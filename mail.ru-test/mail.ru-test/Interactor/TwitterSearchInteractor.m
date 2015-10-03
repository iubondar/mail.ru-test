//
//  TwitterSearchByHashtagInteractor.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TwitterSearchInteractor.h"
#import "TweetSummary.h"

@interface TwitterSearchInteractor()
@property (nonatomic, copy) NSString *currentSearchString;
@property (nonatomic) NSString *lastTweetID;
@end

@implementation TwitterSearchInteractor

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetLastTweetID];
    }
    return self;
}

#pragma mark - TwitterSearchInput

- (void)checkAssertions {
    NSAssert(self.twitterDataSource != nil, @"Twitter data source should be set");
    NSAssert(self.output != nil, @"Output for search results should be set");
}

- (void)searchForUserInput:(NSString*)inputString {
    
    [self checkAssertions];
    
    if (inputString.length == 0) {
        [self.output resetSearchResults];
        self.currentSearchString = nil;
        return;
    }
    
    if ([inputString isEqualToString:self.currentSearchString]) return;
    
    [self queryTweetsDataFromFirstPageWithInputString:inputString];
}

- (void)searchMore {
    [self checkAssertions];
    
    if (!self.currentSearchString) return;
    if (!self.lastTweetID) return;
    
    [self.twitterDataSource searchTweetsByHashtag:self.currentSearchString
                                          sinceID:self.lastTweetID
                                  successCallback:^(NSArray *searchResults) {
                                      [self processSearchResults:searchResults];
                                  } errorCallback:^(NSError *error) {
                                      [self processError:error];
                                  }];
}

- (void)queryTweetsDataFromFirstPageWithInputString:(NSString*)inputString {
    [self resetLastTweetID];
    self.currentSearchString = inputString;
    
    [self.output resetSearchResults];
    
    [self.twitterDataSource searchTweetsByHashtag:self.currentSearchString
                                          sinceID:nil
                                  successCallback:^(NSArray *searchResults) {
                                      [self processSearchResults:searchResults];
                                  } errorCallback:^(NSError *error) {
                                      [self processError:error];
                                  }];
}

- (void)processSearchResults:(NSArray*)searchResults {
    if (searchResults.count > 0) {
        TweetSummary *tweetSummary = [searchResults lastObject];
        self.lastTweetID = tweetSummary.tweetID;
        [self.output tweetsFound:searchResults];
    }
}

- (void)processError:(NSError*)error {
    // TODO: show message to user
    NSLog(@"%@", error);
}

#pragma mark - Private

- (void)resetLastTweetID {
    self.lastTweetID = nil;
}

@end
