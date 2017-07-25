//
//  YHWGSegmentView.m
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWGSegmentView.h"
#import "Masonry.h"

#define  kDefaultCol RGBCOLOR(120, 120, 120)
#define  kSelCol RGBCOLOR(0, 0, 0)

@interface YHWGSegmentView(){
    NSInteger _selIndex;
}
@property (nonatomic,strong) UIView *viewTopLine;//顶部横线
@property (nonatomic,strong) UIView *viewVLine1;//竖线1
@property (nonatomic,strong) UIView *viewVLine2;//竖线2
@property (nonatomic,strong) UIView *viewBotSepLine;//底部分隔线
@end

@implementation YHWGSegmentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    _selIndex = 0;
    self.backgroundColor = [UIColor whiteColor];
    
    
    UIView *viewTopLine = [UIView new];
    viewTopLine.backgroundColor = kSeparatorLineColor;
    [self addSubview:viewTopLine];
    self.viewTopLine = viewTopLine;
    
    //评论
    UIButton *btnComment = [UIButton new];
    [btnComment addTarget:self action:@selector(onBtn:) forControlEvents:UIControlEventTouchUpInside];
    btnComment.tag = 100;
    [self addSubview:btnComment];
    self.btnComment = btnComment;
    
    self.lbComment = [UILabel new];
    self.lbComment.font = [UIFont systemFontOfSize:13.0f];
    self.lbComment.textColor = kDefaultCol;
    self.lbComment.text = @"评论";
    [self addSubview:self.lbComment];
    
    self.lbComCount = [UILabel new];
    self.lbComCount.font = [UIFont systemFontOfSize:13.0f];
    self.lbComCount.text = @"0";
    self.lbComCount.textColor = kDefaultCol;
    [self addSubview:self.lbComCount];
    
    
    UIView *viewVLine1 = [UIView new];
    [self addSubview:viewVLine1];
    viewVLine1.backgroundColor = kSeparatorLineColor;
    self.viewVLine1 = viewVLine1;
    
    //点赞
    UIButton *btnLike = [UIButton new];
    [self addSubview:btnLike];
    [btnLike addTarget:self action:@selector(onBtn:) forControlEvents:UIControlEventTouchUpInside];
    btnLike.tag = 101;
    self.btnLike = btnLike;
    
    self.lbLike = [UILabel new];
    self.lbLike.font = [UIFont systemFontOfSize:13.0f];
    self.lbLike.text = @"赞";
    self.lbLike.textColor = kDefaultCol;
    [self addSubview:self.lbLike];
    
    self.lbLikeCount = [UILabel new];
    self.lbLikeCount.font = [UIFont systemFontOfSize:13.0f];
    self.lbLikeCount.text = @"0";
    self.lbLikeCount.textColor = kDefaultCol;
    [self addSubview:self.lbLikeCount];
    
    
    UIView *viewVLine2 = [UIView new];
    [self addSubview:viewVLine2];
    viewVLine2.backgroundColor = kSeparatorLineColor;
    self.viewVLine2 = viewVLine2;
    
    //分享
    UIButton *btnShare = [UIButton new];
    [btnShare addTarget:self action:@selector(onBtn:) forControlEvents:UIControlEventTouchUpInside];
    btnShare.tag = 102;
    [self addSubview:btnShare];
    self.btnShare = btnShare;
    
    self.lbShare = [UILabel new];
    self.lbShare.font = [UIFont systemFontOfSize:13.0f];
    self.lbShare.text = @"分享";
    self.lbShare.textColor = kDefaultCol;
    [self addSubview:self.lbShare];
    
    self.lbShareCount = [UILabel new];
    self.lbShareCount.font = [UIFont systemFontOfSize:13.0f];
    self.lbShareCount.text = @"0";
    self.lbShareCount.textColor = kDefaultCol;
    [self addSubview:self.lbShareCount];
    
    
    //底部线(指示器)
    UIView *viewBotLine = [UIView new];
    viewBotLine.backgroundColor = kBlueColor;
    [self addSubview:viewBotLine];
    self.viewBotLine = viewBotLine;
    
    UIView *viewBotSepLine = [UIView new];
    viewBotSepLine.backgroundColor = kSeparatorLineColor;
    [self addSubview:viewBotSepLine];
    self.viewBotSepLine = viewBotSepLine;
    
    [self layoutUI];
    
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    
    [self.btnComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(weakSelf);
        make.width.equalTo(weakSelf.mas_width).dividedBy(3);
    }];
    
    [self.lbComment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.centerX.equalTo(weakSelf.btnComment.mas_centerX).offset(-5);
    }];
    
    [self.lbComCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.left.equalTo(weakSelf.lbComment.mas_right).offset(5);
        make.right.equalTo(weakSelf.btnComment.mas_right);
    }];
    
    [self.lbComCount setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.lbComCount setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.btnLike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnComment.mas_right);
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.width.mas_equalTo(weakSelf.btnComment.mas_width);
        make.height.equalTo(weakSelf.btnComment.mas_height);
    }];
    
    [self.lbLike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnLike.mas_centerY);
        make.centerX.equalTo(weakSelf.btnLike.mas_centerX).offset(-5);
    }];
    
    [self.lbLikeCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnLike.mas_centerY);
        make.left.equalTo(weakSelf.lbLike.mas_right).offset(5);
        make.right.equalTo(weakSelf.btnLike.mas_right);
    }];
    
    [self.lbLikeCount setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.lbLikeCount setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.btnShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnLike.mas_right);
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.width.mas_equalTo(weakSelf.btnComment.mas_width);
        make.height.mas_equalTo(weakSelf.btnComment.mas_height);
    }];
    
    [self.lbShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnShare.mas_centerY);
        make.centerX.equalTo(weakSelf.btnShare.mas_centerX).offset(-5);
    }];

    [self.lbShareCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.btnShare.mas_centerY);
        make.left.equalTo(weakSelf.lbShare.mas_right).offset(5);
        make.right.equalTo(weakSelf.btnShare.mas_right);
    }];
    
    [self.lbShareCount setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.lbShareCount setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.viewTopLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf);
        make.left.right.equalTo(weakSelf);
        make.height.mas_equalTo(0.5);
    }];
    
    
    
    [self.viewVLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.right.equalTo(weakSelf.btnComment.mas_right);
        make.height.equalTo(weakSelf.mas_height).multipliedBy(0.8);
    }];
    
    [self.viewVLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.centerY.equalTo(weakSelf.btnComment.mas_centerY);
        make.right.equalTo(weakSelf.btnLike.mas_right);
        make.height.equalTo(weakSelf.viewVLine1.mas_height);
    }];
    
    [self.viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
        make.width.mas_equalTo(weakSelf.btnComment.mas_width);
        make.height.mas_equalTo(2);
    }];
    
    [self.viewBotSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf);
        make.height.mas_equalTo(0.5);
    }];
    
}

#pragma mark - Private
- (void)moveLineWithTag:(NSInteger)tag{
    NSInteger currentIndex = tag-100;
    if (currentIndex != _selIndex) {
        NSInteger curPosX = _selIndex*(self.frame.size.width/3);
        NSInteger offsetX = (currentIndex - _selIndex)*(self.frame.size.width/3);
        NSInteger resultPosX = curPosX + offsetX;
        WeakSelf
        [self.viewBotLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).offset(resultPosX);
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
    _selIndex = currentIndex;
}

#pragma mark - Public
- (void)setSelIndex:(NSInteger)selIndex{
    _selIndex = selIndex+100;
    [self showSelBtn:_selIndex];
    
     [_zjDelegate childViewController:nil forIndex:selIndex];
}

#pragma mark - Action
- (void)onBtn:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(fromIndex:toIndex:)]) {
        [_delegate fromIndex:_selIndex toIndex:(sender.tag-100)];
    }
    
    [self showSelBtn:sender.tag];
}

- (void)showSelBtn:(NSInteger)tag{
    //resetColor
    self.lbComCount.textColor = self.lbComment.textColor = self.lbLike.textColor = self.lbLikeCount.textColor = self.lbShare.textColor = self.lbShareCount.textColor = kDefaultCol;
    switch (tag) {
        case 100:
            self.lbComCount.textColor = self.lbComment.textColor = kSelCol;
            break;
        case 101:
            self.lbLike.textColor = self.lbLikeCount.textColor = kSelCol;
            break;
        case 102:
            self.lbShare.textColor = self.lbShareCount.textColor = kSelCol;
            break;
        default:
            break;
    }
    
    [self moveLineWithTag:tag];
}

- (void)onShare:(UIButton *)sender{
    [self moveLineWithTag:sender.tag];

    if (_delegate && [_delegate respondsToSelector:@selector(onShareInSegView)]) {
        [_delegate onShareInSegView];
    }
    
}

- (void)onLike:(UIButton *)sender{
    [self moveLineWithTag:sender.tag];
    sender.selected = !sender.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(onLikeInSegView)]) {
        [_delegate onLikeInSegView];
    }
}

- (void)onComment:(UIButton *)sender{
    [self moveLineWithTag:sender.tag];
    if (_delegate && [_delegate respondsToSelector:@selector(onCommentInSegView)]) {
        [_delegate onCommentInSegView];
    }
}

@end
