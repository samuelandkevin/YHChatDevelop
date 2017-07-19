//
//  YHLoginInputViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHLoginInputViewController.h"
#import "NetManager.h"
#import "NetManager+Login.h"
#import "YHChatListVC.h"
#import "YHUserInfoManager.h"
//用户手机号
#define kMobilePhone            @"mobilePhone"
@interface YHLoginInputViewController () <UITextFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *tfAccount; //账号
@property (weak, nonatomic) IBOutlet UITextField *tfPasswd;  //密码
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;     //登录

@property (weak, nonatomic) IBOutlet UIView *viewContariner;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnForgetCode;
@property (weak, nonatomic) IBOutlet UIButton *btnVisitorLogin;

/*社交账号View*/
@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (weak, nonatomic) IBOutlet UIButton *btnQQ;
@property (weak, nonatomic) IBOutlet UIButton *btnWechat;
@property (weak, nonatomic) IBOutlet UIButton *btnSina;
@property (weak, nonatomic) IBOutlet UILabel *labelQQ;
@property (weak, nonatomic) IBOutlet UILabel *labelWechat;
@property (weak, nonatomic) IBOutlet UILabel *labelSina;


@end

@implementation YHLoginInputViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
   
	//1.initUI
	[self initUI];

	//2.监听通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
												 name:@"UITextFieldTextDidChangeNotification"
											   object:self.tfAccount];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
												 name:@"UITextFieldTextDidChangeNotification"
											   object:self.tfPasswd];
    

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - init

- (void)setupNavigationBar{
    self.title = @"登录";
    self.navigationController.navigationBar.translucent = NO;

}

- (void)initUI
{
    [self setupNavigationBar];
    
	//输入容器边框颜色
	self.viewContariner.layer.borderColor = [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1.0].CGColor;
	self.viewContariner.layer.borderWidth = 0.5;
	self.viewContariner.layer.cornerRadius = 1;
	self.viewContariner.layer.masksToBounds = YES;

	//设置输入框左视图
	UIView *leftViewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
	self.tfAccount.leftView = leftViewPhone;
	self.tfAccount.leftViewMode = UITextFieldViewModeAlways;


    
	UIView *leftViewCode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
	self.tfPasswd.leftView = leftViewCode;
	self.tfPasswd.leftViewMode = UITextFieldViewModeAlways;

	//登录按钮
//    self.btnLogin.hidden = NO;
	self.btnLogin.layer.cornerRadius = 3;
	self.btnLogin.layer.masksToBounds = YES;
	self.btnLogin.enabled = NO;
	self.btnLogin.backgroundColor = RGBCOLOR(196, 197, 198);

    //游客登录
    self.btnVisitorLogin.layer.cornerRadius = 3;
    self.btnVisitorLogin.layer.masksToBounds = YES;
   
    
    //立即注册
    [self.btnRegister setTitleColor:kBlueColor forState:UIControlStateNormal];
    
    //忘记密码
    [self.btnForgetCode setTitleColor:kBlueColor forState:UIControlStateNormal];
   
    
}

#pragma mark - Setter



#pragma mark - Action
- (IBAction)onBack:(id)sender {
   
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

//登录
- (IBAction)onLogin:(id)sender
{
    WeakSelf
    [[NetManager sharedInstance] postLoginWithPhoneNum:weakSelf.tfAccount.text passwd:weakSelf.tfPasswd.text complete:^(BOOL success, id obj) {
        //取消Loading
        //		[weakSelf.loginLoading hide:YES];
        
        
        if (success)
        {
          
            
            DDLog(@"登录成功:%@", obj);
            YHUserInfo *userInfo = obj;
            //1.更新用户偏好设置信息
            [[YHUserInfoManager sharedInstance] loginSuccessWithUserInfo:userInfo];
            
            
            //2.跳转到首页
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_Login_Success object:nil];
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
            
        }
        else
        {
               DDLog(@"登录失败");
            
        }
    }];
    
}

//忘记密码
- (IBAction)onForgetCode:(id)sender
{
	
}

//立即注册
- (IBAction)onRegister:(id)sender
{
	
}

//密码输入方式
- (IBAction)showPasswd:(UIButton *)sender
{
	sender.selected = !sender.selected;
	NSString *passwd = self.tfPasswd.text;
	self.tfPasswd.secureTextEntry = (sender.selected) ? NO : YES;
	self.tfPasswd.text = @" ";
	self.tfPasswd.text = passwd;
}

//游客登录
- (IBAction)onVisitorLogin:(id)sender {
    
    YHChatListVC *vc = [YHChatListVC new];
    vc.isVisitor = YES;
    YHUserInfo *simulateUserInfo = [YHUserInfo new];
    simulateUserInfo.userName = @"samuelandkevin";
    simulateUserInfo.uid = @"1";
    simulateUserInfo.accessToken = @"1";
    simulateUserInfo.avatarUrl = [NSURL URLWithString:@"http://testapp.gtax.cn/images/2016/11/05/812eb442b6a645a99be476d139174d3c.png!m90x90.png"];
    [YHUserInfoManager sharedInstance].userInfo = simulateUserInfo;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)onLoginByQQ:(id)sender {

}

- (IBAction)onLoginByWechat:(id)sender {
    
}

- (IBAction)onLoginBySina:(id)sender {
    
}



#pragma mark - Private






#pragma mark - Life
- (void)viewDidAppear:(BOOL)animated
{
	// 设置账号
	NSString *strAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];

	if (strAccount && strAccount.length > 0)
	{
		_tfAccount.text = strAccount;
	}
    
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.tfAccount.text = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];

	//状态栏显示,从欢迎页跳进此页面显示
	[UIApplication sharedApplication].statusBarHidden = NO;
	[super viewWillAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{

	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DDLog(@"%s vc dealloc", __FUNCTION__);
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//	self.activeView = _btnLogin;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _tfAccount)
	{
		[_tfPasswd becomeFirstResponder];
	}
	else if (textField == _tfPasswd)
	{
		[_tfAccount resignFirstResponder];
		// 默认是登录操作
		[self onLogin:nil];
//		self.activeView = nil;
	}
	return YES;
}

#pragma mark - Keyboard Event

- (void)keyboardWasShown:(NSNotification *)aNotification
{}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{}

#pragma mark - NSNotification

- (void)textFiledEditChanged:(NSNotification *)aNotifi
{
	if (!self.tfAccount.text.length || !self.tfPasswd.text.length)
	{
		self.btnLogin.enabled = NO;
		self.btnLogin.backgroundColor = RGBCOLOR(196, 197, 198);
        _btnLogin.enabled = NO;
	}
	else
	{
		self.btnLogin.enabled = YES;
		self.btnLogin.backgroundColor = kBlueColor;
        _btnLogin.enabled = YES;
	}
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

/*
 * #pragma mark - Navigation
 *
 *  // In a storyboard-based application, you will often want to do a little preparation before navigation
 *  - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 *   // Get the new view controller using [segue destinationViewController].
 *   // Pass the selected object to the new view controller.
 *  }
 */

@end
