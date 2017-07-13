//
//  NetManager+AppInfo.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "NetManager+AppInfo.h"

@implementation NetManager (AppInfo)

//获取页面能否打开信息
- (void)getPageInfoAboutCanOpenedComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", [YHProtocol share].kBaseURL,[YHProtocol share].kPathPageCanOpened];
    
    NSDictionary *params = @{
                             @"platform":iOSPlatform,
                             @"app_id":TaxTaoAppId
                             };
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success) {
            NSArray *retArray = [obj objectForKey:@"data"];
            complete(YES,retArray);
        }else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

@end
