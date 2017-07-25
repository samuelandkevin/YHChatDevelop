//
//  YHRegisterByPhoneNumViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHRegisterByPhoneNumViewController.h"
#import "RegexKitLite.h"
#import "YHNetManager.h"
#import <SMS_SDK/SMSSDK.h>
#import "HHUtils.h"
#import "YHRegisterChooseJobMainViewController.h"
#import "YHUserInfoManager.h"
#import "MBProgressHUD.h"
#import "YHVerifyCodeManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQKeyboardManager.h"
#import "YHChatDevelop-Swift.h"

#define kGetVerifyCodeCDTime    60      // 60秒

@interface YHRegisterByPhoneNumViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
        NSTimer         *_timerForGetVerifyCodeCD;
    
}


@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNum;   //手机号
@property (weak, nonatomic) IBOutlet UITextField *tfVerifyCode; //验证码
@property (weak, nonatomic) IBOutlet UITextField *tfCode;        //密码
@property (weak, nonatomic) IBOutlet UIView *viewContainer; //输入视图容器
@property (weak, nonatomic) IBOutlet UIButton *btnFinishRegister;  //完成注册
@property (weak, nonatomic) IBOutlet UIButton *btnSendVerifyCode; //发送验证码
@property (strong, nonatomic)IBOutlet UITableViewCell *cellForInput;
@property (weak, nonatomic)  IBOutlet NSLayoutConstraint *cstTbvTop;//tableview顶部距离约束
@property (weak,nonatomic) IBOutlet UITableView  *tableViewList;

@property (assign,nonatomic) int nGetVerifyCodeCDTime; //倒计时
@property (nonatomic,strong) NSTimer *registerVerifyCodeTimer;

@end

@implementation YHRegisterByPhoneNumViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _timerForGetVerifyCodeCD    = NULL;
        _nGetVerifyCodeCDTime       = kGetVerifyCodeCDTime;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //1.初始化UI
    [self initUI];
    
    //2.监听通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.tfPhoneNum];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.tfCode];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.tfVerifyCode];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - init
- (void)setupNavigationBar{
    self.title = @"注册";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)initUI{
    [self setupNavigationBar];
    
    //输入容器边框颜色
    self.viewContainer.layer.borderColor   = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0].CGColor;
    self.viewContainer.layer.borderWidth   = 0.5;
    self.viewContainer.layer.cornerRadius  = 1;
    self.viewContainer.layer.masksToBounds = YES;
    
    //设置输入框左视图
    UIView *leftViewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.tfPhoneNum.leftView = leftViewPhone;
    self.tfPhoneNum.leftViewMode = UITextFieldViewModeAlways;
    
     UIView *leftViewCode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
     self.tfCode.leftView     = leftViewCode;
     self.tfCode.leftViewMode =UITextFieldViewModeAlways;
    
     UIView *leftViewVeriCode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    self.tfVerifyCode.leftView = leftViewVeriCode;
    self.tfVerifyCode.leftViewMode =UITextFieldViewModeAlways;
    
    //发送验证码
    self.btnSendVerifyCode.enabled = NO;
    self.btnSendVerifyCode.backgroundColor = kGrayColor;
    self.btnSendVerifyCode.layer.cornerRadius = 1;
    self.btnSendVerifyCode.layer.masksToBounds = YES;
    
    //完成注册
    self.btnFinishRegister.layer.cornerRadius  = 3;
    self.btnFinishRegister.layer.masksToBounds = YES;
    self.btnFinishRegister.enabled = NO;
    self.btnFinishRegister.backgroundColor = kGrayColor;
    
    //tableview
    self.tableViewList.rowHeight = 286.0f;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    IQKeyboardReturnKeyHandler * returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    returnKeyHandler.delegate = self;
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellForInput;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];

}


#pragma mark - Action
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  完成注册
 *
 *  @param sender btn
 */
- (IBAction)onFinishRegister:(id)sender {
    
    if (!isValidePhoneFormat(self.tfPhoneNum.text)) {
        postHUDTips(@"手机号填写不正确,仅支持大陆手机号码", self.view);
        return;
    }
    
    if(!isValidePassword(self.tfCode.text))
    {
        postHUDTips(@"登录密码请输入6-20位数字或字符", self.view);
        return;
    }
    
    if (!self.tfVerifyCode.text.length) {
        postHUDTips(@"验证码不能为空", self.view);
        return;
    }
    
    if ([[YHVerifyCodeManager shareInstance] isExpiredRegisterVerifyCode]) {
        postTips(@"验证已失效，请重新获取", nil);
        return;
    }
    
    if([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable){
        postHUDTips(kNetWorkFailTips, self.view);
        return;
    }
    
    [self.view endEditing:YES];
    
    //2.向服务器进行注册请求
    __weak typeof(self) weakSelf = self;
     __block MBProgressHUD *hud = showHUDWithText(@"", self.view);
    [weakSelf requestRegisterComplete:^(BOOL success, id obj) {
        [hud hide:YES];
        if (success)
        {
            [YHError shareInstance].verifyCodeErrorCount = 0;
            
            [[YHVerifyCodeManager shareInstance] resetRegisterVCDate];
            
            //注册成功,进入完善资料页面.
            DDLog(@"注册成功,正准备进入完善资料页面");
            
            //1.提示
            postHUDTips(@"注册成功",self.view);
            
            //2.通知环信去注册
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_Register_Success object:nil userInfo:@{
                             @"phone":weakSelf.tfPhoneNum,
                             @"passwd":weakSelf.tfCode.text
                             }];

            //3.更新用户偏好设置信息
            [[YHUserInfoManager sharedInstance] loginSuccessWithUserInfo:obj];
            
            //4. 0.5秒后进入完善资料页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                YHRegisterChooseJobMainViewController *vc =[[YHRegisterChooseJobMainViewController alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES ];
            });
            
        }else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误代码
                NSString *code = obj[kRetCode];
                NSString *msg  = obj[kRetMsg];
                if ([code isEqualToString:[YHError shareInstance].kErrorVerifyCode]) {
                    //验证码错误
                    if ([YHError shareInstance].verifyCodeErrorCount >= 3)
                    {
                        postTips(@"验证码输错三次，请重新获取", @"");
                    }
                    else
                    {
                        postTips(@"验证码错误,请重新输入", @"");
                    }
                   
                     [YHError shareInstance].verifyCodeErrorCount +=1;
                }
                else{
                    postTips(msg, @"注册失败");
                }
              
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"注册失败");
            }
          
        }

    }];
    
    
    //*******kun注册调试代码,打开注释可忽略网络请求*******
    //    YHRegisterChooseJobMainViewController *vc =[[YHRegisterChooseJobMainViewController alloc] init];
    //    [self.navigationController pushViewController:vc animated:YES ];
    
}

//发送验证码
- (IBAction)onSendVerifyCode:(id)sender {
    
    //0.手机格式是否正确
    if(!isValidePhoneFormat(self.tfPhoneNum.text))
    {
        postHUDTips(@"手机号填写不正确,仅支持大陆手机号码", self.view);
        return;
    }
    
    if([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable){
        postHUDTips(kNetWorkFailTips, self.view);
        return;
    }
    
    [YHError shareInstance].verifyCodeErrorCount = 0;
   
    
    //1.倒计时开始
    [self coolDownForGetVerificationCode];
     self.btnSendVerifyCode.backgroundColor = kGrayColor;
    
    //2.手机输入框不能编辑
    self.tfPhoneNum.enabled = NO;
    
    //3.向服务器验证手机号是否可以进行注册
    __weak typeof(self) weakSelf = self;
    [weakSelf checkPhoneWhetherExsit:^(BOOL success, id obj) {
        
        if (success) {
            
            //手机可以进行注册
            DDLog(@"验证手机号成功,此手机可以注册");
            [weakSelf getVerifyCode];
            
        }else{
            
            [weakSelf resetTimerAndVerifyCodeBtn];
            
            if (isNSDictionaryClass(obj))
            {
                NSString *code = obj[kRetCode];
                NSString *msg  = obj[kRetMsg];
                if ([code isEqualToString:[YHError shareInstance].kErrorPhoneNumExist])
                {
                    postTips(@"该手机号已经注册,请登录", @"");
                }
                else
                {
                    postTips(msg, @"");
                }
               
            }
            else
            {
                    postTips(obj,@"验证手机号失败");
            }
            
           
            
        }
    }];
    
}

//重置定时器和发送验证码
- (void)resetTimerAndVerifyCodeBtn{
    [_timerForGetVerifyCodeCD invalidate];
    _timerForGetVerifyCodeCD = NULL;
    _nGetVerifyCodeCDTime = kGetVerifyCodeCDTime;
    
    [_btnSendVerifyCode setTitle:@"重新验证" forState:UIControlStateNormal];
    [_btnSendVerifyCode setTitle:@"验证" forState:UIControlStateDisabled];
    _btnSendVerifyCode.enabled = YES;
    _btnSendVerifyCode.backgroundColor = kBlueColor;
    
    self.tfPhoneNum.enabled  = YES;
}

//检查手机是否已经注册
- (void)checkPhoneWhetherExsit:(NetManagerCallback)complete{
    [[NetManager sharedInstance] getVerifyphoneNum:_tfPhoneNum.text complete:^(BOOL success, id obj) {
             complete(success,obj);
    }];

}

#pragma mark - 网络请求
//向服务器请求注册
- (void)requestRegisterComplete:(NetManagerCallback)complete{
    //手机号,密码，验证码必需
    //MD5加密
    NSString *codeMD5 = [HHUtils md5HexDigest:self.tfCode.text];
    [[NetManager sharedInstance] postRegisterWithPhoneNum:self.tfPhoneNum.text veriCode:self.tfVerifyCode.text passwd:codeMD5 complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
}

/**
 *  向MobSDK获取手机验证码
 */
- (void)getVerifyCode{
    
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS
                            phoneNumber:self.tfPhoneNum.text
                                   zone:@"86"
                       customIdentifier:nil //自定义短信模板标识
                                 result:^(NSError *error)
     {
         
         if (!error)
         {
              postHUDTips([NSString stringWithFormat:@"验证码已经发送到%@的手机",_tfPhoneNum.text],self.view);
             
             [[YHVerifyCodeManager shareInstance] storageRegisterVCDate];
         }
         else
         {

             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"获取验证码失败"
                                                             message:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"getVerificationCode"]]
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil, nil];
             [alert show];
             
         }
         
     }];

}


#pragma mark - Private

- (void)coolDownForGetVerificationCode {
    if (!_timerForGetVerifyCodeCD) {
        _timerForGetVerifyCodeCD = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onCDTimer:) userInfo:nil repeats:YES];
        _btnSendVerifyCode.enabled = NO;
    }
}

- (void)onCDTimer:(NSTimer *)theTimer {
    _nGetVerifyCodeCDTime -= 1;
    [_btnSendVerifyCode setTitle:[NSString stringWithFormat:@"%@(%d)", @"获取验证码", _nGetVerifyCodeCDTime] forState:UIControlStateDisabled];
    if (_nGetVerifyCodeCDTime == 0) {
        [self resetTimerAndVerifyCodeBtn];
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _tfPhoneNum) {
        if ( !isValidePhoneFormat(self.tfPhoneNum.text)) {
            postHUDTips(@"手机号填写不正确,仅支持大陆手机号码", self.view);
            return NO;
        }
        else {

            [_tfCode becomeFirstResponder];
            return YES;
        }
    }
    else if( textField == _tfCode) {
        if(!isValidePassword(self.tfCode.text))
        {
            postHUDTips(@"登录密码请输入6-20位数字或字符", self.view);
            return NO;
        }
        [_tfVerifyCode becomeFirstResponder];
        return YES;
    }
    else if(textField == _tfVerifyCode){
        [_tfVerifyCode resignFirstResponder];
        return  NO;
    }
   
    return YES;
}


#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated{
    //状态栏显示
    [UIApplication sharedApplication].statusBarHidden = NO;
    [super viewWillAppear:animated];
    if (isiPad) {
        [[IQKeyboardManager sharedManager] setEnable:NO];
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    }
   

}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    if (isiPad) {
        [[IQKeyboardManager sharedManager] setEnable:YES];
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    }
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

#pragma mark - NSNotification

- (void)textFiledEditChanged:(NSNotification *)aNotifi{
    
    if (!self.tfPhoneNum.text.length)
    {
        self.btnSendVerifyCode.enabled = NO;
        self.btnSendVerifyCode.backgroundColor = kGrayColor;
    }
    else{
        self.btnSendVerifyCode.enabled = YES;
        self.btnSendVerifyCode.backgroundColor = kBlueColor;
    }
    
    if (!self.tfPhoneNum.text.length || !self.tfCode.text.length || !self.tfVerifyCode.text.length) {
        self.btnFinishRegister.enabled = NO;
        self.btnFinishRegister.backgroundColor = kGrayColor;
    }
    else{
        self.btnFinishRegister.enabled = YES;
        self.btnFinishRegister.backgroundColor = kBlueColor;
    }
    

}


- (BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
