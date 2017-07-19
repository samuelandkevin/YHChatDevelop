//
//  YHCheckinBtn.m
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHCheckinBtn.h"

@interface YHCheckinBtn()
@property(nonatomic,assign) CGFloat imgW;
@property(nonatomic,assign) CGFloat imgH;
@property(nonatomic,assign) CGFloat margin; //图片与文字的间距
@property(nonatomic,assign) CGFloat labelH;
@end

@implementation YHCheckinBtn

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imgW   = 13;
        _imgH   = 13;
        _margin = 0;
        _labelH = 13;
        self.layer.cornerRadius  = 3;
        self.layer.masksToBounds = YES;
        self.backgroundColor     = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"chat_location" ] forState:UIControlStateNormal];
        [self setTitle:@"签到" forState:UIControlStateNormal];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//1.重写方法,改变图片的位置,在titleRect..方法后执行
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    
    CGFloat imageX  = 0;
    CGFloat imageY  = (self.bounds.size.height - _imgH)/2;
    CGFloat width   = _imgW;
    CGFloat height  = _imgH;
    return CGRectMake(imageX, imageY, width, height);
    
}

//2.改变title文字的位置,构造title的矩形即可
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    
    CGFloat titleX = CGRectGetMaxX(self.imageView.frame) + _margin;
    CGFloat titleY = (self.bounds.size.height - _labelH)/2;
    CGFloat width  = self.bounds.size.width - titleX;
    CGFloat height = _labelH;
    return CGRectMake(titleX, titleY, width, height);
    
}

- (void)setHighlighted:(BOOL)highlighted{

}

@end
