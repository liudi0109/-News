//
//  MixDetailViewController.m
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "MixDetailViewController.h"
#import "MixModel.h"

@interface MixDetailViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation MixDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self requestData];
    
    [self.view addSubview:_webView];
    
}
- (void)requestData {
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    NSString * str = [NSString stringWithFormat:@"%@%ld",kDetailUrl,self.id];
    [manager GET:str  parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"成功");
        NSURL * url = [NSURL URLWithString:responseObject[@"share_url"]];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        [self.webView reload];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"失败");
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
