//
//  SearchResultCell.m
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "SearchResultCell.h"

@interface SearchResultCell()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation SearchResultCell

- (void)setTweetUIData:(TweetUIData*)tweetUIData {
    self.userLabel.text = tweetUIData.userName;
    self.statusLabel.text = tweetUIData.statusText;
    self.dateLabel.text = tweetUIData.dateTimeText;
}

@end
