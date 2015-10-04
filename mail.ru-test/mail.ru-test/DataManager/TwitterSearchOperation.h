//
//  TwitterSearchOperation.h
//  mail.ru-test
//
//  Created by Бондарь Иван on 04/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "TwitterDataSource.h"

@interface TwitterSearchOperation : NSOperation

- (instancetype)initWithRequest:(SLRequest*)twitterSearchRequest
                successCallback:(SuccessTweetsSearchCallback)successCallback
                  errorCallback:(TwitterErrorCallback)errorCallback;

@end
