//
//  TweetSummary.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "TweetSummary.h"

@implementation TweetSummary

- (instancetype)initWithDate:(NSDate*)date user:(NSString*)user text:(NSString*)text; {
    self = [super init];
    if (self) {
        self.date = date;
        self.user = user;
        self.text = text;
    }
    return self;
}

@end
