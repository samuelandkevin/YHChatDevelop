//
//  EditPhoneNuViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/18.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "EditPhoneController.h"
#import "YHUserInfoManager.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

@interface EditPhoneController ()

@property(nonatomic,strong) UILabel * label;

@end

@implementation EditPhoneController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = @"更换手机号";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];

	[self.view addSubview:scrollView];
	self.label = [[UILabel alloc] init];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	self.label.font = [UIFont systemFontOfSize:16];
	self.label.textAlignment = NSTextAlignmentCenter;
    
	YHUserInfoManager *manager = [YHUserInfoManager sharedInstance];
	self.label.text = [NSString stringWithFormat:@"你的手机号码:%@", manager.userInfo.mobilephone];

	[scrollView addSubview:self.label];
	[self.label mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(scrollView);
		make.top.equalTo(scrollView).offset(33);
	}];
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
	btn.backgroundColor = kBlueColor;
	[btn setTitle:@"更换手机号" forState:UIControlStateNormal];
	btn.titleLabel.font = [UIFont systemFontOfSize:16];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	btn.layer.cornerRadius = 5; //设置矩形四个圆角半径
	btn.layer.masksToBounds = YES;
	[btn addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:btn];
    WeakSelf
	[btn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(scrollView);
		make.top.equalTo(weakSelf.label.mas_bottom).offset(35);
		make.height.mas_equalTo(41);
		make.left.equalTo(scrollView).offset(15);
		make.right.equalTo(scrollView).offset(-15);
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    YHUserInfoManager *manager = [YHUserInfoManager sharedInstance];
    self.label.text = [NSString stringWithFormat:@"你的手机号码:%@",manager.userInfo.mobilephone];
}
//
////每个分区的行数
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 1;
//}
//
////表的分区数
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//
////顶部间距
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 60;
//}
//
////修改行高度的位置
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 44;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width,22.0)];
//    self.headerLabel = [[UILabel alloc] init];
//    self.headerLabel.backgroundColor = [UIColor clearColor];
//
//    self.headerLabel.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
//
//    self.headerLabel.font = [UIFont systemFontOfSize:16];
//    self.headerLabel.textAlignment = NSTextAlignmentCenter;
//    self.headerLabel.frame = CGRectMake(0, 0, tableView.frame.size.width, 60.0);
//
//    if (section == 0) {
//        YHUserInfoManager *manager = [YHUserInfoManager sharedInstance];
//        self.headerLabel.text = [NSString stringWithFormat:@"你的手机号码:%@",manager.userInfo.mobilephone];
//    }
//    [customView addSubview:self.headerLabel];
//
//    return customView;
//
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *editPhoneButtonCellIndentifer = @"editPhoneButtonCellIndentifer";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:editPhoneButtonCellIndentifer];
//
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editPhoneButtonCellIndentifer];
//    }
//
//
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = [UIColor clearColor];
//
//    _phoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _phoneButton.backgroundColor = [UIColor colorWithRed:29.0/255 green:190.0/255 blue:144.0/255 alpha:1.0];
//    [_phoneButton setTitle:@"更换手机号码" forState:UIControlStateNormal];
//    _phoneButton.frame = CGRectMake(10, 0, tableView.frame.size.width-20, 44);
//    [_phoneButton setTintColor:[UIColor whiteColor]];
//    [_phoneButton.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
//    [_phoneButton.layer setBorderWidth:0.7];//边框宽度
//    //_phoneButton.layer.borderColor=[UIColor grayColor].CGColor;
//    _phoneButton.layer.borderColor=[UIColor clearColor].CGColor;
//    [_phoneButton addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
//    [cell.contentView addSubview:_phoneButton];
//    return  cell;
//}
//
- (void)butClick
{
    VerificationNuViewController *verificationNuView = [[VerificationNuViewController alloc] init];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:verificationNuView animated:YES];
//	UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"更换手机号码？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

//	[view show];
}

#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//DDLog(@"clickButtonAtIndex:%ld",(long)buttonIndex);
	if (buttonIndex == 1)
	{
		VerificationNuViewController *verificationNuView = [[VerificationNuViewController alloc] init];
		UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
		self.navigationItem.backBarButtonItem = barButtonItem;
		[self.navigationController pushViewController:verificationNuView animated:YES];
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
