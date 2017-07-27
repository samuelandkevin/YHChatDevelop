//
//  YHCommentKeyboard.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/3/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - @protocol YHCommentKeyboardDelegate
@class YHCommentKeyboard;
@protocol YHCommentKeyboardDelegate <NSObject>

@required
//点击发送
- (void)didTapSendBtn:(NSString *)text;

@optional
//根据键盘是否弹起，设置tableView frame
- (void)keyboard:(YHCommentKeyboard *)keyBoard changeDuration:(CGFloat)durtaion;

@end

//评论类型
typedef NS_ENUM(int,YHCommentType){
    YHCommentType_Comment,//评论
    YHCommentType_Reply   //回复评论
};

#pragma mark - YHCommentKeyboard

@interface YHCommentKeyboard : UIView

@property (nonatomic, assign) int maxNumberOfRowsToShow;//最大显示行
@property (nonatomic, copy) NSString  *placeholder;
@property (nonatomic, assign)YHCommentType commentType;//评论类型

/**
 初始化方式
 
 @param viewController YHExpressionKeyboard所在的控制器
 @param aboveView 在viewController的view中,位于YHExpressionKeyboard上方的视图,（用于设置aboveView的滚动）
 @return YHExpressionKeyboard
 */
- (instancetype)initWithViewController:( UIViewController <YHCommentKeyboardDelegate>*)viewController aboveView:( UIView *)aboveView;


/**
 成为第一响应者
 */
- (void)becomeFirstResponder;
/**
 结束编辑
 */
- (void)endEditing;

@end

