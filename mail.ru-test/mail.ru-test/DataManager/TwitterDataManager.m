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
#import "TweetSummary.h"
#import "TwitterSearchOperation.h"

static NSString * const kTweetsPerPage = @"20";

@interface TwitterDataManager()

@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, strong) NSOperationQueue * searchQueue;

@end

@implementation TwitterDataManager

#pragma mark - TwitterDataSource implementation

@synthesize twitterURLBuilder;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.searchQueue = [NSOperationQueue new];
        self.searchQueue.maxConcurrentOperationCount = 1;
        self.searchQueue.name = @"Search queue";
        self.searchQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return self;
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
                  nextPageURL:(NSString*)nextPageURL
              successCallback:(SuccessTweetsSearchCallback)successCallback
                errorCallback:(TwitterErrorCallback)errorCallback
{
    NSAssert(self.twitterURLBuilder, @"URL builder should be set");
    
    if (self.twitterAccount) {
        [self performSearchByHashtag:hashtag
                         nextPageURL:(NSString*)nextPageURL
                     successCallback:successCallback
                       errorCallback:errorCallback];
    }
    else {
        [self connectToTwitterWithSuccess:^{
            [self performSearchByHashtag:hashtag
                             nextPageURL:(NSString*)nextPageURL
                         successCallback:successCallback
                           errorCallback:errorCallback];
        } error:errorCallback];
    }
}

- (void)performSearchByHashtag:(NSString *)hashtag
                   nextPageURL:(NSString*)nextPageURL
               successCallback:(SuccessTweetsSearchCallback)successCallback
                 errorCallback:(TwitterErrorCallback)errorCallback
{
    NSDictionary *requestParameters = (nextPageURL !=nil ) ? nil : [self requestParametersForHashtag:hashtag];
    NSURL * url = (nextPageURL !=nil ) ? [self.twitterURLBuilder URLForNextPage:nextPageURL]
                                       : [self.twitterURLBuilder twitterSearchURL];
    
    SLRequest *twitterSearchRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:url
                                                            parameters:requestParameters];
    [twitterSearchRequest setAccount:self.twitterAccount];
    
    TwitterSearchOperation *searchOperation = [[TwitterSearchOperation alloc] initWithRequest:twitterSearchRequest
                                                                              successCallback:successCallback
                                                                                errorCallback:errorCallback];
    searchOperation.name = [NSString stringWithFormat:@"Search by: %@", hashtag];
    [self.searchQueue addOperation:searchOperation];
    
#ifdef LOG_OPERATIONS
    NSLog(@"Search queue: %@", self.searchQueue.operations);
#endif
}

- (void)cancelCurrentSearch {
#ifdef LOG_OPERATIONS
    NSLog(@"Cancel: %@", self.searchQueue.operations);
#endif
    [self.searchQueue cancelAllOperations];
}

- (NSDictionary*)requestParametersForHashtag:(NSString*)hashtag {
    NSString *queryHashtag = ([hashtag hasPrefix:@"#"]) ? hashtag : [NSString stringWithFormat:@"#%@", hashtag];
    NSDictionary *requestParameters = @{@"q":queryHashtag, @"count": kTweetsPerPage};
    return requestParameters;
}

- (NSError*)errorWithCode:(NSInteger)code description:(NSString*)description {
    return [NSError errorWithDomain:kGeneralErrorDomain code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end

