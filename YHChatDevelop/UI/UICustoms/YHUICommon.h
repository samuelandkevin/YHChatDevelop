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
    
    /**
     显示HUD的提示
     @param view 可以为nil,为nil时使用keywindow显示
     */
    void postHUDTips( NSString *msg ,UIView *view );
    void postHUDTipsWithHideDelay( NSString *msg ,UIView *view, float delay);
    void postHUDTipsWithImage( NSString *msg, UIView *view, UIImage *image );
    void postHUDTipsWithHideDelayAndImage( NSString *msg, UIView *view, float delay, UIImage *image );
    
    /** 显示一个activityIndicator下面一行字 不会消失*/
    id showHUDWithText( NSString *msg, UIView *view);
    /** 只显示一行字的HUD 不会消失*/
    id showHUDTextOnly( NSString *msg, UIView *view);

#ifdef __cplusplus
};
#endif
    
#endif
