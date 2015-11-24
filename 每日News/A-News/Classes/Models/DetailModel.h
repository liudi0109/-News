//
//  DetailModel.h
//  A-News
//
//  Created by lanou3g on 15/11/18.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailModel : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *image_source; // 版权库
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *share_url;
@property (nonatomic, retain) NSString *recommenders;  // 推荐者
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSString *body;

@end
