//
//  YHDiscoveryVC.m
//  samuelandkevin
//
//  Created by samuelandkevin on 2017/7/19.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHDiscoveryVC.h"
#import "YHRefreshTableView.h"
#import "YHWorkGroupController.h"

@interface YHDiscoveryVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) YHRefreshTableView *tableView;

@end

@implementation YHDiscoveryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self _initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
- (void)_initUI{
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH
                                                                          , SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
 
    [self.view addSubview:self.tableView];
    self.tableView.rowHeight  = 45;
    self.tableView.backgroundColor = kTbvBGColor;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MyControllerMiddleCell class] forCellReuseIdentifier:NSStringFromClass([MyControllerMiddleCell class])];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!section) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    const NSArray *titleArray1 = @[@"朋友圈"];
    const NSArray *titleArray2 = @[@"扫一扫", @"摇一摇"];
    const NSArray *imageArray1 = @[@"my_collect"];
    const NSArray *imageArray2 = @[@"my_setting", @"my_aboutus"];
    
    switch (indexPath.section){

        case 0:{
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyControllerMiddleCell class]) forIndexPath:indexPath];
            
            [cell fillValueWith:[UIImage imageNamed:imageArray1[indexPath.row]] and:titleArray1[indexPath.row]];
            
            return cell;
        }
            
        case 1:{
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyControllerMiddleCell class]) forIndexPath:indexPath];
            
            [cell fillValueWith:[UIImage imageNamed:imageArray2[indexPath.row]] and:titleArray2[indexPath.row]];
            
            return cell;
        }
           
    }
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0.01;
    }
    return 10;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!indexPath.row && !indexPath.section) {
        YHWorkGroupController *vc = [[YHWorkGroupController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (!indexPath.row && indexPath.section == 1){
        YHScanVC *vc = [[YHScanVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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
