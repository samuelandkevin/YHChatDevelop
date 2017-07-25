//
//  YHDynamicForwardController.m
//  PikeWay
//
//  Created by YHIOS003 on 16/5/26.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHDynamicForwardController.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "IQKeyboardManager.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "IQTextView.h"
#import "YHChatDevelop-Swift.h"

@interface YHDynamicForwardController ()<UITextViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) IQTextView *textView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic,strong) UIImageView * avatar;

@property(nonatomic,strong) UILabel * name;

@property(nonatomic,strong) UILabel * detail;

@property(nonatomic,strong) YHWorkGroup *currentWorkGroup;
@end
#define textViewHeight (SCREEN_WIDTH - 60) / 3 * 2
@implementation YHDynamicForwardController

- (instancetype)initWithWorkGroup:(YHWorkGroup *)workGroup{
    if (self = [super init]) {
        if (!workGroup) {
            
            return nil;
        }
        _currentWorkGroup = workGroup;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"转发动态";
   
    self.navigationController.navigationBar.translucent = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 63);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    self.textView = [[IQTextView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, textViewHeight)];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
    self.textView.layer.cornerRadius = 10;
    self.textView.placeholder = @"说点儿感想吧";
//    self.textView.placeholder = [UIFont systemFontOfSize:16];
//    self.textView.placeholderTextColor = [UIColor colorWithWhite:0.557 alpha:1.000];
    self.textView.delegate = self;
    //    self.textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.scrollView addSubview:self.textView];
    

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithTitle:@"取消" target:self selector:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"发送" target:self selector:@selector(publish:)];
    
    
    self.avatar = [[UIImageView alloc]initWithFrame:CGRectMake(15, 30+textViewHeight, 70, 70)];
    [self.avatar sd_setImageWithURL:_currentWorkGroup.userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    self.avatar.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:self.avatar];
    
    self.name = [[UILabel alloc]initWithFrame:CGRectMake(100, 30+textViewHeight, SCREEN_WIDTH - 100 -15, 28)];
    self.name.font =[UIFont systemFontOfSize:16];
    self.name.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
    self.name.numberOfLines = 1;
    self.name.lineBreakMode = NSLineBreakByTruncatingTail;
    self.name.text = _currentWorkGroup.userInfo.userName;
    [self.scrollView addSubview:self.name];
    
    self.detail = [[UILabel alloc]initWithFrame:CGRectMake(100, 30+textViewHeight + 28, SCREEN_WIDTH - 100 -15, 42)];
    self.detail.font =[UIFont systemFontOfSize:14];
    self.detail.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
    self.detail.numberOfLines = 2;
    self.detail.lineBreakMode = NSLineBreakByTruncatingTail;
    self.detail.text = _currentWorkGroup.msgContent;
    [self.scrollView addSubview:self.detail];
    
    
    
    
    // Do any additional setup after loading the view.
}

#pragma mark  - Life
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //	[self.textView becomeFirstResponder];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

- (void)touchesBegan:(NSSet <UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textView resignFirstResponder];
}

- (void)cancel:(id)sender
{
    [self.textView resignFirstResponder];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)publish:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.scrollView animated:YES];
    [self requestRepostDynamic];
}

#pragma mark scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textView resignFirstResponder];
}

#pragma mark textView delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
//请求转发动态
- (void)requestRepostDynamic{
    [[NetManager sharedInstance] postDynamicRepostWithId:_currentWorkGroup.dynamicId content:self.textView.text visible:DynmaicVisible_AllPeople atUsers:nil complete:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView:self.scrollView animated:YES];
        
        if (success)
        {
            DDLog(@"转发动态成功：%@",obj);
            
            postTips(@"转发动态成功", nil);
            int dynTag = 0; //后台默认把转发动态归类为动态标签为0
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew", @"subIndex":@(dynTag)}];
            [self.view endEditing:YES];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"转发动态失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"转发动态失败");
            }
            
        }
    }];
}

@end
