//
//  YHRegisterCompleteInfoViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/23.
//  Copyright © 2016年 YHSoft. All rights reserved.
// 

#import "YHRegisterCompleteInfoViewController.h"
#import "CellForRegister.h"
#import "CellForRegister2.h"
#import "YHRegisterChooseJobFunctionViewController.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "YHChatDevelop-Swift.h"

@interface YHRegisterCompleteInfoViewController ()<UITextFieldDelegate>{
    
    
}
#define kMaxLength 20

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cstTbvTop;//tableview顶部约束
@property(weak,nonatomic) CellForRegister2 *cell2;
@property(strong,nonatomic)CellForRegister *cell1InSec0;
//@property(strong,nonatomic)CellForRegister *cell2InSec0;
@property(strong,nonatomic)CellForRegister *cell3InSec0;
@property(strong,nonatomic)CellForRegister *cell4InSec0;
@property(weak,nonatomic)IBOutlet UITableView *tableViewList;
@end

@implementation YHRegisterCompleteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    //1.initUI
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

    //2.点击下一步
    __weak typeof(self) weakSelf = self;
    weakSelf.cell2.onNextBlock = ^{
        
       DDLog(@"真实姓名:%@", weakSelf.cell1InSec0.textField.text);
      
       DDLog(@"当前公司:%@", weakSelf.cell3InSec0.textField.text);
       
       DDLog(@"当前职位:%@", weakSelf.cell4InSec0.textField.text);
        
        NSString *userName = weakSelf.cell1InSec0.textField.text;
        if (userName.length > kMaxLength) {
            userName = [userName substringToIndex:kMaxLength];
        }
        NSString *company  = weakSelf.cell3InSec0.textField.text;
        if (company.length > kMaxLength) {
            company = [company substringToIndex:kMaxLength];
        }
        NSString *job      = weakSelf.cell4InSec0.textField.text;
        if (job.length > kMaxLength) {
            job = [job substringToIndex:kMaxLength];
        }
        //网络请求
        [weakSelf requestCompleteInfoWithuserName:userName company:company job:job];
   
    };
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
    
    _cell1InSec0   = [CellForRegister cell];
    _cell1InSec0.textField.placeholder = @"真实姓名";
    _cell1InSec0.textField.delegate    = self;
    _cell1InSec0.cstTextFieldTrailing.constant = 0;
    _cell1InSec0.imgvDownArrow.hidden  = YES;
    
    
    _cell3InSec0   = [CellForRegister cell];
    _cell3InSec0.textField.placeholder = @"当前公司";
    _cell3InSec0.textField.delegate    = self;
    _cell3InSec0.cstTextFieldTrailing.constant = 0;
    _cell3InSec0.imgvDownArrow.hidden  = YES;
    
    _cell4InSec0   = [CellForRegister cell];
    _cell4InSec0.textField.placeholder = @"当前职位";
    _cell4InSec0.textField.delegate    = self;
    _cell4InSec0.viewBotLine.hidden    = YES;
    _cell4InSec0.cstTextFieldTrailing.constant = 0;
    _cell4InSec0.imgvDownArrow.hidden  = YES;
    
    //下一步
    _cell2.btnNext.layer.cornerRadius  = 3;
    _cell2.btnNext.layer.masksToBounds = YES;
}

#pragma mark - Super
- (BOOL)isSupportSwipePop{
    return NO;
}


#pragma mark - Action
- (IBAction)onSkip:(id)sender {
   //保留,需求待定
    
}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 网络请求
//请求完善用户资料
- (void)requestCompleteInfoWithuserName:(NSString *)userName company:(NSString *)company job:(NSString *)job{
    WeakSelf
    //修改我的名片
    YHUserInfo *userInfo = [YHUserInfo new];
    userInfo.userName = userName;
    userInfo.company  = company;
    userInfo.job      = job;
    
    [[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
        
        if (success)
        {
            
            DDLog(@"修改用户信息成功");
             //修改单例属性值
             [YHUserInfoManager sharedInstance].userInfo.userName  = userName;
             [YHUserInfoManager sharedInstance].userInfo.company = company;
             [YHUserInfoManager sharedInstance].userInfo.job =job;
            
        }
        else{
            //不提示，界面不友好
        }
    
        //关闭当前页,工作圈首页刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:Event_Login_Success object:nil];
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    
    //*******kun注册调试代码,打开注释可忽略网络请求*******
//    WeakSelf
//    //修改我的名片
//    YHUserInfo *userInfo = [YHUserInfo new];
//    userInfo.userName = userName;
//    userInfo.company  = company;
//    userInfo.job      = job;
//    [[NSNotificationCenter defaultCenter] postNotificationName:Event_Login_Success object:nil];
//    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Lazy Load

- (CellForRegister2 *)cell2{
    if (!_cell2) {
        _cell2 = [CellForRegister2 cell];
    }
    return _cell2;
}

#pragma mark - KeyBoard
- (void)keyboardWillShow:(NSNotification *)aNotification{
    // get keyboard size and loctaion
    CGRect kbRect;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &kbRect];
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    UIView *activeView = _cell4InSec0;
    if (!activeView) {
        return;
    }
    
    CGPoint keyboardOriginInActiveField = [activeView convertPoint:kbRect.origin fromView:[UIApplication sharedApplication].keyWindow];
    
    float ret = activeView.frame.size.height - keyboardOriginInActiveField.y;
    if (ret > 0) {
        [UIView animateWithDuration:[duration floatValue] delay:0 options:[curve integerValue] animations:^{
            self.cstTbvTop.constant = -ret+15;
            [self.view layoutIfNeeded];
        } completion:NULL];
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cstTbvTop.constant = 15;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _cell1InSec0.textField) {
        [_cell3InSec0.textField becomeFirstResponder];
    }
    else if (textField == _cell3InSec0.textField){
        [_cell4InSec0.textField becomeFirstResponder];
    }
        
    else if (textField == _cell4InSec0.textField) {
        [_cell4InSec0.textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)aNotifi{

    UITextField *textField = (UITextField *)aNotifi.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [self.textInputMode primaryLanguage]; // 键盘输入模式
    if ([lang hasPrefix:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length  > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }

    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    DDLog(@"%ld,%@", range.location, string);
    
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
    }
    
    NSString *result;
    
    if (textField.text.length >= range.length)
    {
        result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    if (result.length > kMaxLength)
    {
        return NO;
    }
    
    return YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                return _cell1InSec0;
                break;
            case 1:
                return _cell3InSec0;
                break;
            case 2:
                return _cell4InSec0;
                break;
                
            default:
                return kErrorCell;
                break;
        }
    }
    else{
        return self.cell2;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44.0f;
    }else{
        return 140.f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
}

#pragma mark - Life
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated{
//    [self registerForKeyboardNotifications];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
//    [self unregisterKeyboardNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
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
