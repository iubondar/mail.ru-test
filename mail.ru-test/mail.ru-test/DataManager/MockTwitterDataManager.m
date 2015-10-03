//
//  MockTwitterDataManager.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "MockTwitterDataManager.h"
#import "TweetSummary.h"

static int const kTwitterPerPage = 20;

static NSString * const mockTweetText = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

@interface MockTwitterDataManager()
@property (nonatomic, strong) NSArray *userNames;
@end

@implementation MockTwitterDataManager

- (instancetype) init {
    self = [super init];
    if (self) {
        self.userNames = @[@"Chak", @"Jenny", @"Ivan", @"Stepan", @"Ksenia", @"Nikolay", @"Albert", @"Ned", @"Gomer"];
    }
    return self;
}

- (void)searchTweetsByHashtag:(NSString*)hashtag
                      sinceID:(NSString*)sinceID
              successCallback:(SuccessTweetsSearchCallback)successCallback
                errorCallback:(ErrorTweetsSearchCallback)errorCallback;
{
    successCallback([self portionOfTweets]);
}

- (NSArray*)portionOfTweets {
    
    NSMutableArray * tweets = [NSMutableArray new];
    for (int i = 0; i < kTwitterPerPage; i++) {
        NSDate *date = [self generateRandomDateWithinDaysBeforeToday:10];
        int userIndex = arc4random_uniform((int)self.userNames.count);
        int substringIndex = arc4random_uniform(140);
        if (substringIndex < 20) substringIndex += 20;
        NSString * text = [mockTweetText substringToIndex:substringIndex];
        TweetSummary *tweet = [[TweetSummary alloc] initWithID:[NSString stringWithFormat:@"%d", i]
                                                           date:date
                                                            user:self.userNames[userIndex]
                                                            text:text];
        [tweets addObject:tweet];
    }
    return tweets;
}

- (NSDate *) generateRandomDateWithinDaysBeforeToday:(int)days
{
    int r1 = arc4random_uniform(days);
    int r2 = arc4random_uniform(23);
    int r3 = arc4random_uniform(59);
    
    NSDate *today = [NSDate new];
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *offsetComponents = [NSDateComponents new];
    [offsetComponents setDay:(r1*-1)];
    [offsetComponents setHour:r2];
    [offsetComponents setMinute:r3];
    
    NSDate *rndDate1 = [gregorian dateByAddingComponents:offsetComponents
                                                  toDate:today options:0];
    
    return rndDate1;
}

@end
