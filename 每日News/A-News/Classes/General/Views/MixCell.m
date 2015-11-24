//
//  MixCell.m
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "MixCell.h"
#import "MixModel.h"

@implementation MixCell

- (void)setModel:(MixModel *)model {
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.images.lastObject] placeholderImage:[UIImage imageNamed:@"1"]];
    self.nameLabel.text = model.title;
    
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
