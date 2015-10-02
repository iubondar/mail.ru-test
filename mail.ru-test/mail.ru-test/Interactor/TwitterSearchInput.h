//
//  TWHashTagSearchinput.h
//  mail.ru-test
//
//  Created by Ivan Bondar on 02/10/15.
//  Copyright © 2015 Ivan Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterSearchInput <NSObject>

- (void)searchForUserInput:(NSString*)inputString;
- (void)searchMore;

@end
