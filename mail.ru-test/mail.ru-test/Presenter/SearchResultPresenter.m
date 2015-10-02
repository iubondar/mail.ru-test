//
//  SearchResultPresener.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "SearchResultPresenter.h"
#import "SearchResultDataSource.h"

@interface SearchResultPresenter()
@property (nonatomic, strong) SearchResultDataSource *searchResultDataSource;
@end

@implementation SearchResultPresenter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.searchResultDataSource = [SearchResultDataSource new];
    }
    return self;
}

- (void) setSearchResultsUI:(id<TwitterSearchResultsUI>)searchResultsUI {
    searchResultsUI.searchResultDataSource = self.searchResultDataSource;
    _searchResultsUI = searchResultsUI;
}

#pragma mark - TwitterSearchOutput

- (void)tweetsFound:(NSArray*)tweetSummaries {
    
}

@end
