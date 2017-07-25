//
//  YHDynamicListViewController.h
//  PikeWay
//
//  Created by YHIOS002 on 16/8/12.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJScrollPageViewDelegate.h"

@interface YHDynamicListViewController : UIViewController <ZJScrollPageViewChildVcDelegate>
@property (nonatomic,assign) NSInteger  currentPage;//当前动态页

@end
