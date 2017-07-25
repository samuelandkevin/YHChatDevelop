//
//  CityListController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/16.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "CityListController.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "MyAreaCell.h"
#import "MBProgressHUD.h"
#import "YHChatDevelop-Swift.h"

@interface CityListController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *provinceTableView;

@property (nonatomic, strong) UITableView *cityTableView;

@property (nonatomic, strong) NSDictionary *areaDic;

@property (nonatomic, strong) NSArray *provinceArr;

@property (nonatomic, strong) NSArray *cityArr;

@property (nonatomic, strong) YHUserInfoManager *manager;

@property (nonatomic, strong) YHUserInfo *userInfo;

@property (nonatomic, strong) MyAreaCell *didSelectProvinceCell;

@property (nonatomic, strong) MyAreaCell *didSelectCityCell;

@end

@implementation CityListController

- (void)viewDidLoad
{
	[super viewDidLoad];
	NSString *areaFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"area.plist"];
	self.areaDic = [[NSDictionary alloc] initWithContentsOfFile:areaFilePath];
    NSArray *arr = [self.areaDic allKeys];
	self.provinceArr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 localizedCaseInsensitiveCompare:obj2];
    }];

	self.view.backgroundColor = [UIColor whiteColor];

	self.manager = [YHUserInfoManager sharedInstance];
	self.userInfo = [[YHUserInfo alloc] init];
	self.provinceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
	self.cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
	self.provinceTableView.delegate = self;
	self.provinceTableView.dataSource = self;
	self.cityTableView.delegate = self;
	self.cityTableView.dataSource = self;
	self.provinceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.cityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[self.view addSubview:self.provinceTableView];
	[self.view addSubview:self.cityTableView];


    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"确定" target:self selector:@selector(save:) ];
    
	[self.provinceTableView registerClass:[MyAreaCell class] forCellReuseIdentifier:@"ProvinceCell"];
	[self.cityTableView registerClass:[MyAreaCell class] forCellReuseIdentifier:@"CityCell"];
    
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}

- (void)save:(id)sender
{
	if (self.didSelectCityCell.title.text.length == 0)
	{
		return;
	}
	NSString *total = [NSString stringWithFormat:@"%@ %@", self.didSelectProvinceCell.title.text, self.didSelectCityCell.title.text];
	self.userInfo.workCity = total;
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[[NetManager sharedInstance] postEditMyCardWithUserInfo:self.userInfo complete:^(BOOL success, id obj) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];

		if (success)
		{
			DDLog(@"修改用户信息成功");
	        //修改单例属性值
			self.manager.userInfo.workCity = self.userInfo.workCity;
			postTips(@"保存成功", nil);
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"保存失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"保存失败");
			}
		}
	}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.provinceTableView)
	{
		return [self.areaDic allKeys].count;
	}
	else
	{
		return self.cityArr ? self.cityArr.count : 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.provinceTableView)
	{
		MyAreaCell *cell = [self.provinceTableView dequeueReusableCellWithIdentifier:@"ProvinceCell" forIndexPath:indexPath];

		cell.title.text = self.provinceArr[indexPath.row];

		return cell;
	}

	if (tableView == self.cityTableView)
	{
		MyAreaCell *cell = [self.cityTableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
		cell.title.text = self.cityArr[indexPath.row];

		return cell;
	}

	return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.provinceTableView)
	{
		[self.didSelectProvinceCell notSelect];
		[self.didSelectCityCell notSelect];
		self.didSelectCityCell = [[MyAreaCell alloc] init];
		self.didSelectProvinceCell = [self.provinceTableView cellForRowAtIndexPath:indexPath];
		[self.didSelectProvinceCell provinceDidSelect];
		NSString *didSelectProvince = self.provinceArr[indexPath.row];
		self.cityArr = self.areaDic[didSelectProvince];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.cityTableView reloadData];
		});
	}

	if (tableView == self.cityTableView)
	{
		[self.didSelectCityCell notSelect];
		self.didSelectCityCell = [self.cityTableView cellForRowAtIndexPath:indexPath];
		[self.didSelectCityCell cityDidSelect];
	}
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
