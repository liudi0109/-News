//
//  MixTableViewController.h
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, retain) NSString *name;

+(MixTableViewController *)sharedHomeNav;

@end
