//
//  CellChatList.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@class YHChatListModel;
@interface CellChatList : SWTableViewCell

@property (nonatomic,strong) YHChatListModel *model;

//更新置顶/取消置顶状态
- (void)updateStickStatus:(BOOL)stick;
@end
