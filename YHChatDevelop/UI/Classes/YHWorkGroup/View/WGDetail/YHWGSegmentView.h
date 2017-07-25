//
//  YHWGSegmentView.h
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJScrollPageViewDelegate.h"

@class YHWGSegmentView;

@protocol YHWGSegmentViewDelegate <NSObject>

- (void)onCommentInSegView;
- (void)onLikeInSegView;
- (void)onShareInSegView;
- (void)fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end

@interface YHWGSegmentView : UIView

@property (nonatomic,strong)UIButton *btnComment;
@property (nonatomic,strong)UIButton *btnLike;
@property (nonatomic,strong)UIButton *btnShare;
@property (nonatomic,strong)UILabel *lbComment;
@property (nonatomic,strong)UILabel *lbComCount;
@property (nonatomic,strong)UILabel *lbLike;
@property (nonatomic,strong)UILabel *lbLikeCount;
@property (nonatomic,strong)UILabel *lbShare;
@property (nonatomic,strong)UILabel *lbShareCount;

@property (nonatomic,strong)UIView *viewBotLine;//底部线(指示器)

@property (nonatomic,weak)id<YHWGSegmentViewDelegate>delegate;
@property(weak, nonatomic)id<ZJScrollPageViewDelegate> zjDelegate;
- (void)setSelIndex:(NSInteger)selIndex;
@end