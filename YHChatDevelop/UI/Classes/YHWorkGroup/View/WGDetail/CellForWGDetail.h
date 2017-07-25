//
//  CellForWGDetail.h
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"
#import "YHWorkGroupBottomView.h"

@class CellForWGDetail;
@protocol CellForWGDetailDelegate <NSObject>

- (void)onAvatarInWGDetailCell:(CellForWGDetail *)cell;
- (void)onMoreInWGDetailCell:(CellForWGDetail *)cell;

@optional
- (void)onDeleteInWGDetailCell:(CellForWGDetail *)cell;
- (void)onLinkInWGDetailCell:(CellForWGDetail *)cell linkType:(int)linkType linkText:(NSString *)linkText;
@end

@interface CellForWGDetail : UITableViewCell

@property (nonatomic,strong) YHWorkGroup *model;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic, weak) id<CellForWGDetailDelegate> delegate;


@end
