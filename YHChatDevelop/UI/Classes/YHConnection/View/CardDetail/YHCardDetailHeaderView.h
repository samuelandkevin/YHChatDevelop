//
//  YHCardDetailHeaderView.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/6/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatDevelop-Swift.h"

@interface YHCardDetailHeaderView : UITableViewHeaderFooterView



typedef  void(^YHCardDetailHeaderViewExpandCallBack)(BOOL isExpanded);

@property (nonatomic,strong) UILabel *labelMainTitle;
@property (nonatomic,strong) UILabel *labelSubTitle;
@property (nonatomic,strong) UIImageView *imgvArrow;
@property (nonatomic,strong) UIView *botLine;
@property (nonatomic,strong) YHCardSection *model;
@property (nonatomic,copy) YHCardDetailHeaderViewExpandCallBack expandCallback;
@end
