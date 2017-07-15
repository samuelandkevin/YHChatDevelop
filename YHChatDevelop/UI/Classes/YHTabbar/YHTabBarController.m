//
//  YHTabBarController.m
//  PikeWay
//
//  Created by YHIOS002 on 16/4/21.
//  Copyright © 2016年 YHSoft. All rights reserved.
//
#import "YHNavigationController.h"
#import "YHTabBarController.h"
#import "YHChatListVC.h"
#import "YHConnectioniewController.h"

@interface YHTabBarController ()

@property(nonatomic,strong) YHChatListVC * firstVC;

@property(nonatomic,strong) YHConnectioniewController * secVC;

@property(nonatomic,strong) UIViewController * thiVC;

@property(nonatomic,strong) UIViewController * fifVC;
@end

@implementation YHTabBarController


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.firstVC = [[YHChatListVC alloc]init];
        self.secVC = [[YHConnectioniewController alloc]init];
        self.thiVC = [[UIViewController alloc]init];
        self.fifVC = [[UIViewController alloc]init];

        UIColor * color = [UIColor colorWithRed:0.f green:191.f / 255 blue:143.f / 255 alpha:1];
        NSDictionary *colorDic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
        [[UITabBarItem appearance] setTitleTextAttributes:colorDic forState:UIControlStateSelected];
        
        //此处改动navigationbar的标题
       
        self.firstVC.title = @"首页";
        self.secVC.title   = @"通讯录";
        self.thiVC.title   = @"发现";
        self.fifVC.title   = @"我";
        
        //此处改动tabbar上的标题和图片(分普通和被选中); ps: 标题和图片必须同时设置才有显示
        self.firstVC.tabBarItem.title = @"首页";
        self.firstVC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_mainframe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.firstVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_mainframeHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.secVC.tabBarItem.title = @"通讯录";
        self.secVC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_contacts"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.secVC.tabBarItem.selectedImage  = [[UIImage imageNamed:@"tabbar_contactsHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.thiVC.tabBarItem.title = @"发现";
        self.thiVC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_discover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.thiVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_discoverHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        
        self.fifVC.tabBarItem.title = @"我";
        self.fifVC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.fifVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_meHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self setupTabBar];
        
        //这里设置导航栏,默认用系统的,如需修改,进入超类添加方法,但不允许重写init 和 viewdidload等方法,自己写开关方法去调用
        YHNavigationController *firNav = [[YHNavigationController alloc]initWithRootViewController:self.firstVC];
        YHNavigationController *secNav = [[YHNavigationController alloc]initWithRootViewController:self.secVC];
        YHNavigationController *thiNav = [[YHNavigationController alloc]initWithRootViewController:self.thiVC];
        YHNavigationController *fifNav = [[YHNavigationController alloc]initWithRootViewController:self.fifVC];
        self.viewControllers = @[firNav,secNav,thiNav,fifNav];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)setupTabBar
{
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:bgView atIndex:0];
    self.tabBar.opaque = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
