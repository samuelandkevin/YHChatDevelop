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
//#import "MySettingController.h"
//#import "MyDetailEditViewController.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
//#import "YHWorkGroupController.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"
//#import "UMMobClick/MobClick.h"

@interface YHMyController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSURL * avatarURL;
@property (nonatomic, assign) BOOL isInitialize;

@end

@implementation YHMyController

- (void)viewDidLoad
{
    [super viewDidLoad];

	if ([YHUserInfoManager sharedInstance].userInfo.updateStatus != updateFinish || [YHUserInfoManager sharedInstance].userInfo == nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:Event_UserInfo_UpdateFinish object:nil];
        
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:Event_SystemFontSize_Change object:nil];
	self.navigationController.navigationBar.translucent = NO;
    [self setupNavigationBar];
    [self initUI];
    
}

- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset  = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[MyControllerMiddleCell class] forCellReuseIdentifier:@"MyControllerMiddleCell"];
    [self.tableView registerClass:[MyControllerHeaderCell class] forCellReuseIdentifier:@"MyControllerHeaderCell"];
    
    self.tableView.backgroundColor = kTbvBGColor;
}

- (void)setupNavigationBar{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"my_code"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 21, 21);
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(goQrCode) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:Event_UserInfo_UpdateFinish object:nil];
}

#pragma mark notification
- (void)updateFont:(NSNotification *)aNotifi{
    [self.tableView removeFromSuperview];
    [self initUI];
    [self.tableView reloadData];
}

- (void)reloadView:(NSNotification *)sender
{
	if ([YHUserInfoManager sharedInstance].userInfo == nil)
	{
		return;
	}
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    MyControllerHeaderCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell fillValueWith:[YHUserInfoManager sharedInstance].userInfo.userName and:[YHUserInfoManager sharedInstance].userInfo.company and:[YHUserInfoManager sharedInstance].userInfo.job];
    if ([YHUserInfoManager sharedInstance].userInfo.avatarUrl && self.avatarURL &&  self.avatarURL != [YHUserInfoManager sharedInstance].userInfo.avatarUrl) {
        [cell.avatar sd_setImageWithURL:[YHUserInfoManager sharedInstance].userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed | SDWebImageProgressiveDownload | SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error == nil)
            {
                cell.avatar.image = image;
                self.avatarURL = [YHUserInfoManager sharedInstance].userInfo.avatarUrl;
            }
            else
            {
                DDLog(@"%@", error.description);
            }
        }];
    }
}

#pragma mark button method
- (void)goQrCode
{
	YHQRCodeCardVC *myQrCodeView = [[YHQRCodeCardVC alloc] initWithUserInfo:[YHUserInfoManager sharedInstance].userInfo];

	myQrCodeView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:myQrCodeView animated:YES];
}

#pragma mark tableView delegate & dataSource
//每个分区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//DDLog(@"--->%ld",(long)section);
	// return section == 1?[_contentArray count]:1;
	switch (section)
	{
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

//头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 0.01;
	}
	return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.001; //隐藏最后一个cell底部黑线
}

//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		return 78;
	}
	else
	{
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
    
    static NSString *MyControllerHeaderCellIdentifier = @"MyControllerHeaderCell";
    
	switch (indexPath.section)
	{
		case 0:
		{
            MyControllerHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerHeaderCellIdentifier forIndexPath:indexPath];

			if ([YHUserInfoManager sharedInstance].userInfo.avatarUrl)
			{
				[cell.avatar sd_setImageWithURL:[YHUserInfoManager sharedInstance].userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed | SDWebImageProgressiveDownload | SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
					if (error == nil)
					{
                        cell.avatar.image = image;
                        self.avatarURL = [YHUserInfoManager sharedInstance].userInfo.avatarUrl;
                    }
					else
					{
						DDLog(@"%@", error.description);
					}
				}];
			}
            
            [cell fillValueWith:[YHUserInfoManager sharedInstance].userInfo.userName and:[YHUserInfoManager sharedInstance].userInfo.company and:[YHUserInfoManager sharedInstance].userInfo.job];

			return cell;
		}
		break;

		case 1:
		{
            
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerMiddleCellIdentifier forIndexPath:indexPath];
            
            [cell fillValueWith:[UIImage imageNamed:imageArray1[indexPath.row]] and:titleArray1[indexPath.row]];
            
			return cell;
		}
		break;

		case 2:
		{
            
            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerMiddleCellIdentifier forIndexPath:indexPath];

            [cell fillValueWith:[UIImage imageNamed:imageArray2[indexPath.row]] and:titleArray2[indexPath.row]];

			return cell;
		}
		break;
            
//        case 3:
//        {
//            MyControllerMiddleCell *cell = [tableView dequeueReusableCellWithIdentifier:MyControllerMiddleCellIdentifier forIndexPath:indexPath];
//
//            [cell fillValueWith:[UIImage imageNamed:imageArray3[indexPath.row]] and:titleArray3[indexPath.row]];
//
//            return cell;
//        }
//            break;

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
        if (indexPath.section == 0)
        {
            
            if (indexPath.row == 0)
            {
                DDLog(@"%@",[YHUserInfoManager sharedInstance].userInfo.avatarUrl);
//                YHWorkGroupController *vc = [YHWorkGroupController new];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
                CardDetailViewController *myCardView = [[CardDetailViewController alloc] initWithUserInfo:[YHUserInfoManager sharedInstance].userInfo];
                myCardView.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:myCardView animated:YES];
                
            }
            
        }
        
        if (indexPath.section == 1)
        {
            
            if (indexPath.row == 0)
            {
//                YHMyCollectionVC *vc = [[YHMyCollectionVC alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
            
            if (indexPath.row == 1)
            {
                MyVisitorsViewController *vc = [[MyVisitorsViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
            if (indexPath.row == 2)
            {
                //跳转我的钱包
//                YHMyWalletVC *vc = [[YHMyWalletVC alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
        
        if (indexPath.section == 2)
        {
            if (indexPath.row == 0)
            {
//                MySettingController *myAccountSetView = [[MySettingController alloc] init];
//                myAccountSetView.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:myAccountSetView animated:YES];
            }
            
            if (indexPath.row == 1)
            {
//                MyAboutMeViewController *myAboutMeView = [[MyAboutMeViewController alloc] init];
//                myAboutMeView.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:myAboutMeView animated:YES];
            }
        }
        
    }];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadView:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
