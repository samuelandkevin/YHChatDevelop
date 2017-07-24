//
//  YHConfig.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/22.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHConfig.h"
#import "STMURLCache.h"
#import "YHAppInfoManager.h"
#import "UIImageView+WebCache.h"
#import <SMS_SDK/SMSSDK.h>

const int   kDynamciTextMaxLength             = 150; //发动态长度
const int   lengthForEveryRequest             = 20;  //每次请求n条
const int   kVerifyCodeValidDuration          = 120; //验证码有效时长
//Mob短信平台
NSString * const kMobAppKey                   = @"11f71aa828ed0";
NSString * const kMobAppSecret                = @"a64321f5ede1e37b5e2f47b070f4f272";
//友盟
NSString * const kUmengAppkey                 = @"58a575bb310c931f440006d1";//之前是：5735a329e0f55a1d170034ed

//微信开发平台
NSString * const kWXAppId = @"wxe8e8240e8bf2c3a3";
NSString * const kWXAppSecret = @"ae5ac01d111423d950d5d0a056fb8e0d";

//腾讯开放平台
NSString * const kQQAppId = @"1105361751";
NSString * const kQQAppSecret = @"U6BpxVgHIAjUKIu0";

#pragma mark - Public

void configLaunchOptions(){
    [[NetManager sharedInstance] startMonitoring];
    configWebViewCache();
    configSysFont();
}

void configMobSDK() {
    [SMSSDK registerApp:kMobAppKey withSecret:kMobAppSecret];
}


void configSDWebImage(){
    [[SDImageCache sharedImageCache] setMaxMemoryCountLimit:32];
    [[SDImageCache sharedImageCache] setMaxMemoryCost:8192000];
}

void configWebViewCache(){
    //webView离线缓存
//    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];
    //webView加载缓存
    
    NSString *whiteListStr = @"apps.gtax.cn|testapp.gtax.cn";
    NSMutableArray *whiteLists = [NSMutableArray arrayWithArray:[whiteListStr componentsSeparatedByString:@"|"]];
    NSString *userAgent  = [YHAppInfoManager shareInstanced].userAgent;
    BOOL useURLProtocol  = NO;
    NSUInteger cacheTime = 24*60*60;
    [YHAppInfoManager shareInstanced].webCacheUseURLProtocol = useURLProtocol;
    
    [STMURLCache create:^(STMURLCacheMk *mk) {
        mk.whiteListsHost(whiteLists).whiteUserAgent(userAgent).isUsingURLProtocol(useURLProtocol).cacheTime(cacheTime);
    }];
  
    
}

void configSysFont(){
    [UILabel setupGlobalFont];
    [UITextField setupGlobalFont];
}
