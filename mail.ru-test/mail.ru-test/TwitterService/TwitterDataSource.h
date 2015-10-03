//
//  TwitterDataSource.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterAPIURLBuilder.h"

typedef void (^SuccessTweetsSearchCallback)(NSArray *searchResults);
typedef void (^TwitterErrorCallback)(NSError *error);
typedef void (^TwitterConnectionSuccessCallback)();

@protocol TwitterDataSource <NSObject>

@property (nonatomic, strong) id<TwitterAPIURLBuilder> twitterURLBuilder;

- (void)connectToTwitterWithSuccess:(TwitterConnectionSuccessCallback)successCallback
                              error:(TwitterErrorCallback)errorCallback;

- (void)searchTweetsByHashtag:(NSString*)hashtag
                      sinceID:(NSString*)sinceID
              successCallback:(SuccessTweetsSearchCallback)successCallback
                errorCallback:(TwitterErrorCallback)errorCallback;

@end
