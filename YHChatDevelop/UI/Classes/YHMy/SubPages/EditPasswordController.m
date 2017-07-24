//
//  EditPwdViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/14.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "EditPasswordController.h"
#import "YHNetManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "MyPasswordView.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQKeyboardManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

#define kFinishChangePassword 202
@interface EditPasswordController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MyPasswordView *oldPassword;

@property (nonatomic, strong) MyPasswordView *password;

@property (nonatomic, strong) MyPasswordView *confirmPassword;

@property (nonatomic, strong) UILabel *tipsLab;

@end

@implementation EditPasswordController

- (void)initAndAddSubView
{
	self.oldPassword = [[MyPasswordView alloc] init];
	self.password = [[MyPasswordView alloc] init];
	self.confirmPassword = [[MyPasswordView alloc] init];
	self.tipsLab = [[UILabel alloc] init];
	self.completeButton = [UIButton buttonWithType:UIButtonTypeSystem];

	[self.view addSubview:self.oldPassword];
	[self.view addSubview:self.password];
	[self.view addSubview:self.confirmPassword];
	[self.view addSubview:self.tipsLab];
	[self.view addSubview:self.completeButton];
}

- (void)setSubView
{
	self.oldPassword.bottomline.hidden = YES;
	self.oldPassword.passwordTF.delegate = self;
	self.oldPassword.passwordTF.placeholder = @"原始密码";

	self.password.bottomline.hidden = YES;
	self.password.passwordTF.delegate = self;
	self.password.passwordTF.placeholder = @"新密码";

	self.confirmPassword.passwordTF.returnKeyType = UIReturnKeyDone;
	self.confirmPassword.passwordTF.delegate = self;
	self.confirmPassword.passwordTF.placeholder = @"确认新密码";

	self.tipsLab.font = [UIFont systemFontOfSize:13];
	self.tipsLab.numberOfLines = 2;
	self.tipsLab.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	self.tipsLab.textAlignment = NSTextAlignmentCenter;
	self.tipsLab.text = @"登录密码由6-20位字符组合，\n更改密码后请妥善保管密码。";

	self.completeButton.backgroundColor = kBlueColor;
	[self.completeButton setTitle:@"完成" forState:UIControlStateNormal];
	[self.completeButton setTintColor:[UIColor whiteColor]];
	self.completeButton.layer.cornerRadius = 5;
	self.completeButton.layer.masksToBounds = YES;
	[self.completeButton addTarget:self action:@selector(submitPassword:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)masonry
{
	WeakSelf
	[self.oldPassword.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.oldPassword.title.mas_right);
	}];

	[self.oldPassword mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(55);
		make.top.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
	}];

	[self.password.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.password.title.mas_right);
	}];

	[self.password mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(55);
		make.top.equalTo(weakSelf.oldPassword.mas_bottom);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
	}];
	[self.confirmPassword.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.confirmPassword.title.mas_right);
	}];
	[self.confirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(55);
		make.top.equalTo(weakSelf.password.mas_bottom);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
	}];

	[self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.confirmPassword.mas_bottom).offset(15);
		make.centerX.equalTo(weakSelf.view);
	}];

	[self.completeButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(40);
		make.top.equalTo(weakSelf.tipsLab.mas_bottom).offset(38);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
	}];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[IQKeyboardManager sharedManager].enableAutoToolbar = NO;
	self.title = @"更改密码";
	self.fd_interactivePopDisabled = YES;
	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
	[self initAndAddSubView];
	[self setSubView];
	[self masonry];
}

- (void)dealloc
{
	DDLog(@"%@ did dealloc", self);
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)submitPassword:(id)sender
{
	[self.view endEditing:YES];

    
    if (!isValidePassword(self.oldPassword.passwordTF.text)) {
        postTips(@"原始密码请输入6-20位数字或字符", nil);
        return;
    }
    
	if (!isValidePassword(self.password.passwordTF.text) || !isValidePassword(self.confirmPassword.passwordTF.text))
	{
		postTips(@"新密码请输入6-20位数字或字符", nil);
		return;
	}

	if (![self.password.passwordTF.text isEqualToString:self.confirmPassword.passwordTF.text])
	{
		postTips(@"两次输入的新密码不一致,请重新输入", nil);
		return;
	}

	if ([self.oldPassword.passwordTF.text isEqualToString:self.password.passwordTF.text])
	{
		postTips(@"新密码不能与原始密码一致", nil);
		return;
	}

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[[NetManager sharedInstance] postModifyPasswd:self.password.passwordTF.text oldPasswd:self.oldPassword.passwordTF.text complete:^(BOOL success, id obj) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];

		if (success)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改密码成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
			alertView.tag = kFinishChangePassword;
			[alertView show];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误
				NSString *code = obj[kRetCode];
				NSString *msg = obj[kRetMsg];

				if ([code isEqualToString:[YHError shareInstance].kErrorOldPasswd])
				{
					postTips(@"原始密码输入错误,请重新输入", nil);
				}
				else
				{
	                //其他错误
					postTips(msg, @"修改密码失败");
				}
			}
			else
			{
	            //AFN请求失败
				postTips(obj, @"修改密码失败");
			}
		}
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kFinishChangePassword)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
}

//限制字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *result;

	if (textField.text.length >= range.length)
	{
		result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}

	if (result.length > 20)
	{
		return NO;
	}
	return YES;
}

//键盘往下收的方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.oldPassword.passwordTF)
	{
		[self.password.passwordTF becomeFirstResponder];
	}

	if (textField == self.password.passwordTF)
	{
		[self.confirmPassword.passwordTF becomeFirstResponder];
	}

	if (textField == self.confirmPassword.passwordTF)
	{
		[self submitPassword:nil];
	}

	return YES;
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
