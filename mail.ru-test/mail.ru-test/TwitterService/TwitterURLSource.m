//
//  TwitterURLSource.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TwitterURLSource.h"
#import "TwitterAPIURLBuilder.h"

@implementation TwitterURLSource

- (NSURL*)twitterSearchURL {
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
}

@end
