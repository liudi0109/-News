//
//  Latest.h
//  A-News
//
//  Created by lanou3g on 15/11/17.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Latest : NSObject

@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *stories;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSString *ga_prefix;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSString *multipic;
@property (nonatomic, retain) NSString *top_stories;
@property (nonatomic, retain) NSString *image;

@end
