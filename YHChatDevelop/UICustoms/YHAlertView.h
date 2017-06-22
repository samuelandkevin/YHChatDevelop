//
//  YHAlertView.h
//  PikeWay
//
//  Created by YHIOS002 on 2017/4/19.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, YHAlertAnimationOptions) {
    YHAlertAnimationOptionNone            = 1 <<  0,
    YHAlertAnimationOptionZoom            = 1 <<  1, // 先放大，再缩小，在还原
    YHAlertAnimationOptionTopToCenter     = 1 <<  2, // 从上到中间
};

@protocol YHAlertViewDelegate;
@class UILabel, UIButton, UIWindow;

@interface YHAlertView : UIView
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id <YHAlertViewDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)showWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitle:(nullable NSString *)otherButtonTitle clickButtonBlock:(void (^)(YHAlertView *alertView, NSUInteger buttonIndex))block;

// shows popup alert animated.
- (void)show;
@property(nullable,nonatomic,weak)id <YHAlertViewDelegate> delegate;
@property(nonatomic)YHAlertAnimationOptions animationOption;
// background visual
@property(nonatomic, assign)BOOL visual;

@end

@protocol YHAlertViewDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(YHAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

NS_ASSUME_NONNULL_END
