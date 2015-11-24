//
//  DetailViewController.h
//  A-News
//
//  Created by lanou3g on 15/11/18.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, assign) NSInteger ID;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end
