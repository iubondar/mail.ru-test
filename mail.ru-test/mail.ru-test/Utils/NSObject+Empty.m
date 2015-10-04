//
//  NSObject+Empty.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 04/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "NSObject+Empty.h"

@implementation NSObject (Empty)

+ (BOOL)isNotEmpty:(id)object {
    return !( object == nil || [object isEqual:[NSNull null]] );
}

@end
