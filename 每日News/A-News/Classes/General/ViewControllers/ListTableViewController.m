//
//  ListTableViewController.m
//  A-News
//
//  Created by lanou3g on 15/11/17.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListCell.h"
#import "Latest.h"
#import "DetailViewController.h"
#import "MixTableViewController.h"
#import "MixModel.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface ListTableViewController ()<YAScrollSegmentControlDelegate,SDCycleScrollViewDelegate,ADCircularMenuDelegate>

@property (nonatomic, strong) NSString *todayDate;  // 今天的日期
@property (nonatomic, retain) NSMutableArray *todayArray;  // 今天新闻
@property (nonatomic, retain) NSMutableArray *oldArray;  // 旧新闻
@property (nonatomic, retain) NSMutableArray *scrollArray;  // 轮播图
@property (nonatomic, retain) NSMutableArray *sectionArray; // 标题
@property (nonatomic, retain) NSMutableArray *mixArray;  // 分类
@property (nonatomic, retain) YAScrollSegmentControl *segmentControl;
@property (nonatomic, retain) SDCycleScrollView *cycleScrollView;
@property (strong, nonatomic) IBOutlet UIView *aView;
@property (nonatomic, retain) Latest *latest;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;  // 分区字典
@property (nonatomic, retain) ListTableViewController *ListTableView;
@property (nonatomic, retain) ADCircularMenuViewController *circularMenuVC;

@property (nonatomic, assign) BOOL isColor;

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    UINavigationController *nav = self.navigationController;
//    nav.navigationBar.translucent = NO;
//    self.isColor = NO;
    // 注册
    [self.tableView registerNib:[UINib nibWithNibName:@"ListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    self.tableView.tableHeaderView = _aView;
    [self segmentTitle];
    [self requestDate];
    // 集成刷新控件
    [self addRefreshAndLoad];
    
}

/**
 *  集成刷新控件
 */
#pragma mark --方法：下拉刷新 上拉加载
- (void)addRefreshAndLoad{
    
    // 下拉刷新
    __unsafe_unretained UITableView *tableView = self.tableView;
    
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        // 模拟延迟加载数据，因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [tableView.mj_header endRefreshing];
        });
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉加载
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self requestOldDate];
        // 模拟延迟加载数据，因此2秒后才调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
}


// ----------------------解析今日数据------------------
- (void)requestDate {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:KLatestURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // tableView
        NSArray *array1 = responseObject[@"stories"];
        for (NSDictionary *dic in array1) {
            Latest *latest = [Latest new];
            [latest setValuesForKeysWithDictionary:dic];
            [self.todayArray addObject:latest];
        }
        // 轮播图
        NSArray *array2 = responseObject[@"top_stories"];
        for (NSDictionary *dic in array2) {
            Latest *latest = [Latest new];
            [latest setValuesForKeysWithDictionary:dic];
            [self.scrollArray addObject:latest];
        }
        // 分区时间
        self.todayDate = responseObject[@"date"];
        [self.sectionArray addObject:responseObject[@"date"]];
        [self.dataDictionary setObject:self.todayArray forKey:responseObject[@"date"]];
        
        //刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self wheelPicture];  // 调用轮播图方法
            [self requestOldDate]; // 调用解析方法
            [self requestMixData];  // 调用分类解析方法
            [self.tableView reloadData];
        });
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"今日数据解析失败");
    }];

}

// ----------------------解析往日数据------------------
- (void)requestOldDate {
    
    if (self.oldArray.count) {
        [self.oldArray removeAllObjects];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kOldNewsURL,self.todayDate]];
    NSLog(@"%@", url);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // tableView
            NSArray *array = dic[@"stories"];
            for (NSDictionary *dic in array) {
                Latest *latest = [Latest new];
                [latest setValuesForKeysWithDictionary:dic];
                [self.oldArray addObject:latest];
            }
            // 分区
            [self.sectionArray addObject:dic[@"date"]];
            self.todayDate = dic[@"date"];
            NSLog(@"%@",dic[@"date"]);
            // 排序
            // 1.系统默认升序
//            NSComparator sortBlock = ^(id string1, id string2) {
//                return [string1 compare:string2];
//            };
//            NSArray *sortArray1 = [self.sectionArray sortedArrayUsingComparator:sortBlock];
            // 2.强制降序
            NSArray *sortArray2 = [_sectionArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj2 compare:obj1];
            }];
            self.sectionArray = [NSMutableArray arrayWithArray:sortArray2];
            [self.dataDictionary setObject:_oldArray forKey:dic[@"date"]];
            
            //刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });

        }];
        [task resume];

}

// ----------------------解析分段数据-----------------
- (void)requestMixData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:kMixUrl parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 解析
        NSArray *array = responseObject[@"others"];
        for (NSDictionary *dic in array) {
            MixModel *model = [MixModel new];
            [model setValuesForKeysWithDictionary:dic];
            [self.mixArray addObject:model];
        }

        //刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"------------分段解析失败了");
    }];
}

// ----------------------分段标题------------------
- (void)segmentTitle {
    
    if ([self.view viewWithTag:11]) {
        [[self.view viewWithTag:11] removeFromSuperview];
    }
    
    self.segmentControl = [[YAScrollSegmentControl alloc] initWithFrame:CGRectMake(0, 0, Width, 40)];
    _segmentControl.buttons = @[@"首页", @"设计日报", @"互联网安全", @"开始游戏", @"音乐日报",@"动漫日报",@"用户推荐日报"];
    _segmentControl.delegate = self;
    _segmentControl.tag = 11;
    [_segmentControl setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    _segmentControl.gradientColor = [UIColor lightGrayColor];
    [_aView addSubview:_segmentControl];
    
}

// ----------------------轮播图------------------
- (void)wheelPicture {
    
    //网络加载 --- 创建带标题的图片轮播器
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 40, Width, 200) imageURLStringsGroup:nil]; // 模拟网络延时情景

    _cycleScrollView.delegate = self;  // 代理
    NSMutableArray *imagesURLStrings = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];
    for (Latest *late in self.scrollArray) {
        [titles addObject:late.title];
        [imagesURLStrings addObject:late.image];
    }
    
    _cycleScrollView.titlesGroup = titles;
    // 自定义分页控件小圆标颜色
    _cycleScrollView.dotColor = [UIColor lightGrayColor];
    // 占位图片
    _cycleScrollView.placeholderImage = [UIImage imageNamed:@"1"];
    // 设置pageControl居右，默认居中
    _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    // 自定义轮播时间间隔
    _cycleScrollView.autoScrollTimeInterval = 2;
    [_aView addSubview:_cycleScrollView];

    // --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
        
    });
    
    // 清除缓存
//    [_cycleScrollView clearCache];
    
}

// 左item，设置
- (IBAction)Settings:(UIBarButtonItem *)sender {
    
    self.circularMenuVC = nil;
    
    NSArray *arrImageName = [[NSArray alloc] initWithObjects:@"black",
                             @"white",
                             @"cyan",
                             @"orange",
                             @"green",
                             @"color",
                             @"color", nil];
    
    // 初始化并确认协议
    _circularMenuVC = [[ADCircularMenuViewController alloc] initWithMenuButtonImageNameArray:arrImageName andCornerButtonImageName:nil];
    _circularMenuVC.delegateCircularMenu = self;
    [_circularMenuVC show];  // 展示
}

- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex {
    
    if (buttonIndex == 0) {
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.tableView.nightBackgroundColor = UIColorFromRGB(0x343434);
        }];
        // 设置模式颜色
        [DKNightVersionManager nightFalling];
        
    }
    if (buttonIndex == 1) {
        @weakify(self);
        [self addColorChangedBlock:^{
            @strongify(self);
            self.tableView.normalBackgroundColor = UIColorFromRGB(0xffffff);
        }];
        // 设置模式颜色
        [DKNightVersionManager dawnComing];
        
    }
    if (buttonIndex == 2) {
        // 天青
        self.view.backgroundColor = [UIColor colorWithRed:0.432 green:0.998 blue:1.000 alpha:1.000];
    }
    if (buttonIndex == 3) {
        // 橙
        self.view.backgroundColor = [UIColor colorWithRed:0.989 green:1.000 blue:0.066 alpha:1.000];
    }
    if (buttonIndex == 4) {
        // 绿
        self.view.backgroundColor = [UIColor colorWithRed:0.553 green:1.000 blue:0.485 alpha:1.000];
    }
    if (buttonIndex == 5) {
        self.isColor = YES;
        if (self.isColor) {
            [self.view showLightingWithColors:@[[UIColor cyanColor], [UIColor yellowColor], [UIColor whiteColor],[UIColor colorWithRed:1.000 green:0.533 blue:0.914 alpha:1.000],[UIColor colorWithRed:0.175 green:0.478 blue:1.000 alpha:1.000],[UIColor colorWithRed:1.000 green:0.398 blue:0.480 alpha:1.000],[UIColor colorWithRed:0.553 green:1.000 blue:0.485 alpha:1.000]]];
        }
    }
    if (buttonIndex == 6) {
        self.isColor = NO;
        [self.view pauseLighting];
        [self.view showLightingWithColors:@[[UIColor whiteColor]]];
    }
}

#pragma mark -segment代理方法
- (void)didSelectItemAtIndex:(NSInteger)index {
    
    // 设计日报
    if (index == 1) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.name = @"设计日报";
        mixVC.id = 4;
        [self.navigationController pushViewController:mixVC animated:YES];
    }
    // 互联网安全
    if (index == 2) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.id = 10;
        mixVC.name = @"互联网安全";
        [self.navigationController pushViewController:mixVC animated:YES];
    }
    // 开始游戏
    if (index == 3) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.id = 2;
        mixVC.name = @"开始游戏";
        [self.navigationController pushViewController:mixVC animated:YES];
    }
    // 音乐日报
    if (index == 4) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.id = 7;
        mixVC.name = @"音乐日报";
        [self.navigationController pushViewController:mixVC animated:YES];
    }
    // 动漫日报
    if (index == 5) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.id = 9;
        mixVC.name = @"动漫日报";
        [self.navigationController pushViewController:mixVC animated:YES];
    }
    // 用户推荐日报
    if (index == 6) {
        MixTableViewController *mixVC = [MixTableViewController sharedHomeNav];
        mixVC.id = 12;
        mixVC.name = @"用户推荐日报";
        [self.navigationController pushViewController:mixVC animated:YES];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    Latest *latest = _scrollArray[index];
    detailVC.ID = latest.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"+++++++++++++++++++++==========%ld",[self.dataDictionary[_sectionArray[section]] count]);
    return [self.dataDictionary[_sectionArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // 选中无灰色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.dataDictionary[_sectionArray[indexPath.section]] count] != 0) {
        NSArray *array = self.dataDictionary[_sectionArray[indexPath.section]];
        Latest *latest = array[indexPath.row];
        [cell setLatest:latest];
    }
    
    if (self.isColor) {
        [cell showLightingWithColors:@[[UIColor cyanColor], [UIColor yellowColor], [UIColor whiteColor], [UIColor colorWithRed:1.000 green:0.533 blue:0.914 alpha:1.000],[UIColor colorWithRed:0.175 green:0.478 blue:1.000 alpha:1.000],[UIColor colorWithRed:1.000 green:0.398 blue:0.480 alpha:1.000],[UIColor colorWithRed:0.553 green:1.000 blue:0.485 alpha:1.000]]];
    } else {
        [cell showLightingWithColors:@[[UIColor whiteColor]]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Width, 30)];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.highlightedTextColor = [UIColor whiteColor];
//    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blueColor];
    headerLabel.frame = CGRectMake(10, 0, Width, 30);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [customView addSubview:headerLabel];
    headerLabel.text = _sectionArray[section];
    
    return customView;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detailVC = [[DetailViewController alloc] init];

    if (_sectionArray[indexPath.section] == 0) {
        Latest *latest = _todayArray[indexPath.row];
        // 属性传值
        detailVC.ID = latest.ID;
    }
    
    if (_sectionArray[indexPath.section] != 0) {
        Latest *latest = self.dataDictionary[_sectionArray[indexPath.section]][indexPath.row];
        detailVC.ID = latest.ID;
    }
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark --懒加载
-(NSMutableArray *)oldArray {
    if (!_oldArray) {
        _oldArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _oldArray;
}

-(NSMutableArray *)todayArray {
    if (!_todayArray) {
        _todayArray = [NSMutableArray array];
    }
    return _todayArray;
}

-(NSMutableArray *)scrollArray {
    if (!_scrollArray) {
        _scrollArray = [NSMutableArray array];
    }
    return _scrollArray;
}

-(NSMutableArray *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

- (NSMutableDictionary *)dataDictionary {
    if (!_dataDictionary) {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    return _dataDictionary;
}

-(NSMutableArray *)mixArray {
    if (!_mixArray) {
        _mixArray = [NSMutableArray array];
    }
    return _mixArray;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
