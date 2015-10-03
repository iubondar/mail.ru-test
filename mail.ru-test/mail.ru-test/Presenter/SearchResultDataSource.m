//
//  SearchResultDataSource.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "SearchResultDataSource.h"

@interface SearchResultDataSource()
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation SearchResultDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.searchResults = [NSMutableArray new];
    }
    return self;
}

- (void)addTweets:(NSArray *)tweets {
    @synchronized(self) {
        [self.searchResults addObjectsFromArray:tweets];
    }
}

- (void)resetTweets {
    [self.searchResults removeAllObjects];
}

#pragma mark - TwitterSearchResultTableDataSource

- (NSInteger)totalTweetsCount {
    return self.searchResults.count;
}

- (TweetUIData*)tweetUIDataForRow:(NSInteger)rowNumber {
    return (TweetUIData*)self.searchResults[rowNumber];
}

@end
