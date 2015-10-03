//
//  TweetUIData.h
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetUIData : NSObject

@property (nonatomic, strong) NSString *dateTimeText;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, copy) NSString *statusText;

- (instancetype)initWithDateTimeText:(NSString*)dateTimeText userName:(NSString*)userName statusText:(NSString*)statusText;

@end
