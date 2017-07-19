//
//  CellChatCheckinRight.h
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  签到cell

#import "CellChatBase.h"

@class CellChatCheckinRight;
@protocol CellChatCheckinRightDelegate <NSObject>

@optional
- (void)retweetImage:(UIImage *)image inRightCheckinCell:(CellChatCheckinRight *)rightCheckinCell;//转发图片
- (void)withDrawImage:(UIImage *)image inRightCheckinCell:(CellChatCheckinRight *)rightCheckinCell;//撤回图片

@end

@interface CellChatCheckinRight : CellChatBase

@property (nonatomic,weak)id<CellChatCheckinRightDelegate>delegate;

@end
