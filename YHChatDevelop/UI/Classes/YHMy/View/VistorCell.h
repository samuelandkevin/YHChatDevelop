//
//  VistorCell.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/5/9.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@class VistorCell;
@protocol VistorCellDelegate <NSObject>

- (void)onAddFriendInCell:(VistorCell *)cell;

@end

@interface VistorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgvAddFriend;
@property (assign,nonatomic) NSIndexPath *indexPath;
@property (nonatomic,strong) YHUserInfo *userInfo;
@property (nonatomic,weak)id<VistorCellDelegate>delegate;
@end
