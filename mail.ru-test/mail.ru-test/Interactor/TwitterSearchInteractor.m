//
//  TwitterSearchByHashtagInteractor.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TwitterSearchInteractor.h"

@interface TwitterSearchInteractor()
@property (nonatomic, copy) NSString *currentSearchString;
@property (nonatomic) NSInteger pageNumber;
@end

@implementation TwitterSearchInteractor

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetPageNumber];
    }
    return self;
}

#pragma mark - TwitterSearchInput

- (void)searchForUserInput:(NSString*)inputString {
    
    NSAssert(self.twitterDataSource != nil, @"Twitter data source should be set");
    NSAssert(self.output != nil, @"Output for search results should be set");
    
    if (inputString.length == 0) {
        [self.output resetSearchResults];
        self.currentSearchString = nil;
        return;
    }
    
    if ([inputString isEqualToString:self.currentSearchString]) return;
    
    [self queryTweetsDataFromFirstPageWithInputString:inputString];
}

- (void)queryTweetsDataFromFirstPageWithInputString:(NSString*)inputString {
    [self resetPageNumber];
    self.currentSearchString = inputString;
    
    [self.output resetSearchResults];
    
    [self.twitterDataSource searchTweetsByHashtag:self.currentSearchString
                                          sinceID:nil
                                  successCallback:^(NSArray *searchResults) {
                                      [self.output tweetsFound:searchResults];
                                  } errorCallback:^(NSError *error) {
                                      // TODO: show message to user
                                      NSLog(@"%@", error);
                                  }];
}

- (void)searchMore {
    
}

#pragma mark - Private

- (void)resetPageNumber {
    self.pageNumber = 1;
}

@end
