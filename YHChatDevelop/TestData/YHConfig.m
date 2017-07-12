//
//  YHConfig.m
//  PikeWay
//
//  Created by YHIOS002 on 16/4/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHConfig.h"
#import "STMURLCache.h"
#import "YHAppInfoManager.h"
#import "UIImageView+WebCache.h"

const int   kDynamciTextMaxLength             = 150; //发动态长度
const int   lengthForEveryRequest             = 20;  //每次请求n条
const int   kVerifyCodeValidDuration          = 120; //验证码有效时长

#pragma mark - Public

void configLaunchOptions(){
    [[NetManager sharedInstance] startMonitoring];
    configWebViewCache();
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
