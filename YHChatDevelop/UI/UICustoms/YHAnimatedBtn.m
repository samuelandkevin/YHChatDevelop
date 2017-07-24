
//
#import "YHAnimatedBtn.h"


#define kNormalCol RGBCOLOR(196, 197, 198)
@interface YHAnimatedBtn(){
   
}

//渲染层
@property (nonatomic,strong) CAShapeLayer *maskLayer;

@property (nonatomic,strong) CAShapeLayer *shapeLayer;

@property (nonatomic,strong) CAShapeLayer *loadingLayer;//菊花

//@property (nonatomic,strong) CAShapeLayer *loadingBgLayer;//菊花的背景

@property (nonatomic,strong) CAShapeLayer *clickCicrleLayer;

@property (nonatomic,strong) UIButton *btnLogin;

@property (nonatomic,strong) void(^loadingBlock)();

@property (nonatomic,strong) UIBezierPath *bezierPath;//登录按钮path
@property (nonatomic,strong) UIBezierPath *bezierPathInCenter;//居中的登录按钮path
@end


@implementation YHAnimatedBtn


- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setup];
 
    }
    return self;
}

- (void)setup{
    
    [self bezierPathInCenter];
    
    [self bezierPath];
    
    [self shapeLayer];
    
    [self maskLayer];
    
    [self btnLogin];
    
}

#pragma mark - Public

- (void)setNormal{
    _btnLogin.hidden          = NO;
    _maskLayer.hidden         = NO;
    _shapeLayer.hidden        = NO;
    _loadingLayer.hidden      = NO;
    _clickCicrleLayer.hidden  = NO;
    _btnLogin.enabled         = NO;
    _shapeLayer.fillColor     = kNormalCol.CGColor;
}

- (void)setSelected{
    _btnLogin.hidden          = NO;
    _maskLayer.hidden         = NO;
    _shapeLayer.hidden        = NO;
    _loadingLayer.hidden      = NO;
//    _loadingBgLayer.hidden    = NO;
    _clickCicrleLayer.hidden  = NO;
    _btnLogin.enabled         = YES;
    _shapeLayer.fillColor     = kBlueColor.CGColor;
}

- (void)reset{
    [self hideLoading];
    [self setup];
    [self setSelected];

}

#pragma mark - Setter
- (void)setTitle:(NSString *)title{
    _title = title;
    [_btnLogin setTitle:self.title forState:UIControlStateNormal];
}

#pragma mark - Lazy Load

- (UIBezierPath *)bezierPath{
    if (!_bezierPath) {

        CGFloat radius = 5;
        CGFloat right  = self.bounds.size.width-radius;
        CGFloat left   = radius;
        
        _bezierPath = [self drawRectCornerWidthRaidus:radius leftArcAxisHorizontal:left rightArcAxisHorizontal:right];
    }
    return _bezierPath;
}

- (UIBezierPath *)bezierPathInCenter{
    if (!_bezierPathInCenter) {
        CGFloat radius = 5;
        CGFloat right  = self.bounds.size.width/2+(self.bounds.size.height/2-radius);
        CGFloat left   = self.bounds.size.width/2-self.bounds.size.height/2+radius;
        
        _bezierPathInCenter = [self drawRectCornerWidthRaidus:radius leftArcAxisHorizontal:left rightArcAxisHorizontal:right];
    }
    return _bezierPathInCenter;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {

        //遮罩layer
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.path        = _bezierPath.CGPath;
        _shapeLayer.fillColor   = kNormalCol.CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;

}

- (CAShapeLayer *)loadingLayer{
    if (!_loadingLayer) {
        _loadingLayer = [CAShapeLayer layer];
        _loadingLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _loadingLayer.fillColor   = [UIColor clearColor].CGColor;
        _loadingLayer.strokeColor = kBlueColor.CGColor;
        _loadingLayer.lineWidth   = 2;
        _loadingLayer.path = [self drawLoadingBezierPath].CGPath;
        [self.layer addSublayer:_loadingLayer];
    }
    return _loadingLayer;
}

//- (CAShapeLayer *)loadingBgLayer{
//    if (!_loadingBgLayer) {
//        
//        _loadingBgLayer = [CAShapeLayer layer];
//        _loadingBgLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//        _loadingBgLayer.fillColor   = [UIColor clearColor].CGColor;
//        _loadingBgLayer.strokeColor = [UIColor whiteColor].CGColor;
//        _loadingBgLayer.lineWidth   = 2;
//        _loadingBgLayer.path = [self drawLoadingBgBezierPath].CGPath;
//        [self.layer addSublayer:_loadingBgLayer];
//
//    }
//    return _loadingBgLayer;
//}

- (CAShapeLayer *)clickCicrleLayer{
    if (!_clickCicrleLayer) {
        CAShapeLayer *clickCicrleLayer = [CAShapeLayer layer];
        clickCicrleLayer.lineWidth = 10;
        clickCicrleLayer.frame = CGRectMake(self.bounds.size.width/2, self.bounds.size.height/2, 5, 5);
        clickCicrleLayer.fillColor   = [UIColor clearColor].CGColor;
        clickCicrleLayer.strokeColor = [UIColor whiteColor].CGColor;
        clickCicrleLayer.path = [self drawclickCircleBezierPath:0].CGPath;
        [self.layer addSublayer:clickCicrleLayer];
        
        //放大变色圆形
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration = 0.4;
        basicAnimation.toValue  = (__bridge id _Nullable)([self drawclickCircleBezierPath:(self.bounds.size.height - 10*2)/2].CGPath);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        [clickCicrleLayer addAnimation:basicAnimation forKey:@"clickCicrleAnimation"];
        
        _clickCicrleLayer = clickCicrleLayer;
    }
    return _clickCicrleLayer;
}

//遮罩layer
- (CAShapeLayer *)maskLayer{
    if(!_maskLayer){
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.opacity   = 0;
        _maskLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_maskLayer];
    }
    return _maskLayer;
}

- (UIButton *)btnLogin{
    if(!_btnLogin){
        _btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnLogin.frame = self.bounds;
        [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnLogin.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_btnLogin setTitle:self.title forState:UIControlStateNormal];
        [_btnLogin addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnLogin];
    }
    return _btnLogin;
}

#pragma mark - Action
- (void)onLogin:(id)sender{
    if(_onLoginBlock){
        _onLoginBlock();
    }
}

#pragma mark - Public
//显示菊花
- (void)showLoadingComplete:(void(^)())complete{
    _loadingBlock = complete;
    [self _clickAnimation];
}

//隐藏菊花
- (void)hideLoading{
    [_btnLogin  removeFromSuperview];
    [_maskLayer removeFromSuperlayer];
    [_shapeLayer removeFromSuperlayer];
    [_loadingLayer     removeFromSuperlayer];
//    [_loadingBgLayer   removeFromSuperlayer];
    [_clickCicrleLayer removeFromSuperlayer];
    _btnLogin         = nil;
    _maskLayer        = nil;
    _shapeLayer       = nil;
    _loadingLayer     = nil;
//    _loadingBgLayer   = nil;
    _clickCicrleLayer = nil;
    if (_loadingBlock) {
        _loadingBlock = nil;
    }
}


#pragma mark - Private
//点击出现白色圆形
- (void)_clickAnimation{

    [self clickCicrleLayer];
    CAAnimation *basicAnimation = [_clickCicrleLayer animationForKey:@"clickCicrleAnimation"];
    //执行下一个动画
    [self performSelector:@selector(_clickNextAnimation) withObject:self afterDelay:basicAnimation.duration];
    
}

//
- (void)_clickNextAnimation{
    //圆形变圆弧
    if (![_clickCicrleLayer animationForKey:@"clickCicrleAnimation1"]) {
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        
        //圆弧变大
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration = 0.2;
        basicAnimation.toValue = (__bridge id _Nullable)([self drawclickCircleBezierPath:(self.bounds.size.height - 10*2)].CGPath);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        //变透明
        CABasicAnimation *basicAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation1.beginTime = 0.10;
        basicAnimation1.duration  = 0.2;
        basicAnimation1.toValue   = @0;
        basicAnimation1.removedOnCompletion = NO;
        basicAnimation1.fillMode  = kCAFillModeForwards;
        
        animationGroup.duration = basicAnimation1.beginTime + basicAnimation1.duration;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.animations = @[basicAnimation,basicAnimation1];

        [_clickCicrleLayer addAnimation:animationGroup forKey:@"clickCicrleAnimation1"];
    }
    CAAnimation *animationGroup = [_clickCicrleLayer animationForKey:@"clickCicrleAnimation1"];
    [self performSelector:@selector(_startMaskAnimation) withObject:self afterDelay:animationGroup.duration];
    
}

//半透明的登录按钮的背景
- (void)_startMaskAnimation{
    
    _maskLayer.opacity   = 0.5;
    if (![_maskLayer animationForKey:@"maskAnimation"]) {
    
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration  = 0.25;

        basicAnimation.fromValue = (__bridge id _Nullable)(_bezierPathInCenter.CGPath);
        basicAnimation.toValue   = (__bridge id _Nullable)(_bezierPath.CGPath);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode  = kCAFillModeForwards;
        [_maskLayer addAnimation:basicAnimation forKey:@"maskAnimation"];
    }
    CAAnimation *basicAnimation = [_maskLayer animationForKey:@"maskAnimation"];
    [self performSelector:@selector(_dismissAnimation) withObject:self afterDelay:basicAnimation.duration+0.25];
}

//登录按钮合拢并消失（透明）
- (void)_dismissAnimation{
    [self _hiddenSubViews];
    
    
    if (![_shapeLayer animationForKey:@"dismissAnimation"]) {
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration  = 0.2;
        basicAnimation.fromValue = (__bridge id _Nullable)(_bezierPath.CGPath);
        basicAnimation.toValue   = (__bridge id _Nullable)(_bezierPathInCenter.CGPath);
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *basicAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation1.beginTime = 0.10;
        basicAnimation1.duration  = 0.2;
        basicAnimation1.toValue   = @0;
        basicAnimation1.removedOnCompletion = NO;
        basicAnimation1.fillMode = kCAFillModeForwards;
        
        animationGroup.animations = @[basicAnimation,basicAnimation1];
        animationGroup.duration = basicAnimation.duration+basicAnimation1.beginTime+basicAnimation1.duration;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        [_shapeLayer addAnimation:animationGroup forKey:@"dismissAnimation"];
    }
    CAAnimation *animationGroup  = [_shapeLayer animationForKey:@"dismissAnimation"];
    [self performSelector:@selector(_loadingAnimation) withObject:self afterDelay:animationGroup.duration];
}

//菊花
- (void)_loadingAnimation{
    
//    [self loadingBgLayer];
    [self loadingLayer];
    
    if (![_loadingLayer animationForKey:@"loadingAnimation"]) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        basicAnimation.fromValue = @(0);
        basicAnimation.toValue   = @(M_PI*2);
        basicAnimation.duration  = 0.7;
        basicAnimation.repeatCount = LONG_MAX;
        [_loadingLayer addAnimation:basicAnimation forKey:@"loadingAnimation"];
    }
    
    
//    if (![_loadingBgLayer animationForKey:@"loadingBgAnimation"]) {
//        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//        basicAnimation.fromValue = @(0);
//        basicAnimation.toValue   = @(M_PI*2);
//        basicAnimation.duration  = 0.7;
//        basicAnimation.repeatCount = LONG_MAX;
//        [_loadingBgLayer addAnimation:basicAnimation forKey:@"loadingBgAnimation"];
//    }
   
    
    //显示loading效果
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.loadingBlock) {
            weakSelf.loadingBlock();
        }
    });


}

- (void)_hiddenSubViews{
    _btnLogin.hidden         = YES;
    _maskLayer.hidden        = YES;
    _loadingLayer.hidden     = YES;
//    _loadingBgLayer.hidden   = YES;
    _clickCicrleLayer.hidden = YES;
}

- (CAShapeLayer *)drawMask:(CGFloat)x{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path  = [self drawBezierPath:x].CGPath;
    return shapeLayer;
}

//
- (UIBezierPath *)drawBezierPath:(CGFloat)x{
    CGFloat radius = self.bounds.size.height/2 - 3;
    CGFloat right  = self.bounds.size.width-x;
    CGFloat left   = x;

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineCapStyle  = kCGLineCapRound;
    //右边圆弧
    [bezierPath addArcWithCenter:CGPointMake(right, self.bounds.size.height/2) radius:radius startAngle:-M_PI/2 endAngle:M_PI/2 clockwise:YES];
    //左边圆弧
    [bezierPath addArcWithCenter:CGPointMake(left, self.bounds.size.height/2) radius:radius startAngle:M_PI/2 endAngle:-M_PI/2 clockwise:YES];
    //闭合弧线
    [bezierPath closePath];

    return bezierPath;
}


/**
 绘制矩形的四个圆角

 @param radius 圆角大小
 @param left 左边方向圆弧的水平坐标x
 @param right 右边方向圆弧的水平坐标x
 @return UIBezierPath
 */
- (UIBezierPath *)drawRectCornerWidthRaidus:(CGFloat)radius leftArcAxisHorizontal:(CGFloat)left rightArcAxisHorizontal:(CGFloat)right{
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineCapStyle  = kCGLineCapRound;
    //*******注意:添加圆弧的顺序不能错乱,否则显示异型********
    //右边两条圆弧
    [bezierPath addArcWithCenter:CGPointMake(right, radius) radius:radius startAngle:-M_PI/2+(M_PI/6) endAngle:-M_PI/2+(M_PI/3) clockwise:YES];
    [bezierPath addArcWithCenter:CGPointMake(right, self.bounds.size.height-5) radius:radius startAngle:(M_PI/6) endAngle:(M_PI/3) clockwise:YES];
    
    //左边两条圆弧
    [bezierPath addArcWithCenter:CGPointMake(left, self.bounds.size.height-5) radius:radius startAngle:M_PI/2+(M_PI/6) endAngle:M_PI/2+(M_PI/3) clockwise:YES];
    [bezierPath addArcWithCenter:CGPointMake(left, radius) radius:radius startAngle:M_PI+(M_PI/6) endAngle:M_PI+(M_PI/3) clockwise:YES];
    [bezierPath closePath];
    return bezierPath;
}

- (UIBezierPath *)drawLoadingBezierPath{
    CGFloat radius = self.bounds.size.height/2 + 5;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(0,0) radius:radius startAngle:M_PI/2 endAngle:(2*M_PI + M_PI/4)  clockwise:YES];
    return bezierPath;
}

- (UIBezierPath *)drawLoadingBgBezierPath{
    CGFloat radius = self.bounds.size.height/2 + 5;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(0,0) radius:radius startAngle:M_PI/4 endAngle:M_PI/2 clockwise:YES];
    return bezierPath;
}

//画圆
-(UIBezierPath *)drawclickCircleBezierPath:(CGFloat)radius{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    /**
     *  center: 弧线中心点的坐标
     radius: 弧线所在圆的半径
     startAngle: 弧线开始的角度值
     endAngle: 弧线结束的角度值
     clockwise: 是否顺时针画弧线
     *
     */
    [bezierPath addArcWithCenter:CGPointMake(0,0) radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    return bezierPath;
}

#pragma mark - Life
- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [_btnLogin setTitle:self.title forState:UIControlStateNormal];
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}
@end
