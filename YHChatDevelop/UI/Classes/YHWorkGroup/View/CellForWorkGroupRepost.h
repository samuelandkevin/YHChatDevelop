//
//  CellForWorkGroupRepost.h
//  HKPTimeLine
//
//  Created by YHIOS002 on 16/9/20.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  转发视图

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"
#import "YHWorkGroupBottomView.h"
#import "YHWGTouchModel.h"

@class CellForWorkGroupRepost;
@protocol CellForWorkGroupRepostDelegate <NSObject>

- (void)onAvatarInRepostCell:(CellForWorkGroupRepost *)cell;
- (void)onTapRepostViewInCell:(CellForWorkGroupRepost *)cell;
- (void)onCommentInRepostCell:(CellForWorkGroupRepost *)cell;
- (void)onLikeInRepostCell:(CellForWorkGroupRepost *)cell;
- (void)onShareInRepostCell:(CellForWorkGroupRepost *)cell;
- (void)onDeleteInRepostCell:(CellForWorkGroupRepost *)cell;
- (void)onMoreInRespostCell:(CellForWorkGroupRepost *)cell;

@optional
- (void)onLinkInRepostCell:(CellForWorkGroupRepost *)cell linkType:(int)linkType linkText:(NSString *)linkText;
@end

@interface CellForWorkGroupRepost : UITableViewCell

@property (nonatomic) NSIndexPath *indexPath;
@property (weak,nonatomic) id<CellForWorkGroupRepostDelegate>delegate;
@property (nonatomic,strong) YHWorkGroup *model;
@property (nonatomic,strong) YHWorkGroupBottomView  *viewBottom;
@property (nonatomic,strong) YHWGTouchModel *touchModel;

- (void)showLikeAnimationWithLikeCount:(int)likeCount complete:(void(^)(BOOL finished))complete;
@end
