//
//  YHRegisterChooseJobFunctionViewController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  注册选择工作职能

//#import "SuperViewController.h"

@interface YHRegisterChooseJobFunctionViewController : UIViewController


//初始化带有选择职业信息回调
- (instancetype)initWithSelectedJobBlock:(void(^)(NSString *jobType,NSString *jobDetail))selectedJobBlock;

//初始化带有判断点击“确定”按钮是否push to another控制器
- (instancetype)initWithSureToPushNextController:(BOOL)surePushToNextVC;
@end
