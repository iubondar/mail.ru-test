//
//  TweetSummary.h
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetSummary : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithDate:(NSDate*)date user:(NSString*)user text:(NSString*)text;

@end
