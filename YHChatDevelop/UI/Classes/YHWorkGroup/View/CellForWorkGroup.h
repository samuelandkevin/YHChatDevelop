//
//  CellForQAList.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/8/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  原创视图

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"
#import "YHWorkGroupBottomView.h"
#import "YHWGTouchModel.h"

@class CellForWorkGroup;
@protocol CellForWorkGroupDelegate <NSObject>

- (void)onAvatarInCell:(CellForWorkGroup *)cell;
- (void)onMoreInCell:(CellForWorkGroup *)cell;
- (void)onCommentInCell:(CellForWorkGroup *)cell;
- (void)onLikeInCell:(CellForWorkGroup *)cell;
- (void)onShareInCell:(CellForWorkGroup *)cell;

@optional
- (void)onDeleteInCell:(CellForWorkGroup *)cell;
- (void)onLinkInCell:(CellForWorkGroup *)cell linkType:(int)linkType linkText:(NSString *)linkText;
@end

@interface CellForWorkGroup : UITableViewCell

@property (nonatomic,strong) YHWorkGroup *model;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CellForWorkGroupDelegate> delegate;
@property (nonatomic,strong)YHWorkGroupBottomView  *viewBottom;
@property (nonatomic,strong)YHWGTouchModel *touchModel;


- (void)showLikeAnimationWithLikeCount:(int)likeCount complete:(void(^)(BOOL finished))complete;
@end
