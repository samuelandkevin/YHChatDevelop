//
//  CellForMyFri.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"
#import "YHCellWave.h"

@class CellForMyFri;
@protocol CellForMyFriDelegate <NSObject>

- (void)didSelectOneFriend:(BOOL)didSel inCell:(CellForMyFri *)cell;

@end

@interface CellForMyFri : YHCellWave

@property (strong,nonatomic) YHUserInfo *model;
@property (weak,nonatomic)id <CellForMyFriDelegate>delegate;
@property (nonatomic,strong) UIImageView *imgvSel;
@property (nonatomic,strong) UIButton *btnTapScope;
@property (nonatomic,assign) BOOL     isInviteFrisToGroupChat;//邀请好友到群聊
//@property (nonatomic) NSIndexPath *indexPath;
@end
