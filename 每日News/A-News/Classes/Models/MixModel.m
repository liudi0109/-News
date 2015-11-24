//
//  MixModel.m
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "MixModel.h"

@implementation MixModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.Description = value;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@--%@--%@--%ld",_name,_Description,_title,_id];
}


@end
