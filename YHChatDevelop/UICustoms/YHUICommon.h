//
//  YHUICommon.h
//  samuelandkevin
//
//  Created by samuelandkevin on 15/3/31.
//  Copyright (c) 2015年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef YHChat_YHUICommon_h
#define YHChat_YHUICommon_h


#ifdef __cplusplus
extern "C" {
#endif
    
#pragma mark - Public
    //显示提示,自动消失
    void postTips(id msg, NSString *title );
    //显示提示,点击才消失
    void postTipsTouchHide(id msg, NSString *title);
   
#pragma mark - Private
    void handleTips(id msg,NSString *title,BOOL touchHide);
    void showTips(id msg,BOOL touchHide);
    

#ifdef __cplusplus
};
#endif
    
#endif
