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
    return [self URLFromString:[self twitterSearchURLString]];
}

- (NSURL*)URLForNextPage:(NSString*)nextPageURL {
    NSString * URLString = [NSString stringWithFormat:@"%@%@", [self twitterSearchURLString], nextPageURL];
    return [self URLFromString:URLString];
}

- (NSString*)twitterSearchURLString {
    return @"https://api.twitter.com/1.1/search/tweets.json";
}

- (NSURL*)URLFromString:(NSString*)URLString {
    return [NSURL URLWithString:URLString];
}

@end
