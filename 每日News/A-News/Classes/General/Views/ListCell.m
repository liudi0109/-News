//
//  ListCell.m
//  A-News
//
//  Created by lanou3g on 15/11/17.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "ListCell.h"
#import "Latest.h"

@implementation ListCell

- (void)setLatest:(Latest *)latest {
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:latest.images.lastObject] placeholderImage:[UIImage imageNamed:@"1"]];
    self.titleLabel.text = latest.title;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
