//
//  TweetUIData.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TweetUIData.h"

@implementation TweetUIData

- (instancetype)initWithDateTimeText:(NSString*)dateTimeText userName:(NSString*)userName statusText:(NSString*)statusText {
    self = [super init];
    if (self) {
        self.dateTimeText = dateTimeText;
        self.userName = userName;
        self.statusText = statusText;
    }
    return self;
}

@end
