//
//  EditAccountViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/18.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "EditAccountController.h"
#import "YHNetManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "YHUserInfoManager.h"
#import "MyPasswordView.h"
#import "IQKeyboardManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

#define kFinishChangeTaxAccount 203

@interface EditAccountController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MyPasswordView *accountView;

@property (nonatomic, strong) MyPasswordView *passwordView;

@property (nonatomic, strong) UILabel *tipsLab;

@property (nonatomic, strong) UIButton *completeBtn;

@end

@implementation EditAccountController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"设置账户名称";
	self.fd_interactivePopDisabled = YES;
	[IQKeyboardManager sharedManager].enableAutoToolbar = NO;
	self.view.backgroundColor = [UIColor whiteColor];
    
	[self initAndAddSubView];
	[self setSubView];
	[self masonry];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)initAndAddSubView
{
	self.accountView = [[MyPasswordView alloc] init];
	self.passwordView = [[MyPasswordView alloc] init];
	self.tipsLab = [[UILabel alloc] init];
	self.completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];

	[self.view addSubview:self.accountView];
	[self.view addSubview:self.passwordView];
	[self.view addSubview:self.tipsLab];
	[self.view addSubview:self.completeBtn];
}

- (void)setSubView
{
	self.accountView.passwordTF.placeholder = @"账户名称由6-20位数字或英文字母组成";
	self.accountView.passwordTF.delegate = self;
	self.accountView.passwordTF.secureTextEntry = NO;

	self.passwordView.passwordTF.placeholder = @"登录密码";
    self.passwordView.passwordTF.returnKeyType = UIReturnKeyDone;
    self.passwordView.passwordTF.delegate = self;

	self.tipsLab.backgroundColor = [UIColor clearColor];
	self.tipsLab.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	self.tipsLab.font = [UIFont systemFontOfSize:13];
	self.tipsLab.numberOfLines = 2;
	self.tipsLab.textAlignment = NSTextAlignmentCenter;
	self.tipsLab.text = @"为保证您的账户安全，\n设置账户名称前需验证您的登录密码";
    
    self.completeBtn.backgroundColor = kBlueColor;
    [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeBtn setTintColor:[UIColor whiteColor]];
    self.completeBtn.layer.cornerRadius = 5;
    self.completeBtn.layer.masksToBounds = YES;
    [self.completeBtn addTarget:self action:@selector(submitAccount:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)masonry
{
	WeakSelf
	[self.accountView.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.accountView.title.mas_right);
	}];

	[self.passwordView.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.passwordView.title.mas_right);
	}];

	[self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(55);
	}];

	[self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.accountView.mas_bottom);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(55);
	}];

	[self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.passwordView.mas_bottom).offset(15);
		make.centerX.equalTo(weakSelf.view);
	}];

	[self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.tipsLab.mas_bottom).offset(37);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(40);
	}];
}

#pragma mark textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountView.passwordTF) {
        [self.passwordView.passwordTF becomeFirstResponder];
    }
    if (textField == self.passwordView.passwordTF) {
        [self submitAccount:nil];
    }
	return YES;
}

- (void)submitAccount:(id)sender
{
	[self.view endEditing:YES];
	NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
	NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];

	if (![userNamePredicate evaluateWithObject:self.accountView.passwordTF.text])
	{
		postTips(@"账户名称请输入6-20位数字或字母", nil);

		return;
	}
	NSString *string = [YHUserInfoManager sharedInstance].userInfo.taxAccount;

	if (string.length > 0 && [string isEqualToString:self.accountView.passwordTF.text])
	{
		postTips(@"新账户名称不能与旧账号名称相同,请更换账户名称", nil);
		return;
	}

	if (self.passwordView.passwordTF.text.length == 0)
	{
		postTips(@"请输入登录密码", nil);
		return;
	}

	if (!isValidePassword(self.passwordView.passwordTF.text))
	{
		postTips(@"登录密码错误,请重新输入", nil);
		return;
	}

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	[[NetManager sharedInstance] postVerifyTaxAccountExist:self.accountView.passwordTF.text complete:^(BOOL success, id obj) {
		if (success)
		{
			DDLog(@"此账号至今没人用过,可以使用");
			[[NetManager sharedInstance] postChangeTaxAccount:self.accountView.passwordTF.text passwd:self.passwordView.passwordTF.text complete:^(BOOL success, id obj) {
				[MBProgressHUD hideHUDForView:self.view animated:YES];

				if (success)
				{
					[YHUserInfoManager sharedInstance].userInfo.taxAccount = self.accountView.passwordTF.text;
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置完成" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
					alert.tag = kFinishChangeTaxAccount;
					[alert show];
				}
				else
				{
					if (isNSDictionaryClass(obj))
					{
	                    //服务器返回的错误描述
						NSString *msg = obj[kRetMsg];
						NSString *code = obj[kRetCode];

						if ([code isEqualToString:[YHError shareInstance].kErrorOldPasswd])
						{
							postTips(@"登录密码错误,请重新输入", @"修改税道号失败");
						}
						else
						{
							postTips(msg, @"修改税道号失败");
						}
					}
					else
					{
	                    //AFN请求失败的错误描述
						postTips(obj, @"修改税道号失败");
					}
				}
			}];
		}
		else
		{
			[MBProgressHUD hideHUDForView:self.view animated:YES];

			if (isNSDictionaryClass(obj))
			{
	            //服务器服务的错误描述
				NSString *code = obj[kRetCode];
				NSString *msg = obj[kRetMsg];

				if ([code isEqualToString:[YHError shareInstance].kErrorUserNameExist])
				{
					postTips(@"此账号名称已被使用，请选择其他账户名称", @"验证税道账号失败");
				}
				else
				{
					postTips(msg, @"验证税道账号失败");
				}
			}
			else
			{
	            //AFN请求失败
				postTips(obj, @"验证税道账号失败");
			}
		}
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kFinishChangeTaxAccount)
	{
		[self.view endEditing:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
