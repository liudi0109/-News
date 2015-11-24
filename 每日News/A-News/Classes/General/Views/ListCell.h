//
//  ListCell.h
//  A-News
//
//  Created by lanou3g on 15/11/17.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Latest;

@interface ListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) Latest *latest;

@end
