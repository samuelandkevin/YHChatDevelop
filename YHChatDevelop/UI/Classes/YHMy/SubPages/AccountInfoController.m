//
//  MyAccountSetEditViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/14.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "AccountInfoController.h"
#import "YHUserInfoManager.h"
#import "MySettingCommonCell.h"
#import "YHChatDevelop-Swift.h"

@interface AccountInfoController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AccountInfoController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = @"我的账号";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
	self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	[self.view addSubview:self.tableView];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 45;
	[self.tableView registerClass:[MySettingCommonCell class] forCellReuseIdentifier:@"MySettingCommonCell"];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//每个分区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
	view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	return view;
}

//表的分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MySettingCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MySettingCommonCell"];
	NSArray *arr = @[@"手机号码:", @"账号:", @"修改密码:"];

	NSUInteger row = [indexPath row];

	cell.title.text = arr[row];

	if (row == 0)
	{
		cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.mobilephone;
		cell.line.hidden = NO;
	}

	if (row == 1)
	{
		cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.taxAccount;
		cell.line.hidden = NO;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	if (indexPath.row == 0)
	{
		EditPhoneController *editPhoneNuView = [[EditPhoneController alloc] init];

		[self.navigationController pushViewController:editPhoneNuView animated:YES];
	}

	if (indexPath.row == 1)
	{
		if ([YHUserInfoManager sharedInstance].userInfo.taxAccount.length > 0)
		{
            postTips(@"税道账号不允许修改",nil);
			return;
		}

		EditAccountController *editAccountView = [[EditAccountController alloc] init];

		[self.navigationController pushViewController:editAccountView animated:YES];
	}

	if (indexPath.row == 2)
	{
		EditPasswordController *editPwdView = [[EditPasswordController alloc] init];
		UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
		self.navigationItem.backBarButtonItem = barButtonItem;
		[self.navigationController pushViewController:editPwdView animated:YES];
	}
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
