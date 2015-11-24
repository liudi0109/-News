//
//  DetailModel.m
//  A-News
//
//  Created by lanou3g on 15/11/18.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "DetailModel.h"

@implementation DetailModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.ID = [value integerValue];
    }
}


@end
