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
@property (nonatomic) NSString *nextPageURL;
@property (atomic) BOOL isSearchingMoreTweets;
@end

@implementation TwitterSearchInteractor

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetNextPageURL];
    }
    return self;
}

#pragma mark - TwitterSearchInput

- (void)checkAssertions {
    NSAssert(self.twitterDataSource != nil, @"Twitter data source should be set");
    NSAssert(self.output != nil, @"Output for search results should be set");
}

- (void)searchUIIsReadyForPresentation {
    [self checkAssertions];
    
    [self.twitterDataSource connectToTwitterWithSuccess:nil error:^(NSError *error) {
        [self processError:error];
    }];
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
    if (!self.nextPageURL) return;
    if (self.isSearchingMoreTweets) return;
    
    self.isSearchingMoreTweets = YES;
    
    [self.twitterDataSource searchTweetsByHashtag:self.currentSearchString
                                      nextPageURL:self.nextPageURL
                                  successCallback:^(NSArray *searchResults,  NSString* nextPageURL) {
                                      [self processSearchResults:searchResults nextPageURL:nextPageURL];
                                      self.isSearchingMoreTweets = NO;
                                  } errorCallback:^(NSError *error) {
                                      [self processError:error];
                                      self.isSearchingMoreTweets = NO;
                                  }];
}

- (void)queryTweetsDataFromFirstPageWithInputString:(NSString*)inputString {
    [self resetNextPageURL];
    self.currentSearchString = inputString;
    
    [self.twitterDataSource cancelCurrentSearch];
    [self.output resetSearchResults];
    
    [self.twitterDataSource searchTweetsByHashtag:self.currentSearchString
                                      nextPageURL:self.nextPageURL
                                  successCallback:^(NSArray *searchResults, NSString* nextPageURL) {
                                      [self processSearchResults:searchResults nextPageURL:nextPageURL];
                                  } errorCallback:^(NSError *error) {
                                      [self processError:error];
                                  }];
}

- (void)processSearchResults:(NSArray*)searchResults nextPageURL:(NSString*) nextPageURL {
    if (searchResults.count > 0) {
        self.nextPageURL = nextPageURL;
        [self.output tweetsFound:searchResults];
    }
}

- (void)processError:(NSError*)error {
    [self.output errorOccured:error];
}

#pragma mark - Private

- (void)resetNextPageURL {
    self.nextPageURL = nil;
}

@end
