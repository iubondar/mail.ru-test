
//
//  FittingSizeLabel.m
//  mail.ru-test
//
//  Created by Бондарь Иван on 03/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import "FittingSizeLabel.h"

@implementation FittingSizeLabel

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (self.numberOfLines == 0 && bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}

@end
