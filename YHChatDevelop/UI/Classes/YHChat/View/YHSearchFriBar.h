//
//  YHSearchFriBar.h
//  PikeWay
//
//  Created by kun on 16/10/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@protocol YHSearchFriBarDelegate <NSObject>

- (void)deSelectAvatarWithUserInfo:(YHUserInfo *)uid;


@end

@interface YHSearchFriBar : UIView

@property (nonatomic, strong) NSMutableArray <YHUserInfo *>*selFriArray;//选择的好友Array
@property (nonatomic, strong) NSMutableArray <UIImageView *>*selAvatarArray;//选中好友的图像View数组
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, weak)id <YHSearchFriBarDelegate>delegate;

- (void)setupScrollViewDidSel:(BOOL)didSel userInfo:(YHUserInfo *)userInfo;
@end
