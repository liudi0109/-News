//
//  DetailViewController.m
//  A-News
//
//  Created by lanou3g on 15/11/18.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailModel.h"
#import "Latest.h"
#define NAVBAR_CHANGE_POINT 50

@interface DetailViewController ()<UIWebViewDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *imgSourceLabel;

@property (nonatomic, assign) NSInteger currentID;
@property (nonatomic, retain) NSMutableArray *todayArray;  // 今天新闻
@property (nonatomic, retain) Latest *latest;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    self.myScrollView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    [self requestData];
    // 集成刷新控件
    [self addRefreshAndLoad];
    
}
/**
 *  集成刷新控件
 */
#pragma mark --方法：下拉刷新 上拉加载
- (void)addRefreshAndLoad{
    
    // 下拉刷新
//    __unsafe_unretained DetailView *detail = self.detail;
    
    self.myScrollView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        // 模拟延迟加载数据，因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_myScrollView.mj_header endRefreshing];
        });
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    _myScrollView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉加载
    _myScrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self requestData];
        
        // 模拟延迟加载数据，因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [_myScrollView.mj_footer endRefreshing];
        });
    }];
}

// 滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    // 控制图片向上移动导航栏的变化
    if (offsetY > 0) {
        if (offsetY >= NAVBAR_CHANGE_POINT) {
            [self setNavigationBarTransformProgress:1];
        } else {
            [self setNavigationBarTransformProgress:(offsetY / NAVBAR_CHANGE_POINT)];
//            [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor blueColor]];
        }
    } else {
        [self setNavigationBarTransformProgress:0];
        self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    }
    // 控制向上滑动时下面出内容补充页面
    if (offsetY >= scrollView.frame.size.height * 0.2) {
        self.webView.scrollView.scrollEnabled = YES;
    }else{
        self.webView.scrollView.scrollEnabled = NO;
    }
    
}

- (void)setNavigationBarTransformProgress:(CGFloat)progress {
    [self.navigationController.navigationBar lt_setTranslationY:(-NAVBAR_CHANGE_POINT * progress)];
    [self.navigationController.navigationBar lt_setElementsAlpha:(1-progress)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar lt_reset];
}

// 解析数据
- (void)requestData {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *str = [NSString stringWithFormat:@"%@%ld",kDetailUrl,self.ID];
    [manager GET:str parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 解析
        DetailModel *model = [DetailModel new];
        [model setValuesForKeysWithDictionary:responseObject];
        // 赋值
        [self.imgView sd_setImageWithURL:[NSURL URLWithString: model.image]];
        self.titleLabel.text = model.title;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.imgSourceLabel.text = model.image_source;
        [self.webView loadHTMLString:model.body baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"------------失败了");
    }];
}

// 取消当前页面所有点击事件
/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        static int i = 0;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求打开链接" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        UIAlertAction *ensure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            i ++;
        }];
        [alert addAction:ensure];
        // 添加视图
        [self presentViewController:alert animated:YES completion:nil];
        if (i == 1) {
            return YES;
        }else {
            return NO;
        }
    }
    return YES;
}
 */

// 详情页修改图片尺寸
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    CGFloat width = self.webView.frame.size.width;
    
    // 修改图片大小
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var script = document.createElement('script');"
        "script.type = 'text/javascript';"
        "script.text = \"function ResizeImages() { "
             "var myimg,oldwidth;"
             "var maxwidth = %f;" //缩放系数
             "for(i=0;i < document.images.length;i++){"
                   "myimg = document.images[i];"
                         "if(myimg.width > maxwidth){"
                              "oldwidth = myimg.width;"
                              "myimg.width = maxwidth;"
                              "myimg.height = myimg.height * (maxwidth/oldwidth) + 90;"
                          "}"
                    "}"
        "}\";"
        "document.getElementsByTagName('head')[0].appendChild(script);",width]];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}

// 开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载");
}
// 懒加载
-(UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc]init];
    }
    return _webView;
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
