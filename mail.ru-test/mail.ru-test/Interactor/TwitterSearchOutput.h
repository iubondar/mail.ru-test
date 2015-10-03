//
//  TwitterSearchOutput.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterSearchOutput <NSObject>

- (void)resetSearchResults;
- (void)tweetsFound:(NSArray*)tweetSummaries;

@end
