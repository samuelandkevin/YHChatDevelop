//
//  YHCellWave.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/4/19.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHCellWave.h"

@interface YHCellWave()<CAAnimationDelegate>{
    NSTimeInterval duration;
}

@property (nonatomic,strong)CAShapeLayer *waveLayer;
@property (nonatomic,assign)CGPoint centerTouch;//点击中心
@property (nonatomic,assign)CGFloat waveRadius; //波纹半径
@property (nonatomic,copy)  void(^complete)(BOOL finished);

@end

@implementation YHCellWave

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupCommon];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupCommon];
    }
    return self;
}

- (void)setupCommon{
    duration = 0.25;
    
    _waveLayer = [CAShapeLayer new];
    _waveLayer.backgroundColor  = [UIColor clearColor].CGColor;
    _waveLayer.opacity          = 0.6;
    _waveLayer.fillColor        = kBlueColor.CGColor;
    [self.contentView.layer addSublayer:_waveLayer];
}

- (void)startAnimation:(void(^)(BOOL finished))complete{
    _complete = complete;
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithArcCenter:_centerTouch radius:_waveRadius*0.2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:_centerTouch radius:_waveRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.delegate   = self;
    
    CABasicAnimation *rippleAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    rippleAnimation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    rippleAnimation.toValue   = (__bridge id _Nullable)(endPath.CGPath);
    rippleAnimation.duration  = duration;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.6];
    opacityAnimation.toValue   = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration  = duration;
    
    groupAnimation.animations = @[rippleAnimation,opacityAnimation];
    [_waveLayer addAnimation:groupAnimation forKey:@"groupAnimation"];

}


#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    _centerTouch = [touch locationInView:self.contentView];
    
    //波纹的最大半径
    CGFloat maxRadius = self.contentView.frame.size.height/2;
    
    //波纹的实际半径
    CGFloat axisX = fabs(self.contentView.frame.size.width - _centerTouch.x);
    if (_centerTouch.x < maxRadius) {
        axisX = _centerTouch.x;
    }
    CGFloat axixY = fabs(self.contentView.frame.size.height - _centerTouch.y);
    if (_centerTouch.y < maxRadius) {
        axixY = _centerTouch.y;
    }
    
    if (axisX > maxRadius && axixY > maxRadius) {
        _waveRadius = maxRadius;
    }else{
        _waveRadius = MIN(axisX, axixY);
    }
    
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag ) {
        if (_complete) {
            _complete(YES);
        }
    }
    
}

#pragma mark - Life
- (void)dealloc{
    DDLog(@"YHCellWave is dealoc");
}


@end
