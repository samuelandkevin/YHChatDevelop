//
//  MyDynamicViewController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/5/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"
#import "ZJScrollPageViewDelegate.h"

@interface MyDynamicViewController : UIViewController<ZJScrollPageViewChildVcDelegate>

@property (nonatomic,assign) BOOL showSearchBar;//显示searchbar
- (instancetype)initWithUserInfo:(YHUserInfo *)userInfo;

@end
