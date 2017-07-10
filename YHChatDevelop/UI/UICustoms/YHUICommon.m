//
//  YHUICommon.m
//  YHChat
//
//  Created by zhaochuangye on 15/1/28.
//  Copyright (c) 2015年 samuelandkevin. All rights reserved.
//

#import "YHUICommon.h"
#import "AppDelegate.h"
#import "YHTipsView.h"
#import "NetManager.h"

void postTipsTouchHide(NSString *msg, NSString *title){
    handleTips(msg,title,YES);
}

void postTips(id msg, NSString *title) {
    handleTips(msg,title,NO);
}


void handleTips(id msg,NSString *title,BOOL touchHide){
    dispatch_async(dispatch_get_main_queue(), ^{
        //1.自定义的错误描述
        if ([msg isKindOfClass:[NSString class]])
        {
            
            DDLog(@"\n<错误标题: %@ \n错误描述: %@>",title,msg);
            
            if ([msg isEqualToString: kServerReturnEmptyData]) {
                
            }
            else{
                showTips(msg,touchHide);
            }
            
        }
        
        //2.AFN请求失败错误描述
        if ([msg isKindOfClass:[NSError class]])
        {
            NSError *error = (NSError *)msg;
            NSString *errorTitle = @"";
            if ([title isKindOfClass:[NSString class]]) {
                errorTitle = title;
            }
            DDLog(@"\n<错误标题:%@ \n错误代码: %ld \n错误描述: %@>",errorTitle,(long)error.code,error.localizedDescription);
            if (error.code == -1009)
            {
                showTips(kNetWorkFailTips,touchHide);
            }
            if (error.code == -1011)
            {
                
                NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                
                if (response.statusCode == 401)
                {
                    //token失效,重新登录
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_Token_Unavailable object:nil];
                    
                    
                }
                
            }
            if (error.code == -1001)
            {
                showTips(kNetWorkReqTimeOutTips,touchHide);
                
            }
            
        }
        
        //3.服务器返回的错误描述
        if ([msg isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dictError = (NSDictionary *)msg;
            DDLog(@"\n<错误标题:%@ \n错误代码: %@ \n错误描述: %@>",title,dictError[@"code"],dictError[@"msg"]);
        }
        
    });

}

void showTips(NSString *msg,BOOL touchHide){
    YHTipsView *tipsView =  [[YHTipsView alloc] init];
  
    [tipsView showTouchHide:touchHide msg:msg];
    
    tipsView.tips = msg;
}

