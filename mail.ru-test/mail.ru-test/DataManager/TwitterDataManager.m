//
//  TwitterDataManager.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "TwitterDataManager.h"
#import "ErrorCodes.h"
#import "NSObject+Empty.h"
#import "TweetSummary.h"

static int const kTweetsPerPage = 20;

static NSString * const kTweetStatusesKey = @"statuses";
static NSString * const kTweetIDKey = @"id";
static NSString * const kTweetTextKey = @"text";
static NSString * const kTweetDateKey = @"created_at";
static NSString * const kTweetUserKey = @"user";
static NSString * const kTweetNameKey = @"name";

@interface TwitterDataManager() {
    NSDateFormatter *_twitterParserFormatter;
}

@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, readonly) NSDateFormatter *twitterParserFormatter;

@end

@implementation TwitterDataManager

#pragma mark - TwitterDataSource implementation

@synthesize twitterURLBuilder;

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

// @warning - Упрощение: используем только настроенные в Settings аккаунты.
// Если аккаунтов больше одного - используем первый в списке
- (void)connectToTwitterWithSuccess:(TwitterConnectionSuccessCallback)successCallback
                              error:(TwitterErrorCallback)errorCallback
{
    
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Запросить доступ к аккаунтам
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            // Доступ предоставлен - проверить, настроен ли хотя бы один аккаунт
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0) {
                self.twitterAccount = [accounts objectAtIndex:0];
                if (successCallback) successCallback();
            }
            else {
                if (errorCallback) errorCallback([self errorWithCode:kTwitterAccountSetupErrorCode
                                                         description:@"Пожалуйста, настройте ваш Твиттер аккаунт."]);
            }
        } else {
            if (errorCallback) errorCallback([self errorWithCode:kTwitterAccountSetupErrorCode
                                                     description:@"Доступ не предоставлен."]);
        }
    }];
}

- (void)searchTweetsByHashtag:(NSString *)hashtag
                      sinceID:(NSString *)sinceID
              successCallback:(SuccessTweetsSearchCallback)successCallback
                errorCallback:(TwitterErrorCallback)errorCallback
{
    NSAssert(self.twitterURLBuilder, @"URL builder should be set");
    
    if (self.twitterAccount) {
        [self performSearchByHashtag:hashtag
                             sinceID:sinceID
                     successCallback:successCallback
                       errorCallback:errorCallback];
    }
    else {
        [self connectToTwitterWithSuccess:^{
            [self performSearchByHashtag:hashtag
                                 sinceID:sinceID
                         successCallback:successCallback
                           errorCallback:errorCallback];
        } error:errorCallback];
    }
}

- (void)performSearchByHashtag:(NSString *)hashtag
                       sinceID:(NSString *)sinceID
               successCallback:(SuccessTweetsSearchCallback)successCallback
                 errorCallback:(TwitterErrorCallback)errorCallback
{
    NSDictionary *requestParameters = [self requestParametersForHashtag:hashtag sinceID:sinceID];
    
    SLRequest *twitterSearchRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                          requestMethod:SLRequestMethodGET
                                                                    URL:[self.twitterURLBuilder twitterSearchURL]
                                                             parameters:requestParameters];
    [twitterSearchRequest setAccount:self.twitterAccount];
    
    [twitterSearchRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self processTwitterSearchResultWithData:responseData
                                     urlResponce:urlResponse
                                           error:error
                                 successCallback:successCallback
                                   errorCallback:errorCallback];
    }];
}

- (NSDictionary*)requestParametersForHashtag:(NSString*)hashtag sinceID:(NSString*)sinceID {
    NSString *queryHashtag = ([hashtag hasPrefix:@"#"]) ? hashtag : [NSString stringWithFormat:@"#%@", hashtag];
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                             @"q":queryHashtag,
                                                                                             @"count":@(kTweetsPerPage)
                                                                                             }];
    if (sinceID) requestParameters[@"since_id"] = sinceID;
    return requestParameters;
}

- (void)processTwitterSearchResultWithData:(NSData *)responseData
                               urlResponce:(NSHTTPURLResponse *)urlResponse
                                     error:(NSError *)error
                           successCallback:(SuccessTweetsSearchCallback)successCallback
                             errorCallback:(TwitterErrorCallback)errorCallback
{
    if ([urlResponse statusCode] == kTwitterRateLimitExceededErrorCode) {
        if (errorCallback)
            errorCallback([self errorWithCode:kTwitterRateLimitExceededErrorCode
                                  description:@"Превышен лимит запросов"]);
        return;
    }

    if (error) {
        if (errorCallback) errorCallback(error);
        return;
    }
    
    if (responseData) {
        
        NSError *error = nil;
        id resultData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            if (errorCallback) errorCallback([self parsingError]);
            return;
        }
        
        [self parseSearchResultData:resultData
                            success:successCallback
                              error:errorCallback];
    }
    else {
        if (successCallback) successCallback(nil);
    }
}

- (void)parseSearchResultData:(id)resultData
                      success:(SuccessTweetsSearchCallback)successCallback
                        error:(TwitterErrorCallback)errorCallback
{
    @try {
        NSMutableArray *tweetSummaries = [NSMutableArray new];
        
        NSArray *statuses = [resultData objectForKey:kTweetStatusesKey];
        if ([NSObject isNotEmpty:statuses]) {
            for (NSDictionary * status in statuses) {
                
                TweetSummary *tweetSummary = [self tweetSummaryFromStatusDictionary:status];
                if (tweetSummary) [tweetSummaries addObject:tweetSummary];
            }
        }
        
        if (successCallback) successCallback(tweetSummaries);
    }
    @catch (NSException *exception) {
        if (errorCallback) errorCallback([self parsingError]);
    }
}

- (TweetSummary*) tweetSummaryFromStatusDictionary:(NSDictionary*)status {
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

- (NSError*)errorWithCode:(NSInteger)code description:(NSString*)description {
    return [NSError errorWithDomain:kGeneralErrorDomain code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

- (NSError*)parsingError {
    return [NSError errorWithDomain:kGeneralErrorDomain code:kTwitterResponceParsingErrorCode
                           userInfo:@{NSLocalizedDescriptionKey: @"Ошибка при обработке ответа сервера"}];
}

@end

