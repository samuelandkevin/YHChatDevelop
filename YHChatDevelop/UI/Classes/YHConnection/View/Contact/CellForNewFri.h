//
//  CellForNewFri.h
//  PikeWay
//
//  Created by YHIOS002 on 17/1/14.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@class CellForNewFri;
@protocol CellForNewFriDelegate <NSObject>

//接受对方的好友请求
- (void)onAccepetNewFriendInCell:(CellForNewFri *)cell;

@end

@interface CellForNewFri : UITableViewCell

@property (strong, nonatomic)  UIButton *btnAccept;    //接受
@property (strong, nonatomic)  UILabel *labelAddReq;   //添加请求理由
@property (assign, nonatomic)  NSIndexPath *indexPath;
@property (strong,nonatomic)   YHUserInfo *model;
@property (weak, nonatomic)    id<CellForNewFriDelegate>delegate;

@end
