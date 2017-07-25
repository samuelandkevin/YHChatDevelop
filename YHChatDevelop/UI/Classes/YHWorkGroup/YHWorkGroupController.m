
//
//  YHWorkGroupController.m
//  PikeWay
//
//  Created by YHIOS002 on 16/5/6.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWorkGroupController.h"
#import "YHNetManager.h"
#import "YHNavigationController.h"
#import "YHDynamicPublishOController.h"
//#import "YHGlobalSearchController.h"
#import "ZJScrollPageView.h"
#import "YHDynamicListViewController.h"
#import "YHWGManager.h"
#import "YHChatDevelop-Swift.h"
#import "YHWebViewController.h"
#import "MyDynamicViewController.h"


@interface YHWorkGroupController()<ZJScrollPageViewDelegate>
@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController *> *childVcs;
@property(strong, nonatomic)ZJScrollPageView *scrollPageView;
@end

@implementation YHWorkGroupController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:Event_SystemFontSize_Change object:nil];
}

- (void)initUI{
    //1.初始化左右BarBtn
//    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearch:)];
//    self.navigationItem.leftBarButtonItem = searchBtn;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithImgName:@"connection_btn_edit.png" target:self selector:@selector(onEdit:)];
    
    //3.导航条颜色 RGB16(0x00bf8f)
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"朋友圈";
    
    //4.设置ContentView
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    
    self.titles = @[@"案例分享",@"政策解读",@"财税说说",@"花边新闻",@"我的动态"
                    ];
    style.scrollTitle = self.titles.count > 4? YES:NO;
    
    // 初始化
    ZJScrollPageView *scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) segmentStyle:style titles:self.titles parentViewController:self delegate:self];
    [self.view addSubview:scrollPageView];
    _scrollPageView = scrollPageView;
}

#pragma mark - Action
//点击搜索
- (void)onSearch:(UIBarButtonItem *)sender{
    
//    YHGlobalSearchController *vc = [[YHGlobalSearchController alloc] init];
//    YHNavigationController *nav = [[YHNavigationController alloc]initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:nil];
    
}

//点击"编辑"
- (void)onEdit:(UIButton *)sender {
    
    YHDynamicPublishOController *vc = [[YHDynamicPublishOController alloc] init];
//    if (self.titles.count) {
//        vc.labelArray =  [self.titles mutableCopy];
//    }
    YHNavigationController *nav   = [[YHNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:NULL];
    
}

- (void)goTestVC:(id)sender {
    YHDynamicPublishController *vc = [[YHDynamicPublishController alloc] init];
    if (self.titles.count) {
        vc.labelArray =  [self.titles mutableCopy];
    }
    YHNavigationController *nav   = [[YHNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:NULL];

}


#pragma mark - ZJScrollPageViewDelegate
- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}


- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        
        if(index == 1){
            
            NSString *path = [YHProtocol share].pathLawLib;
            path = [NSString stringWithFormat:@"%@accessToken=%@",path,[YHUserInfoManager sharedInstance].userInfo.accessToken];
            NSURL *url = [NSURL URLWithString:path];
            childVc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) url:url loadCache:NO];
          
        }else if (index == self.titles.count-1){
            
            childVc = [[MyDynamicViewController alloc] initWithUserInfo:[YHUserInfoManager sharedInstance].userInfo];
            MyDynamicViewController *vc = (MyDynamicViewController *)childVc;
            vc.showSearchBar = YES;
        
        }else{

            childVc = [[YHDynamicListViewController alloc] init];
            YHDynamicListViewController *vc        = (YHDynamicListViewController *)childVc;
            vc.currentPage = index;
            
        }
    }

    [YHWGManager shareInstance].currentPage = index;
    
  
    
    return childVc;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}
     
#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -  NSNotification
- (void)updateFont:(NSNotification *)aNotifi{
    [_scrollPageView.segmentView setNeedsLayout];
}

#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}
@end

