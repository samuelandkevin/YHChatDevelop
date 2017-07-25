//
//  YHDynDetailVC.h
//  PikeWay
//
//  Created by YHIOS002 on 16/10/14.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  动态详情控制器

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"



@interface YHDynDetailVC : UIViewController

//@property (nonatomic,assign) BOOL refreshSearchDynPage;//刷新搜索动态页
//@property (nonatomic,assign) BOOL refreshWorkGroupPage;//刷新工作圈首页
//@property (nonatomic,assign) BOOL refreshMyDynamicPage;//刷新我的动态页
//@property (nonatomic,assign) BOOL refreshSynthesisPage;//刷新综合搜索页

@property (nonatomic,assign) RefreshPage refreshPage;

- (instancetype)initWithWorkGroup:(YHWorkGroup *)workGroup;

- (instancetype)initWithDynamicId:(NSString *)dynamicId;

@end
