//
//  TwitterSearchResultsUI.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterSearchResultTableDataSource.h"

@protocol TwitterSearchResultsUI <NSObject>

@property (nonatomic, weak) id<TwitterSearchResultTableDataSource> searchResultDataSource;

@end
