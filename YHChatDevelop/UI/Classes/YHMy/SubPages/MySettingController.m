//
//  MyAccountSetController.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/4/13.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "MySettingController.h"
#import "YHNetManager.h"
#import "YHUserInfoManager.h"
#import "MySettingCommonCell.h"
#import "YHChatDevelop-Swift.h"
#import "YHAnimatedBtn.h"
#import "MBProgressHUD.h"

@interface MySettingController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YHAnimatedBtn *viewLogout;

@end

@implementation MySettingController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateButtonTitle) name:Event_Login_Success object:nil];
    [self initUI];
}

- (void)initUI{
    //navigation
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    self.title = @"设置";
    self.view.backgroundColor =kTbvBGColor;
    
    
    //tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MySettingCommonCell class] forCellReuseIdentifier:@"MySettingCommonCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kTbvBGColor;
    
    //btn
    WeakSelf
    _viewLogout = [[YHAnimatedBtn alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT - 70 - 64, SCREEN_WIDTH - 30, 40)];
    [self _updateButtonTitle];
    [_viewLogout setSelected];
    _viewLogout.onLoginBlock = ^{
        
        if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_notRegister_showLoginVC object:nil];
            return;
        }
        
        [weakSelf completeEidtPwd];
    };
    [self.tableView addSubview:_viewLogout];
    
    
}

#pragma mark - @protocol UITableViewDataSource
//每个分区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *arr = @[@"账号信息",
                     @"字体大小",
                     @"清理缓存"];

	MySettingCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MySettingCommonCell"];

	cell.title.text = arr[indexPath.row];

    if (indexPath.row == 0 || indexPath.row == 1){
        cell.line.hidden = NO;
    }else{
        cell.line.hidden = YES;
    }
    
    if (indexPath.row == 2) {
        cell.arrow.hidden = YES;
    }else{
        cell.arrow.hidden = NO;
    }
	return cell;
}

#pragma mark - @protocol UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0){
        
        if(![YHUserInfoManager sharedInstance].userInfo.isRegister){
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_notRegister_showLoginVC object:nil];
            return;
        }
        
		AccountInfoController *myAccountSetEditView = [[AccountInfoController alloc] init];
		[self.navigationController pushViewController:myAccountSetEditView animated:YES];
	}else if (indexPath.row == 1) {

        FontSizeController *vc = [[FontSizeController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        WeakSelf
        [YHAlertView showWithTitle:@"清理缓存" message:@"确定清理缓存？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if(buttonIndex == 1){
                DDLog(@"确定清理");
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    postTips(@"清理完成", nil);
                });
            }
        }];
    }
}

- (void)completeEidtPwd
{
    WeakSelf
    [YHAlertView showWithTitle:@"确定退出？" message:nil cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            [weakSelf.viewLogout showLoadingComplete:^{
                
                [[NetManager sharedInstance] postLogoutComplete:^(BOOL success, id obj) {
                    [weakSelf.viewLogout hideLoading];
                    
                    [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                    
                    [[YHUserInfoManager sharedInstance] logout];
                    
                }];
            }];
            
        }

    }];


}

#pragma mark - Private Method
- (void)_updateButtonTitle{
    NSString *aTitle = [YHUserInfoManager sharedInstance].userInfo.isRegister? @"退出登录":@"登录";
    _viewLogout.title = aTitle;
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Life
- (void)dealloc{
    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
