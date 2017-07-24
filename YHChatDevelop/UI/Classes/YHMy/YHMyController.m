//
//  YGViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17-7-19.
//  Copyright (c) 2013年 samuelandkevin. All rights reserved.
//

#import "YHMyController.h"
//#import "QRCodeCardViewController.h"
#import "CardDetailViewController.h"
#import "MyVisitorsViewController.h"
//#import "MyAboutMeViewController.h"
#import "MySettingController.h"
//#import "MyDetailEditViewController.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
//#import "YHWorkGroupController.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"
//#import "UMMobClick/MobClick.h"

@interface YHMyHeaderModel : NSObject
@property (nonatomic,strong) NSURL *avatarUrl;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *company;
@property (nonatomic,copy) NSString *job;
@end

@implementation YHMyHeaderModel

@end

@interface YHMyController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YHMyHeaderModel *headerModel;
@property (nonatomic, strong) MyControllerHeaderCell *cellHeader;
@end

@implementation YHMyController

- (instancetype)init{
    if (self = [super init]) {
        [self _addNotification];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _headerModel = [YHMyHeaderModel new];
    [self initUI];
    
}

#pragma mark - init
- (void)initUI{
    [self setupNavigationBar];
    
    [self setupTableView];
    
}

- (void)setupTableView{
    //初始化tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MyControllerMiddleCell class] forCellReuseIdentifier:@"MyControllerMiddleCell"];
    [self.tableView registerClass:[MyControllerHeaderCell class] forCellReuseIdentifier:@"MyControllerHeaderCell"];
    
    self.tableView.backgroundColor = kTbvBGColor;
    
    //初始化HeaderCell
    _cellHeader = [[MyControllerHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyControllerHeaderCell"];
}

- (void)setupNavigationBar{
    self.navigationController.navigationBar.translucent = NO;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"my_code"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 21, 21);
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(goQrCode) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
}

#pragma mark - NSNotification
- (void)updateFont:(NSNotification *)aNotifi{
    [self.tableView removeFromSuperview];
    [self setupTableView];
    [self.tableView reloadData];
}

- (void)reloadView:(NSNotification *)sender{
    [self _setupCellHeaderData];
}

#pragma mark - Private Method
//监听通知
- (void)_addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:Event_UserInfo_UpdateFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:Event_SystemFontSize_Change object:nil];
}

//设置头部cell数据
- (void)_setupCellHeaderData{
    
    
    if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
        _headerModel.avatarUrl = nil;
        _headerModel.name      = @"未登录";
        _headerModel.company   = nil;
        _headerModel.job       = nil;
    }else{
        _headerModel.avatarUrl = [YHUserInfoManager sharedInstance].userInfo.avatarUrl;
        _headerModel.name      = [YHUserInfoManager sharedInstance].userInfo.userName;
        _headerModel.company   = [YHUserInfoManager sharedInstance].userInfo.company;
        _headerModel.job       = [YHUserInfoManager sharedInstance].userInfo.job;
    }
    
    [_cellHeader.avatar sd_setImageWithURL:_headerModel.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    [_cellHeader fillValueWith:_headerModel.name and:_headerModel.company and:_headerModel.job];
}


#pragma mark - Button Method
- (void)goQrCode
{
    if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
        [[NSNotificationCenter defaultCenter] postNotificationName:Event_notRegister_showLoginVC object:nil];
        return;
    }
    YHQRCodeCardVC *myQrCodeView = [[YHQRCodeCardVC alloc] initWithUserInfo:[YHUserInfoManager sharedInstance].userInfo];
    
    myQrCodeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myQrCodeView animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
//每个分区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section){
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

//表的分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

//头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0.01;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001; //隐藏最后一个cell底部黑线
}

//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 78;
    }else{
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const NSArray *titleArray1 = @[@"我的收藏", @"我的访客",@"我的钱包"];
    const NSArray *titleArray2 = @[@"设置", @"关于我们"];
    const NSArray *imageArray1 = @[@"my_collect",@"my_visitor",@"my_wallet"];
    const NSArray *imageArray2 = @[@"my_setting", @"my_aboutus"];
    static NSString *MyControllerMiddleCellIdentifier = @"MyControllerMiddleCell";
    
    
    switch (indexPath.section)
    {
        case 0:{
            [self _setupCellHeaderData];
            return _cellHeader;
        }
            break;
            
        case 1:{
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerMiddleCellIdentifier forIndexPath:indexPath];
            [cell fillValueWith:[UIImage imageNamed:imageArray1[indexPath.row]] and:titleArray1[indexPath.row]];
            return cell;
        }
            break;
            
        case 2:{
            
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerMiddleCellIdentifier forIndexPath:indexPath];
            [cell fillValueWith:[UIImage imageNamed:imageArray2[indexPath.row]] and:titleArray2[indexPath.row]];
            return cell;
        }
            break;
            
        default:
            return [[UITableViewCell alloc]init];
            break;
    }
}

//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    WeakSelf
    YHCellWave *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell startAnimation:^(BOOL finished) {
        if (indexPath.section == 0){
            
            if (indexPath.row == 0){
                
                DDLog(@"%@",[YHUserInfoManager sharedInstance].userInfo.avatarUrl);
                
                if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_notRegister_showLoginVC object:nil];
                    return;
                }
                
                CardDetailViewController *myCardView = [[CardDetailViewController alloc] initWithUserInfo:[YHUserInfoManager sharedInstance].userInfo];
                myCardView.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:myCardView animated:YES];
                
            }
            
        }
        
        if (indexPath.section == 1){
            
            if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
                [[NSNotificationCenter defaultCenter] postNotificationName:Event_notRegister_showLoginVC object:nil];
                return;
            }
            
            if (indexPath.row == 0){
                
//                YHMyCollectionVC *vc = [[YHMyCollectionVC alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 1){
                MyVisitorsViewController *vc = [[MyVisitorsViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 2){
                
                //跳转我的钱包
//                YHMyWalletVC *vc = [[YHMyWalletVC alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
        
        if (indexPath.section == 2){
            
            if (indexPath.row == 0){
                
                MySettingController *myAccountSetView = [[MySettingController alloc] init];
                myAccountSetView.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:myAccountSetView animated:YES];
            }else if (indexPath.row == 1){
                
//                MyAboutMeViewController *myAboutMeView = [[MyAboutMeViewController alloc] init];
//                myAboutMeView.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:myAboutMeView animated:YES];
            }
        }
        
    }];
    
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadView:nil];
  
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
