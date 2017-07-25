//
//  MyDynamicViewController.h
//  PikeWay
//
//  Created by kun on 16/5/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"
#import "ZJScrollPageViewDelegate.h"

@interface MyDynamicViewController : UIViewController<ZJScrollPageViewChildVcDelegate>

@property (nonatomic,assign) BOOL showSearchBar;//显示searchbar
- (instancetype)initWithUserInfo:(YHUserInfo *)userInfo;

@end
