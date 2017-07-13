//
//  AppDelegate.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/6/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "AppDelegate.h"
#import "YHChatListVC.h"
#import "YHNavigationController.h"
#import "NetManager.h"
#import "YHLoginInputViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    configLaunchOptions();
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    //1.判断用户是否登录过
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kLoginOAuth]){
        //1-1.进入RootVc
        YHChatListVC *vc = [[YHChatListVC alloc] init];
        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
        
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
        
        //1-2.直接登录
        [[YHUserInfoManager sharedInstance] loginDirectly];
    }
    else{
        //2.没登录过,直接进入首页
        YHLoginInputViewController *vc = [[YHLoginInputViewController alloc] init];
        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
        
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTokenUnavailable:) name:Event_Token_Unavailable object:nil];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)handleTokenUnavailable:(NSNotification *)aNotifi
{
    
    //1.控制器跳转
    postTips(@"账号登录异常,请重新登录", nil);
    
    //2.处理用户token失效数据
    [[YHUserInfoManager sharedInstance] handleTokenUnavailable];
    
    YHLoginInputViewController *vc = [[YHLoginInputViewController alloc] init];
    YHNavigationController *nav    = [[YHNavigationController alloc] initWithRootViewController:vc];
    [UIApplication sharedApplication].delegate.window.rootViewController = nav;
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
    
}


@end
