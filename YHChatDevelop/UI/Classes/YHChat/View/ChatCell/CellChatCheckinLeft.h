//
//  CellChatCheckinLeft.h
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  签到cell

#import "CellChatBase.h"

@class CellChatCheckinLeft;

@protocol CellChatCheckinLeftDelegate <NSObject>

@optional
- (void)retweetImage:(UIImage *)image inLeftCheckinCell:(CellChatCheckinLeft *)leftCheckinCell;//转发图片

@end

@interface CellChatCheckinLeft : CellChatBase

@property (nonatomic,weak)id<CellChatCheckinLeftDelegate>delegate;

@end
