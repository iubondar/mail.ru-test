//
//  TwitterSearchOperation.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 04/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TwitterSearchOperation.h"
#import "ErrorCodes.h"
#import "NSObject+Empty.h"
#import "TweetSummary.h"

static NSString * const kTweetSearchMetadataKey = @"search_metadata";
static NSString * const kTweetNextResultsKey = @"next_results";

static NSString * const kTweetStatusesKey = @"statuses";
static NSString * const kTweetIDKey = @"id";
static NSString * const kTweetTextKey = @"text";
static NSString * const kTweetDateKey = @"created_at";
static NSString * const kTweetUserKey = @"user";
static NSString * const kTweetNameKey = @"name";

@interface TwitterSearchOperation(){
    NSDateFormatter *_twitterParserFormatter;
    
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic, strong) SLRequest *twitterSearchRequest;
@property (nonatomic, copy) SuccessTweetsSearchCallback successCallback;
@property (nonatomic, copy) TwitterErrorCallback errorCallback;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSString* nextPageURL;

@property (nonatomic, readonly) NSDateFormatter *twitterParserFormatter;

@end

@implementation TwitterSearchOperation

- (NSDateFormatter*)twitterParserFormatter {
    if (!_twitterParserFormatter) {
        _twitterParserFormatter = [[NSDateFormatter alloc] init];
        [_twitterParserFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_twitterParserFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        
        // e.g. "Sat Oct 03 20:44:27 +0000 2015"
        [_twitterParserFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    }
    return _twitterParserFormatter;
}

#pragma mark - NSOperation

- (instancetype)initWithRequest:(SLRequest *)twitterSearchRequest
                successCallback:(SuccessTweetsSearchCallback)successCallback
                  errorCallback:(TwitterErrorCallback)errorCallback
{
    self = [super init];
    if (self) {
        self.twitterSearchRequest = twitterSearchRequest;
        self.successCallback = successCallback;
        self.errorCallback = errorCallback;
        
        _isExecuting = NO;
        _isFinished = NO;
    }
    return self;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

- (void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (self.isCancelled) [self finish];
    
#ifdef LOG_OPERATIONS
    NSLog(@"<%@> started.", self.name);
#endif
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.twitterSearchRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (self.isCancelled) [self finish];
        
        [self processTwitterSearchResultWithData:responseData
                                     urlResponce:urlResponse
                                           error:error];
    }];
}

- (void)finish
{
#ifdef LOG_OPERATIONS
    NSLog(@"operation <%@> finished. error: %@", self.name, self.error);
#endif
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (!self.isCancelled) {
        if (self.error) {
            if (self.errorCallback) self.errorCallback(self.error);
        }
        else {
            if (self.successCallback) self.successCallback(self.searchResults, self.nextPageURL);
        }
    }
    else {
#ifdef LOG_OPERATIONS
        NSLog(@"operation <%@> cancelled - finishing", self.name);
#endif
    }
    
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Data processing

- (void)processTwitterSearchResultWithData:(NSData *)responseData
                               urlResponce:(NSHTTPURLResponse *)urlResponse
                                     error:(NSError *)error
{
    if ([urlResponse statusCode] == kTwitterRateLimitExceededErrorCode) {
        self.error = [NSError errorWithDomain:kGeneralErrorDomain code:kTwitterRateLimitExceededErrorCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"Превышен лимит запросов"}];
        [self finish];
        return;
    }
    
    if (error) {
        self.error = error;
        [self finish];
        return;
    }
    
    if (responseData) {
        
        NSError *error = nil;
        id resultData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (self.isCancelled) [self finish];
        
        if (error) {
            self.error = error;
            [self finish];
            return;
        }
        
        [self parseSearchResultData:resultData];
        
        responseData = nil;
    }
}

- (void)parseSearchResultData:(id)resultData
{
    @try {
        NSMutableArray *tweetSummaries = [NSMutableArray new];
        
        NSDictionary * searchMetadata = [resultData objectForKey:kTweetSearchMetadataKey];
        if ([NSObject isNotEmpty:searchMetadata]) {
            NSString * nextResults = [searchMetadata objectForKey:kTweetNextResultsKey];
            if ([NSObject isNotEmpty:nextResults]) self.nextPageURL = nextResults;
        }
        
        
        
        if (self.isCancelled) [self finish];
        
        NSArray *statuses = [resultData objectForKey:kTweetStatusesKey];
        if ([NSObject isNotEmpty:statuses]) {
            for (NSDictionary * status in statuses) {
                
                if (self.isCancelled) [self finish];
                
                TweetSummary *tweetSummary = [self tweetSummaryFromStatusDictionary:status];
                if (tweetSummary) [tweetSummaries addObject:tweetSummary];
            }
        }
        
        resultData = nil;
        
        self.searchResults = tweetSummaries;
        
        [self finish];
    }
    @catch (NSException *exception) {
        self.error = [self parsingError];
        [self finish];
    }
}

- (TweetSummary*)tweetSummaryFromStatusDictionary:(NSDictionary*)status {
    TweetSummary *tweetSummary = [TweetSummary new];
    
    NSNumber * tweetID = [status objectForKey:kTweetIDKey];
    if ([NSObject isNotEmpty:tweetID]) tweetSummary.tweetID = [tweetID stringValue];
    
    NSString * tweetText = [status objectForKey:kTweetTextKey];
    if ([NSObject isNotEmpty:tweetText]) tweetSummary.text = tweetText;
    
    NSString *tweetDateStr = [status objectForKey:kTweetDateKey];
    if ([NSObject isNotEmpty:tweetDateStr]) {
        tweetSummary.date = [self.twitterParserFormatter dateFromString:tweetDateStr];
    }
    
    NSDictionary *user = [status objectForKey:kTweetUserKey];
    if ([NSObject isNotEmpty:user]) {
        NSString *tweetUserName = [user objectForKey:kTweetNameKey];
        if ([NSObject isNotEmpty:tweetUserName]) {
            tweetSummary.user = tweetUserName;
        }
    }
    
    return tweetSummary;
}

- (NSError*)parsingError {
    return [NSError errorWithDomain:kGeneralErrorDomain
                               code:kTwitterResponceParsingErrorCode
                           userInfo:@{NSLocalizedDescriptionKey: @"Ошибка при обработке ответа сервера"}];
}

@end
