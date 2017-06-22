//
//  NetManager+AppInfo.m
//  PikeWay
//
//  Created by YHIOS002 on 16/12/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NetManager+AppInfo.h"

@implementation NetManager (AppInfo)

//获取页面能否打开信息
- (void)getPageInfoAboutCanOpenedComplete:(NetManagerCallback)complete{
   
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", kBaseURL,kPathPageCanOpened];
    
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
