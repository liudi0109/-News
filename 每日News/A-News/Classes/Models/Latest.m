//
//  Latest.m
//  A-News
//
//  Created by lanou3g on 15/11/17.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "Latest.h"

@implementation Latest

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.ID = [value integerValue];
    }
}


@end
