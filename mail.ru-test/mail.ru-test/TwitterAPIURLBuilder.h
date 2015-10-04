//
//  TwitterAPIURLBuilder.h
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterAPIURLBuilder <NSObject>

- (NSURL*)twitterSearchURL;
- (NSURL*)URLForNextPage:(NSString*)nextPageURL;

@end
