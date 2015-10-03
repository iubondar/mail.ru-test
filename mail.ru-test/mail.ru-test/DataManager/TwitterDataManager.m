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

static int const kTweetsPerPage = 20;

@interface TwitterDataManager()

@property (nonatomic, strong) ACAccount *twitterAccount;

@end

@implementation TwitterDataManager

#pragma mark - TwitterDataSource implementation

@synthesize twitterURLBuilder;

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
        NSArray *resultData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error) {
            if (errorCallback) errorCallback([self errorWithCode:kTwitterResponceParsingErrorCode
                                                     description:@"Ошибка при обработке ответа сервера"]);
            return;
        }
        
        NSLog(@"Data:\n%@", resultData);
    }
}

- (NSError*)errorWithCode:(NSInteger)code description:(NSString*)description {
    return [NSError errorWithDomain:kGeneralErrorDomain code:code
                           userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end

