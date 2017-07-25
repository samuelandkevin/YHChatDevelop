//
//  CellForComment.h
//  PikeWay
//
//  Created by YHIOS002 on 16/5/7.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TTTAttributedLabel.h"
#import "YHCommentData.h"


@class CellForComment;
@class CellForLikePeople;

@protocol CellForCommentDelegate <NSObject>

- (void)onTapAvatar:(CellForComment *)cell;

- (void)longPressInCell:(CellForComment *)cell;

@optional
- (void)onReplyUserInCell:(CellForComment *)cell;
- (void)onLinkInCommentCell:(CellForComment *)cell linkType:(int)linkType linkText:(NSString *)linkText;
@end

@interface CellForComment : UITableViewCell

@property (weak, nonatomic) id<CellForCommentDelegate> delegate;
@property (strong,nonatomic)YHCommentData *model;
@property (nonatomic) NSIndexPath *indexPath;
@end

