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
}

@property (nonatomic, strong) SLRequest *twitterSearchRequest;
@property (nonatomic, copy) SuccessTweetsSearchCallback successCallback;
@property (nonatomic, copy) TwitterErrorCallback errorCallback;

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

- (instancetype)initWithRequest:(SLRequest *)twitterSearchRequest
                successCallback:(SuccessTweetsSearchCallback)successCallback
                  errorCallback:(TwitterErrorCallback)errorCallback
{
    self = [super init];
    if (self) {
        self.twitterSearchRequest = twitterSearchRequest;
        self.successCallback = successCallback;
        self.errorCallback = errorCallback;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        [self.twitterSearchRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
            [self checkCancellation];
            
            [self processTwitterSearchResultWithData:responseData
                                         urlResponce:urlResponse
                                               error:error
                                     successCallback:self.successCallback
                                       errorCallback:self.errorCallback];
        }];
    }
}

- (void)processTwitterSearchResultWithData:(NSData *)responseData
                               urlResponce:(NSHTTPURLResponse *)urlResponse
                                     error:(NSError *)error
                           successCallback:(SuccessTweetsSearchCallback)successCallback
                             errorCallback:(TwitterErrorCallback)errorCallback
{
    if ([urlResponse statusCode] == kTwitterRateLimitExceededErrorCode) {
        if (errorCallback)
            errorCallback([NSError errorWithDomain:kGeneralErrorDomain code:kTwitterRateLimitExceededErrorCode
                                          userInfo:@{NSLocalizedDescriptionKey: @"Превышен лимит запросов"}]);
        return;
    }
    
    if (error) {
        if (errorCallback) errorCallback(error);
        return;
    }
    
    if (responseData) {
        
        NSError *error = nil;
        id resultData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        [self checkCancellation];
        
        if (error) {
            if (errorCallback) errorCallback([self parsingError]);
            return;
        }
        
        [self parseSearchResultData:resultData
                            success:successCallback
                              error:errorCallback];
        
        responseData = nil;
    }
    else {
        if (successCallback) successCallback(nil, nil);
    }
}

- (void)parseSearchResultData:(id)resultData
                      success:(SuccessTweetsSearchCallback)successCallback
                        error:(TwitterErrorCallback)errorCallback
{
    @try {
        NSMutableArray *tweetSummaries = [NSMutableArray new];
        NSString *nextPageURL;
        
        NSDictionary * searchMetadata = [resultData objectForKey:kTweetSearchMetadataKey];
        if ([NSObject isNotEmpty:searchMetadata]) {
            NSString * nextResults = [searchMetadata objectForKey:kTweetNextResultsKey];
            if ([NSObject isNotEmpty:nextResults]) nextPageURL = nextResults;
        }
        
        [self checkCancellation];
        
        NSArray *statuses = [resultData objectForKey:kTweetStatusesKey];
        if ([NSObject isNotEmpty:statuses]) {
            for (NSDictionary * status in statuses) {
                [self checkCancellation];
                TweetSummary *tweetSummary = [self tweetSummaryFromStatusDictionary:status];
                if (tweetSummary) [tweetSummaries addObject:tweetSummary];
            }
        }
        
        resultData = nil;
        
        if (successCallback) successCallback(tweetSummaries, nextPageURL);
    }
    @catch (NSException *exception) {
        if (errorCallback) errorCallback([self parsingError]);
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
    return [NSError errorWithDomain:kGeneralErrorDomain code:kTwitterResponceParsingErrorCode
                           userInfo:@{NSLocalizedDescriptionKey: @"Ошибка при обработке ответа сервера"}];
}

- (void)checkCancellation {
    if (self.isCancelled) {
        return;
    }
}

@end
