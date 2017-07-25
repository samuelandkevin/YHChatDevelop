//
//  YHTipsView.m
//  YHChat
//
//  Created by samuelandkevin on 16/6/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHTipsView.h"
#import "Masonry.h"

#define  kEdge_TipsBG       10
#define  kMaxWidth_TipsView (SCREEN_WIDTH-60-(2*kEdge_TipsBG)) //提示文字的最大宽度
@interface YHTipsView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView * viewTipsBG;
@end

@implementation YHTipsView

/*
 *  // Only override drawRect: if you perform custom drawing.
 *  // An empty implementation adversely affects performance during animation.
 *  - (void)drawRect:(CGRect)rect {
 *   // Drawing code
 *  }
 */
- (instancetype)init
{
    if (self = [super init])
    {
        
        self.userInteractionEnabled = YES;
        
        //tipsLabel
        self.tipsLabel               = [[UILabel alloc] init];
        self.tipsLabel.textColor     = [UIColor whiteColor];
        self.tipsLabel.numberOfLines = 0;
        self.tipsLabel.preferredMaxLayoutWidth = kMaxWidth_TipsView;
        self.tipsLabel.font          = [UIFont systemFontOfSize:13.0f];
        
        //tipslabel的背景
        self.viewTipsBG                     = [[UIView alloc] init];
        self.viewTipsBG.backgroundColor     = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.viewTipsBG.layer.cornerRadius  = 5;
        self.viewTipsBG.layer.masksToBounds = YES;
        
        
        [self addSubview:self.viewTipsBG];
        [self addSubview:self.tipsLabel];
        
        WeakSelf
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf);
        }];
        
        [self.viewTipsBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.tipsLabel.mas_top).offset(-kEdge_TipsBG);
            make.bottom.equalTo(weakSelf.tipsLabel.mas_bottom).offset(kEdge_TipsBG);
            make.left.equalTo(weakSelf.tipsLabel.mas_left).offset(-kEdge_TipsBG);
            make.right.equalTo(weakSelf.tipsLabel.mas_right).offset(kEdge_TipsBG);
        }];
        
    }
    return self;
}

#pragma mark - Getter
- (UITapGestureRecognizer *)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:_tapGesture];
    }
    return _tapGesture;
}

- (void)onTap{
    [self hide];
}

#pragma mark - Setter
- (void)setTips:(NSString *)tips
{
    _tips = tips;
    self.tipsLabel.text = _tips;
    
}

#pragma mark - Public
- (void)showTouchHide:(BOOL)touchHide msg:(NSString *)msg{
    
    UIWindow *statusBarWindow = [self statusBarWindow];
    for (int i=0; i<statusBarWindow.subviews.count; i++) {
        UIView *subV = statusBarWindow.subviews[i];
        if ([subV isKindOfClass:[YHTipsView class]]) {
            [subV removeFromSuperview];
        }
    }
    
    [statusBarWindow addSubview:self];
    
    CGFloat maxW = kMaxWidth_TipsView;
    //    CGFloat addFont = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    CGFloat height = [msg boundingRectWithSize:CGSizeMake(maxW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:self.tipsLabel.font.pointSize]  } context:nil].size.height+5;
    
    WeakSelf
    [_tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
        make.center.equalTo(weakSelf);
    }];
    
    
    self.alpha  = 0.5;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height+2*kEdge_TipsBG);
        make.center.equalTo(statusBarWindow);
    }];
    
    
    [self.layer setValue:@(0) forKeyPath:@"transform.scale"];
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [weakSelf.layer setValue:@(1) forKeyPath:@"transform.scale"];
        weakSelf.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    
    if (touchHide)
    {
        
        if (!_tapGesture)
        {
            _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
            [self addGestureRecognizer:_tapGesture];
        }
    }
    else
    {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
        
    }
    
}

#pragma mark - Private
- (UIWindow *)statusBarWindow
{
    return [[UIApplication sharedApplication] valueForKey:@"_statusBarWindow"];
}

- (void)hide
{
    [self removeFromSuperview];
}


#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
