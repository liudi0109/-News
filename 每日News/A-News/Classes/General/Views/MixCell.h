//
//  MixCell.h
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MixModel;

@interface MixCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) MixModel *model;

@end
