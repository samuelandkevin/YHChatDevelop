//
//  YHLoadFailView.h
//  PikeWay
//
//  Created by YHIOS002 on 16/9/26.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHLoadView : UIView

//构造加载失败View
+ (instancetype)loadFail;
//构造加载中View
+ (instancetype)loading;

//显示加载失败
- (void)showLoadFailView;
//显示加载中
- (void)showLoadingView;
//隐藏加载失败
- (void)hideFailView;
//隐藏加载中
- (void)hideLoadingView;

//点击重新加载
- (void)onReloadHandler:(void(^)())handler;

@end
