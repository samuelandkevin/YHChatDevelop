//
//  ChangePhoneNuViewController.m
//  CustomTableViewCell
//
//  Created by 许亚军 on 16/4/22.
//  Copyright © 2016年 atany. All rights reserved.
//

#import "ChangePhoneNuViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "YHUserInfoManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "YHNetManager.h"
#import "AccountInfoController.h"
#import "MyPasswordView.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

#define kFinishChangePhoneNumber	 201
@interface ChangePhoneNuViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) MyPasswordView *phoneNumberView;

@property (nonatomic, strong) MyPasswordView *qrCodeView;

@property (strong, nonatomic) UIButton *nextStepBtn;

@property (nonatomic, assign) NSInteger totalTime;

@property (nonatomic, strong) NSTimer *countDownTimer;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ChangePhoneNuViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"更换手机号";
	self.view.backgroundColor = [UIColor whiteColor];
	self.fd_interactivePopDisabled = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];

	self.phoneNumberView = [[MyPasswordView alloc] init];
	self.qrCodeView = [[MyPasswordView alloc] init];
	UILabel *headerLabel = [[UILabel alloc] init];
	self.nextStepBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	self.hud = [[MBProgressHUD alloc] initWithView:self.view];

	[self.view addSubview:self.phoneNumberView];
	[self.view addSubview:self.qrCodeView];
	[self.view addSubview:headerLabel];
	[self.view addSubview:self.nextStepBtn];
	[self.view addSubview:self.hud];

	self.phoneNumberView.passwordTF.delegate = self;

	WeakSelf
	//
	[self.phoneNumberView.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.phoneNumberView.title.mas_right);
	}];
	[self.phoneNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(55);
	}];
	self.phoneNumberView.passwordTF.placeholder = @"手机号码 仅支持大陆手机";
	self.phoneNumberView.passwordTF.secureTextEntry = NO;

	[self.qrCodeView.passwordTF mas_updateConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(weakSelf.qrCodeView.title.mas_right);
	}];
	[self.qrCodeView.btn mas_updateConstraints:^(MASConstraintMaker *make) {
		make.width.mas_equalTo(117);
		make.height.mas_equalTo(38);
		make.right.equalTo(weakSelf.qrCodeView.mas_right).offset(-15);
	}];

	[self.qrCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.phoneNumberView.mas_bottom);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(55);
	}];
	self.qrCodeView.passwordTF.placeholder = @"验证码";
	self.qrCodeView.passwordTF.secureTextEntry = NO;
	self.qrCodeView.passwordTF.returnKeyType = UIReturnKeyDone;
	self.qrCodeView.passwordTF.delegate = self;

	self.qrCodeView.btn.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];

	[self.qrCodeView.btn setTitle:@"发送验证码" forState:UIControlStateNormal];
	self.qrCodeView.btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
	self.qrCodeView.btn.tintColor = [UIColor whiteColor];
	self.qrCodeView.btn.userInteractionEnabled = NO;
	[self.qrCodeView.btn addTarget:self action:@selector(tryToGetQrCode:) forControlEvents:UIControlEventTouchUpInside];
	//

	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	headerLabel.font = [UIFont systemFontOfSize:13];
	headerLabel.numberOfLines = 1;
	headerLabel.textAlignment = NSTextAlignmentCenter;
	headerLabel.text = @"你的手机号码仅限于验证身份，我们会严格保密";
	[headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.qrCodeView.mas_bottom).offset(15);
		make.centerX.equalTo(weakSelf.view);
	}];

	[self.nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(headerLabel.mas_bottom).offset(37);
		make.left.equalTo(weakSelf.view).offset(15);
		make.right.equalTo(weakSelf.view).offset(-15);
		make.height.mas_equalTo(40);
	}];

	self.nextStepBtn.backgroundColor = kBlueColor;
	[self.nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
	[self.nextStepBtn setTintColor:[UIColor whiteColor]];
	self.nextStepBtn.layer.cornerRadius = 5;
	self.nextStepBtn.layer.masksToBounds = YES;
	[self.nextStepBtn addTarget:self action:@selector(submitPhoneAndQrCode:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.phoneNumberView.passwordTF becomeFirstResponder];
}

- (void)dealloc
{
	DDLog(@"%@ did dealloc", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[self.view endEditing:YES];

	if (self.countDownTimer != nil)
	{
		[self.countDownTimer invalidate];
	}
}

- (void)tryToGetQrCode:(id)sender
{
	[self.view endEditing:YES];
	DDLog(@"tryToGetQrCode");

	if (!isValidePhoneFormat(self.phoneNumberView.passwordTF.text))
	{
		postTips(@"手机号码格式不正确,请重新输入", nil);
		return;
	}

	[self.hud showAnimated:YES];
	WeakSelf
	[[NetManager sharedInstance] getVerifyphoneNum: self.phoneNumberView.passwordTF.text complete:^(BOOL success, id obj) {
		if (success)
		{
	        //记录成功发送验证码的手机号
			[weakSelf getQrCode];
		}
		else
		{
			[weakSelf.hud hide:YES];
			postTips(@"该手机号在税道已被绑定,请更换其他手机号", nil);
		}
	}];
}

/**
 *  向MobSDK获取手机验证码
 */
- (void)getQrCode
{
    DDLog(@"getQrCode");
	WeakSelf
	[SMSSDK getVerificationCodeByMethod: SMSGetCodeMethodSMS phoneNumber: self.phoneNumberView.passwordTF.text zone: @"86" customIdentifier: nil result:^(NSError *error)
	{
		if (!error)
		{
			postHUDTips([NSString stringWithFormat:@"验证码已经发送到%@的手机", weakSelf.phoneNumberView.passwordTF.text], weakSelf.view);
//			DDLog(@"%@", [NSThread currentThread]);
			[weakSelf refuseToClick:YES];
			[weakSelf startTime];

			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:@"0" forKey:kVerificationCode_WrongCount];
		}
		else
		{
			[weakSelf.hud hide:YES];
            postTips([NSString stringWithFormat:@"获取验证码失败,%@", error.userInfo[@"getVerificationCode"]?error.userInfo[@"getVerificationCode"]:@""], nil);
		}
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kFinishChangePhoneNumber)
	{
		for (UIViewController *vc in self.navigationController.viewControllers)
		{
			if ([vc isKindOfClass:[AccountInfoController class]])
			{
				[self.navigationController popToViewController:vc animated:YES];
			}
		}
	}
}

- (void)refuseToClick:(BOOL)yesOrNo
{
	if (yesOrNo)
	{
		[self.qrCodeView.btn setTitle:[NSString stringWithFormat:@"60秒重新发送"] forState:UIControlStateNormal];
		self.qrCodeView.btn.userInteractionEnabled = NO;
		self.qrCodeView.btn.backgroundColor = [UIColor grayColor];

		self.phoneNumberView.passwordTF.userInteractionEnabled = NO;
		self.phoneNumberView.passwordTF.textColor = [UIColor grayColor];
	}
	else
	{
		[self.qrCodeView.btn setTitle:@"发送验证码" forState:UIControlStateNormal];
		self.qrCodeView.btn.userInteractionEnabled = YES;
		self.qrCodeView.btn.backgroundColor = [UIColor colorWithRed:29.0 / 255 green:190.0 / 255 blue:144.0 / 255 alpha:1.0];

		self.phoneNumberView.passwordTF.textColor = [UIColor blackColor];
		self.phoneNumberView.passwordTF.userInteractionEnabled = YES;
	}
}

- (void)startTime
{
	self.totalTime = 59;

	if (self.countDownTimer == nil)
	{
		self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDone) userInfo:nil repeats:YES];

		//		self.countDownTimer = [NSTimer timerWithTimeInterval:1 target:ws selector:@selector(timerDone) userInfo:nil repeats:YES];
	}
//	[[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];

//	[[NSRunLoop currentRunLoop] run];
}

- (void)timerDone
{

	DDLog(@"%@", [NSThread currentThread]);

	if (self.totalTime > 0)
	{
		NSString *strTime = [NSString stringWithFormat:@"%ld", self.totalTime];
		[self.qrCodeView.btn setTitle:[NSString stringWithFormat:@"%@秒重新发送", strTime] forState:UIControlStateNormal];
		self.totalTime--;
		[self.hud hideAnimated:YES];
	}
	else
	{
		[self.countDownTimer invalidate];
		[self refuseToClick:NO];
	}

}

- (void)submitPhoneAndQrCode:(id)sender
{
	[self.view endEditing:YES];

	if (self.phoneNumberView.passwordTF.text.length == 0)
	{
		postTips(@"请输入手机号码", nil);
		return;
	}

	if (self.qrCodeView.passwordTF.text.length == 0)
	{
		postTips(@"请输入验证码", nil);
		return;
	}

	if (!isValidePhoneFormat(self.phoneNumberView.passwordTF.text))
	{
		postTips(@"手机号码格式不正确,请重新输入", nil);
		return;
	}
    NSInteger count = 0;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kVerificationCode_WrongCount]) {
        count = [[defaults objectForKey:kVerificationCode_WrongCount] integerValue];
        
        if (count >= 3)
        {
            postTips(@"验证码输入错误三次，请重新获取", nil);
            return;
        }
    }

	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[[NetManager sharedInstance] postChangePhoneNum:self.phoneNumberView.passwordTF.text verifyCode:self.qrCodeView.passwordTF.text complete:^(BOOL success, id obj) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];

		if (success)
		{
			[YHUserInfoManager sharedInstance].userInfo.mobilephone = self.phoneNumberView.passwordTF.text;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更换手机号成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			alert.tag = kFinishChangePhoneNumber;

			[alert show];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];
				NSString *code = obj[kRetCode];

				if ([code isEqualToString:[YHError shareInstance].kErrorVerifyCode])
				{
					postTips(@"验证码错误,请重新输入", nil);

					if ([defaults objectForKey:kVerificationCode_WrongCount])
					{
						NSInteger count = [[defaults objectForKey:kVerificationCode_WrongCount] integerValue];
						count++;
						[defaults setObject:[NSString stringWithFormat:@"%ld", count] forKey:kVerificationCode_WrongCount];
					}
					else
					{
						[defaults setObject:@"1" forKey:kVerificationCode_WrongCount];
					}
				}
				else
				{
					postTips(msg, @"更换手机号失败");
				}
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"更换手机号失败");
			}
		}
	}];
}

#pragma mark textField delegate
- (void)textFieldChange:(NSNotification *)sender
{
	if (self.phoneNumberView.passwordTF.text.length == 11 && sender.object == self.phoneNumberView.passwordTF)
	{
		self.qrCodeView.btn.userInteractionEnabled = YES;
		self.qrCodeView.btn.backgroundColor = [UIColor colorWithRed:29.0 / 255 green:190.0 / 255 blue:144.0 / 255 alpha:1.0];
	}

	if (self.phoneNumberView.passwordTF.text.length != 11)
	{
		self.qrCodeView.btn.userInteractionEnabled = NO;
		self.qrCodeView.btn.backgroundColor = [UIColor grayColor];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.phoneNumberView.passwordTF)
	{
		[self.qrCodeView.passwordTF becomeFirstResponder];
	}

	if (textField == self.qrCodeView.passwordTF)
	{
		[self submitPhoneAndQrCode:nil];
	}

	return YES;
}

//限制字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	//计算剩下多少文字可以输入
	NSString *result;

	if (textField.text.length >= range.length)
	{
		result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}

	if (result.length > 11)
	{
		return NO;
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
