//
//  SearchResultPresener.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterSearchOutput.h"
#import "TwitterSearchInput.h"
#import "TwitterSearchResultsUI.h"

@interface SearchResultPresenter : NSObject <TwitterSearchOutput>

@property (nonatomic, strong) id<TwitterSearchInput> searchInput;
@property (nonatomic, strong) id<TwitterSearchResultsUI> searchResultsUI;

@end
