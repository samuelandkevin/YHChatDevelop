//
//  YHDynamicListViewController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/8/12.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJScrollPageViewDelegate.h"

@interface YHDynamicListViewController : UIViewController <ZJScrollPageViewChildVcDelegate>
@property (nonatomic,assign) NSInteger  currentPage;//当前动态页

@end
