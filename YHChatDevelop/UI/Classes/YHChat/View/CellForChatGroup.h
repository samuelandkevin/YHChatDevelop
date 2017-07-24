//
//  CellForChatGroup.h
//  PikeWay
//
//  Created by YHIOS002 on 17/1/18.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatGroupModel.h"
//note:cell被页面重用!!
@class CellForChatGroup;
@protocol CellForChatGroupDelegate <NSObject>

- (void)didSelectOneGroup:(BOOL)didSel inCell:(CellForChatGroup *)cell;

@end

@interface CellForChatGroup : UITableViewCell

@property (strong,nonatomic) YHChatGroupModel *model;
@property (weak,nonatomic)id <CellForChatGroupDelegate>delegate;
@property (nonatomic,strong) UIImageView *imgvSel;
@property (nonatomic,strong) UIButton *btnTapScope;
@property (nonatomic,assign) BOOL isOnlyShowGroup;//仅仅显示群,不显示勾选
@property (nonatomic) NSIndexPath *indexPath;
@end
