//
//  VerificationNuViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/22.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "VerificationNuViewController.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "MyPasswordView.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

@interface VerificationNuViewController ()

@property (nonatomic, strong) UIImageView *eyeView;
@property (strong, nonatomic) UIButton *eyeBtn;
@property (strong, nonatomic) UIButton *nextButton;
@property (nonatomic, strong) MyPasswordView *passwordView;

@end

@implementation VerificationNuViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"验证登录";
	self.fd_interactivePopDisabled = YES;
	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
	//创建
	self.passwordView = [[MyPasswordView alloc] init];
	self.eyeBtn = [[UIButton alloc] init];
	self.eyeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_img_hiddenCode"] highlightedImage:[UIImage imageNamed:@"login_img_showCode"]];
	UILabel *label = [[UILabel alloc] init];
	self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];

	//加入
	[self.view addSubview:self.passwordView];
	[self.view addSubview:self.eyeBtn];
	[self.view addSubview:self.eyeView];
	[self.view addSubview:label];
	[self.view addSubview:self.nextButton];

	self.passwordView.rightline.hidden = YES;
//	self.passwordView.title.text = @"请输入登录密码";
	self.passwordView.passwordTF.placeholder = @"请输入登录密码";
    self.passwordView.passwordTF.delegate = self;
    self.passwordView.passwordTF.returnKeyType = UIReturnKeyDone;
	WeakSelf
	[self.passwordView.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.passwordView.title.mas_right);
	}];

	[self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.eyeBtn.mas_left);
		make.height.mas_equalTo(55);
	}];

	[self.eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(weakSelf.view).offset(-15);
		make.centerY.equalTo(weakSelf.passwordView);
		make.height.width.mas_equalTo(55);
	}];
	self.eyeBtn.backgroundColor = [UIColor whiteColor];
	[self.eyeBtn addTarget:self action:@selector(isSecureEntry:) forControlEvents:UIControlEventTouchUpInside];

	[self.eyeView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.height.mas_equalTo(21);
		make.center.equalTo(weakSelf.eyeBtn);
	}];

	label.font = [UIFont systemFontOfSize:13];
	label.numberOfLines = 2;
	label.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = @"为保证您的账户安全，\n更改手机号码需要验证登录密码";
	[label mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.passwordView.mas_bottom).offset(15);
		make.centerX.equalTo(weakSelf.view);
	}];

	UIView *topline = [[UIView alloc] init];
	UIView *rightline = [[UIView alloc] init];
	UIView *bottomline = [[UIView alloc] init];

	[self.view addSubview:topline];
	[self.view addSubview:rightline];
	[self.view addSubview:bottomline];

	topline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
	bottomline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
	rightline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];

	[topline mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(0.5);
		make.top.left.right.equalTo(weakSelf.eyeBtn);
	}];

	[bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(0.5);
		make.bottom.left.right.equalTo(weakSelf.eyeBtn);
	}];

	[rightline mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.mas_equalTo(0.5);
		make.bottom.top.right.equalTo(weakSelf.eyeBtn);
	}];

	self.nextButton.backgroundColor = kBlueColor;
	[self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
	[self.nextButton setTintColor:[UIColor whiteColor]];
	self.nextButton.layer.cornerRadius = 5;
	self.nextButton.layer.masksToBounds = YES;
    [self.nextButton addTarget:self action:@selector(submitPassword:) forControlEvents:UIControlEventTouchUpInside];

	[self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(40);
		make.top.equalTo(label.mas_bottom).offset(38);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
	}];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.passwordView.passwordTF becomeFirstResponder];
}

- (void)isSecureEntry:(UIButton *)button
{
	button.selected = !button.selected;
	self.eyeView.highlighted = !self.eyeView.highlighted;

	if (button.selected)
	{
		self.passwordView.passwordTF.secureTextEntry = NO;
		NSString *text = self.passwordView.passwordTF.text;
		self.passwordView.passwordTF.text = @" ";
		self.passwordView.passwordTF.text = text;
	}
	else
	{
		self.passwordView.passwordTF.secureTextEntry = YES;
		NSString *text = self.passwordView.passwordTF.text;
		self.passwordView.passwordTF.text = @" ";
		self.passwordView.passwordTF.text = text;
	}
}

#pragma mark textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submitPassword:nil];
	return YES;
}

- (void)submitPassword:(id)sender
{
    [self.view endEditing:YES];
    if (self.passwordView.passwordTF.text.length == 0) {
        postTips(@"请输入登录密码", nil);
        return;
    }
    
	if (!isValidePassword(self.passwordView.passwordTF.text))
	{
        postTips(@"密码错误，请重新输入", nil);
		return;
	}

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[self.view endEditing:YES];
	[[NetManager sharedInstance] postValidateOldPasswd:self.passwordView.passwordTF.text complete:^(BOOL success, id obj) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];

		if (success)
		{
			ChangePhoneNuViewController *changePhoneNuView = [[ChangePhoneNuViewController alloc] init];
			[self.navigationController pushViewController:changePhoneNuView animated:YES];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述

				NSString *code = obj[kRetCode];
				NSString *msg  = obj[kRetMsg];

				if ([code isEqualToString:[YHError shareInstance].kErrorOldPasswd])
				{
					msg = @"密码错误，请重新输入";
				}
				postTips(msg, @"验证旧密码失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"验证旧密码失败");
			}
		}
	}];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
