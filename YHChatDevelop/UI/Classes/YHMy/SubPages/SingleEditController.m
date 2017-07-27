//
//  SingleEditController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "SingleEditController.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "MBProgressHUD.h"
#import "YHChatDevelop-Swift.h"

@interface SingleEditController () <UITextViewDelegate>

@property (nonatomic, strong) YHUserInfoManager *manager;

@property (nonatomic, strong) YHUserInfo *userInfo;

@end

@implementation SingleEditController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.manager = [YHUserInfoManager sharedInstance];
	self.userInfo = [[YHUserInfo alloc] init];
	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];

	self.textView = [[IQTextView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 55)];
	self.textView.backgroundColor = [UIColor whiteColor];
	self.textView.placeholder = self.placeholder;
	self.textView.text = self.String;

    CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    
	self.textView.font = [UIFont systemFontOfSize:16 + fontSize];
	
//	self.textView.textContainerInset = UIEdgeInsetsMake(0, 15, 0, 15);
	self.textView.textColor = [UIColor colorWithWhite:0.557 alpha:1.000];


	[self.view addSubview:self.textView];
	self.textView.delegate = self;

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"保存" target:self selector:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountLabelWith:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.textView becomeFirstResponder];
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

}

- (void)dealloc
{
//	DDLog(@"%@ did dealloc", self);
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark button method
- (void)save:(UIButton *)btn
{
	[self.view endEditing:YES];
	//在这里改动单例的数据
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	if (self.experience == expSchool || self.experience == expMajor || self.experience == expCompany || self.experience == expPosition)
	{
		if (![self.textView.text isEqualToString:self.String])
		{
			DDLog(@"有改动");
			NSMutableArray *arr = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%ld", self.experience], self.textView.text, nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:Event_SingleVC_Value object:arr];
		}
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}

	if ([self.title isEqualToString:@"姓名"])
	{
		self.userInfo.userName = self.textView.text;
		[self postUserInfo:userName];
	}

	if ([self.title isEqualToString:@"公司"])
	{
		self.userInfo.company = self.textView.text;
		[self postUserInfo:company];
	}

	if ([self.title isEqualToString:@"职位"])
	{
		self.userInfo.job = self.textView.text;
		[self postUserInfo:position];
	}
    
    if ([self.title isEqualToString:@"部门"]){
        self.userInfo.department = self.textView.text;
        [self postUserInfo:department];
    }
}

- (BOOL)postUserInfo:(UserProperty)userProperty
{
	__block BOOL isfinish = NO;
    WeakSelf
//	DDLog(@"%@,%@", self.manager.userInfo.uid, self.manager.userInfo.accessToken);
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	[[NetManager sharedInstance] postEditMyCardWithUserInfo:self.userInfo complete:^(BOOL success, id obj) {
		isfinish = success;
		[MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

		if (success)
		{
			DDLog(@"修改用户信息成功");
	        //修改单例属性值
			switch (userProperty)
			{
				case userName:
					{
						weakSelf.manager.userInfo.userName = weakSelf.userInfo.userName;
					}
					break;

				case company:
					{
						weakSelf.manager.userInfo.company = weakSelf.userInfo.company;
					}
					break;

				case position:
					{
						weakSelf.manager.userInfo.job = weakSelf.userInfo.job;
					}
					break;
                    
                case department:
                {
                    weakSelf.manager.userInfo.department = weakSelf.userInfo.department;
                }
                    break;
				default:
					break;
			}
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
	return isfinish;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	DDLog(@"%ld,%@", range.location, text);

	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
	}

	NSString *result;

	if (textView.text.length >= range.length)
	{
		result = [textView.text stringByReplacingCharactersInRange:range withString:text];
	}

	if (result.length > 20)
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
    
//    [UIColor colorWithWhite:0.376 alpha:1.000];
//    [UIColor colorWithRed:96/255 green:96/255 blue:96/255 alpha:1.0];
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
