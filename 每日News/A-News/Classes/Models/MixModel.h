//
//  MixModel.h
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MixModel : NSObject

@property (nonatomic, retain) NSString *background;  // 图片
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, retain) NSString *name;

@end
