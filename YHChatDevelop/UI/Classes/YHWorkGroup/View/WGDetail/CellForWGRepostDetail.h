//
//  CellForWGRepostDetail.h
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"
#import "YHWorkGroupBottomView.h"

@class CellForWGRepostDetail;
@protocol CellForWGRepostDetailDelegate <NSObject>

- (void)onAvatarInWGRepostDetailCell:(CellForWGRepostDetail *)cell;
- (void)onTapRepostViewInWGRepostDetailCell:(CellForWGRepostDetail *)cell;
- (void)onDeleteInWGRepostDetailCell:(CellForWGRepostDetail *)cell;
- (void)onMoreInWGRepostDetailCell:(CellForWGRepostDetail *)cell;

@optional
- (void)onLinkInWGRepostDetailCell:(CellForWGRepostDetail *)cell linkType:(int)linkType linkText:(NSString *)linkText;
@end

@interface CellForWGRepostDetail : UITableViewCell

@property (nonatomic) NSIndexPath *indexPath;
@property (weak,nonatomic) id<CellForWGRepostDetailDelegate>delegate;
@property (nonatomic,strong) YHWorkGroup *model;

@end
