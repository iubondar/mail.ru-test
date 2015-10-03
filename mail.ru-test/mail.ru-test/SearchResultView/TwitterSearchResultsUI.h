//
//  TwitterSearchResultsUI.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterSearchResultTableDataSource.h"
#import "SearchResultsUIEventHandler.h"

@protocol TwitterSearchResultsUI <NSObject>

@property (nonatomic, weak) id<TwitterSearchResultTableDataSource> searchResultDataSource;
@property (nonatomic, weak) id<SearchResultsUIEventHandler> eventHandler;

- (void)showNewTweets;

@end
