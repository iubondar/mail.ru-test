//
//  TwitterDataSource.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessTweetsSearchCallback)(NSArray *searchResults);
typedef void (^ErrorTweetsSearchCallback)(NSError *error);

@protocol TwitterDataSource <NSObject>

- (void)searchTweetsByHashtag:(NSString*)hashtag successCallback:(SuccessTweetsSearchCallback)successCallback errorCallback:(ErrorTweetsSearchCallback)errorCallback;

@end
