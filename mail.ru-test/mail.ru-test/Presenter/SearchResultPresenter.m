//
//  SearchResultPresener.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "SearchResultPresenter.h"
#import "SearchResultDataSource.h"
#import "TweetUIData.h"
#import "TweetSummary.h"

@interface SearchResultPresenter() {
    id<TwitterSearchResultsUI> _searchResultsUI;
    NSDateFormatter *_localDateFormatter;
}
@property (nonatomic, strong) SearchResultDataSource *searchResultDataSource;
@property (nonatomic, readonly) NSDateFormatter *localDateFormatter;
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

- (id<TwitterSearchResultsUI>)searchResultsUI {
    return _searchResultsUI;
}

- (NSDateFormatter*)localDateFormatter {
    if (!_localDateFormatter) {
        _localDateFormatter = [[NSDateFormatter alloc]init];
        [_localDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_localDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _localDateFormatter;
}

#pragma mark - TwitterSearchOutput

- (void)tweetsFound:(NSArray*)tweetSummaries {
    NSMutableArray *tweetUIDataList = [NSMutableArray new];
    
    for (TweetSummary *tweetSummary in tweetSummaries) {
        
        NSString *userName = tweetSummary.user;
        NSString *dateTime = [self dateTimeStringFromDate:tweetSummary.date];
        NSString *status = tweetSummary.text;
        TweetUIData *tweetUIData = [[TweetUIData alloc] initWithDateTimeText:dateTime
                                                                    userName:userName
                                                                  statusText:status];
        [tweetUIDataList addObject:tweetUIData];
    }
    
    [self.searchResultDataSource addTweets: tweetUIDataList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchResultsUI showNewTweets];
    });
}

- (NSString*)dateTimeStringFromDate:(NSDate*)date {
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    self.localDateFormatter.timeZone = localTimeZone;
    return [self.localDateFormatter stringFromDate:date];
}

- (void)resetSearchResults {
    [self.searchResultDataSource resetTweets];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchResultsUI showNewTweets];
    });
}

- (void)errorOccured:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchResultsUI showModalDialogWithTitle:@"Ошибка" message:error.localizedDescription];
    });
}

#pragma mark - SearchResultsUIEventHandler

- (void)searchResultUIDidAppearToUser {
    [self.searchResultsUI startEditSearchString];
    
    if ([self.searchInput respondsToSelector:@selector(searchUIIsReadyForPresentation)]) {
        [self.searchInput searchUIIsReadyForPresentation];
    }
}

- (void)queryStringHasBeenChangedByUser:(NSString*)queryString {
    [self.searchInput searchForUserInput:queryString];
}

- (void)userReachedTheEndOfList {
    [self.searchInput searchMore];
}

@end
