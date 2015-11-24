//
//  MixTableViewController.m
//  A-News
//
//  Created by lanou3g on 15/11/19.
//  Copyright © 2015年 刘迪. All rights reserved.
//

#import "MixTableViewController.h"
#import "MixModel.h"
#import "MixCell.h"
#import "MixDetailViewController.h"

@interface MixTableViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imgBackgroud;
@property (strong, nonatomic) IBOutlet UILabel *descripLabel;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) NSString *str;

@end

@implementation MixTableViewController

static MixTableViewController *homeNav = nil;
+(MixTableViewController *)sharedHomeNav{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        homeNav = [sb instantiateViewControllerWithIdentifier:@"didi"];
    });
    return homeNav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册
    [self.tableView registerNib:[UINib nibWithNibName:@"MixCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [_dataArray removeAllObjects];
    self.title = _name;
    [self requestMixData];
}
// 解析分段数据
- (void)requestMixData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    self.str = [NSString stringWithFormat:@"%@%ld",kMixListUrl,self.id];
    [manager GET:_str parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // cell解析
        NSArray *array = responseObject[@"stories"];
        for (NSDictionary *dic in array) {
            MixModel *model = [MixModel new];
            [model setValuesForKeysWithDictionary:dic];
            [self.dataArray addObject:model];
        }

        // 解析大图标
        MixModel *model = [MixModel new];
        [model setValuesForKeysWithDictionary:responseObject];
        // 赋值
        [self.imgBackgroud sd_setImageWithURL:[NSURL URLWithString:model.background]];
        self.descripLabel.text = model.Description;
        
        //刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"------------失败了");
    }];

}

// 懒加载
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MixCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MixModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MixDetailViewController *detaiMixVC = [[MixDetailViewController alloc] init];
    
    MixModel *model = _dataArray[indexPath.row];
    detaiMixVC.id = model.id;
    
    [self.navigationController pushViewController:detaiMixVC animated:YES];
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
