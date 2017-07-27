//
//  IntroduceEditController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "IntroduceEditController.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "IQKeyboardManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

@interface IntroduceEditController () <UITextViewDelegate>

@property (nonatomic, strong) UILabel *count;

@end

@implementation IntroduceEditController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	self.textView = [[IQTextView alloc] initWithFrame:CGRectMake(18, 12, SCREEN_WIDTH - 36, 200)];
	self.textView.placeholder = @"个人简介不能超过30个字";

	self.textView.text = self.string;
	self.textView.backgroundColor = [UIColor whiteColor];
//	self.textView.placeholderTextColor = [UIColor colorWithWhite:0.686 alpha:1.000];
//	self.textView.placeholderFont = [UIFont systemFontOfSize:16];
	self.textView.font = [UIFont systemFontOfSize:16];
	self.textView.textColor = [UIColor colorWithWhite:0.557 alpha:1.000];
	self.textView.layer.cornerRadius = 10;
	self.textView.layer.masksToBounds = YES;
	self.textView.layer.borderColor = kBlueColor.CGColor;
	self.textView.layer.borderWidth = 1;
	self.textView.delegate = self;
	[self.view addSubview:self.textView];

	self.count = [[UILabel alloc] init];
	self.count.textColor = [UIColor colorWithWhite:0.686 alpha:1.000];
	self.count.font = [UIFont systemFontOfSize:11];
    NSInteger count = 30 - self.textView.text.length;
    self.count.text = [NSString stringWithFormat:@"%ld", count];
    
	[self.view addSubview:self.count];
	WeakSelf
	[self.count mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(weakSelf.textView.mas_right).offset(-12);
		make.bottom.equalTo(weakSelf.textView.mas_bottom).offset(-12);
	}];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"保存" target:self selector:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountLabelWith:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

-(void)changeCountLabelWith:(NSNotification *)notif{
    
    IQTextView *textView = (IQTextView *)notif.object;
    
    NSInteger kMaxLength = 30;
    
    NSString *toBeString = textView.text;
    NSString *lang = [[textView textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        if (!position) {
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
            NSInteger count = 30 - textView.text.length;
            self.count.text = [NSString stringWithFormat:@"%ld", count];
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
        NSInteger count = 30 - textView.text.length;
        self.count.text = [NSString stringWithFormat:@"%ld", count];
    }
}

#pragma mark button method
- (void)save:(UIButton *)btn
{
	//在这里改动单例的数据
    [self.textView resignFirstResponder];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	YHUserInfo *userInfo = [[YHUserInfo alloc] init];
	userInfo.intro = self.textView.text;
	[[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
		[MBProgressHUD hideHUDForView:self.view animated:YES];

		if (success)
		{
			[YHUserInfoManager sharedInstance].userInfo.intro = self.textView.text;
            postTips(@"保存成功", nil);
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"修改个人简介失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"修改个人简介失败");
            }
			
		}
	}];
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
	}

	NSString *result;

	if (textView.text.length >= range.length)
	{
		result = [textView.text stringByReplacingCharactersInRange:range withString:text];
	}
    
	if (result.length > 30)
	{
		return NO;
	}
    
	return YES;
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
//    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
