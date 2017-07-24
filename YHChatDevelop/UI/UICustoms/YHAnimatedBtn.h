//
//  YHAnimatedBtn.h
//
//
//  Created by apple on 16/8/10.
//  Copyright © 2016年 kun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHAnimatedBtn : UIView

@property (nonatomic,copy) void(^onLoginBlock)();//登录回调
@property (nonatomic,copy) NSString *title;      //按钮标题

- (void)setNormal;  //normal   (输入框无文字时btn显示)
- (void)setSelected;//selected (输入框有文字时btn显示)
- (void)reset;      //reset    (重置)
- (void)showLoadingComplete:(void(^)())complete;//显示菊花
- (void)hideLoading;//隐藏菊花

@end
