//
//  TwitterSearchByHashtagInteractor.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterSearchInput.h"
#import "TwitterSearchOutput.h"
#import "TwitterDataSource.h"

@interface TwitterSearchInteractor : NSObject <TwitterSearchInput>

@property (nonatomic, weak) id<TwitterSearchOutput> output;
@property (nonatomic, weak) id<TwitterDataSource> twitterDataSource;

@end
