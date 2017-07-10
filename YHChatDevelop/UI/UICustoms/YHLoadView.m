//
//  YHLoadFailView.m
//  PikeWay
//
//  Created by YHIOS002 on 16/9/26.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHLoadView.h"
#import "Masonry.h"

//YHLoadView页面类型
typedef NS_ENUM(NSInteger,PageOptions){
    Page_Loading =1,
    Page_LoadFail
};

@interface YHLoadView()

@property(nonatomic,copy) void(^onReloadBlock)();
@property(nonatomic,assign) PageOptions page;
@property(nonatomic,strong) UIView *loading;
@end

@implementation YHLoadView

#pragma mark - Public
+ (instancetype)loadFail{
    YHLoadView *failView = [[YHLoadView alloc] initFailView];
    failView.hidden = YES;
    return failView;
}

+ (instancetype)loading{
    YHLoadView *loadingView = [[YHLoadView alloc] initLoadingView];
    loadingView.hidden = YES;
    return loadingView;
}

//显示加载失败
- (void)showLoadFailView{
    if (self.page == Page_LoadFail) {
        self.hidden = NO;
    }
    
}
//显示加载中
- (void)showLoadingView{
    if (self.page == Page_Loading) {
         self.hidden = NO;

        self.loading.hidden =NO;
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[self.loading viewWithTag:11];
        [indicator startAnimating];
        
        [self hideFailView];
    }
}

//隐藏加载失败
- (void)hideFailView{
    if (self.page == Page_LoadFail) {
        self.hidden = YES;
    }
}

//隐藏加载中
- (void)hideLoadingView{
    if (self.page == Page_Loading) {

        self.loading.hidden = YES;
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[self.loading viewWithTag:11];
        [indicator stopAnimating];
        self.hidden = YES;
        
        [self hideFailView];
    }
}

- (void)onReloadHandler:(void(^)())handler{
    self.onReloadBlock = handler;
}


#pragma mark - Life
- (void)layoutSubviews{
    
    self.bounds = CGRectMake(0, 0, 250, 200);
}


#pragma mark - Private

- (instancetype)initFailView{
    if(self = [super init]){
        self.page   = Page_LoadFail;
        [self setup];
    }
    return self;
}

- (instancetype)initLoadingView{
    if(self = [super init]){
         self.page   = Page_Loading;
        self.loading.hidden = NO;
        
    }
    return self;
}




#pragma mark - Fail View
- (void)setup{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yh_loading_error_page"]];
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = @"网络连接失败,请检查网络";
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    UIButton *btnReLoad = [UIButton new];
    [btnReLoad setTitle:@"重新加载" forState:UIControlStateNormal];
    [btnReLoad setBackgroundColor:kBlueColor];
    btnReLoad.layer.cornerRadius  = 5;
    btnReLoad.layer.masksToBounds = YES;
    [btnReLoad addTarget:self action:@selector(onReload:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnReLoad];
    
    WeakSelf
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(105.5);
        make.height.mas_equalTo(75.5);
        make.top.equalTo(weakSelf);
        make.centerX.equalTo(weakSelf);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(15);
        make.width.equalTo(weakSelf);
        make.centerX.equalTo(weakSelf);
    }];
    
    [btnReLoad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
    }];

}


#pragma mark - LoadingView

- (UIView *)loading{
    if (!_loading) {
        _loading = [[UIView alloc] init];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"加载中...";
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor blackColor];
        label.backgroundColor   = [UIColor clearColor];
        label.textAlignment     = NSTextAlignmentLeft;
        
        [_loading addSubview:indicator];
        [_loading addSubview:label];
        indicator.tag   = 11;
        label.tag       = 12;
        
        [self addSubview:_loading];
        
        WeakSelf
        [_loading mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(weakSelf);
            make.left.top.equalTo(weakSelf);
        }];
        
        [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf.loading.mas_centerX).offset(-20);
            make.centerY.equalTo(weakSelf.loading);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(indicator);
            make.left.equalTo(indicator.mas_right).offset(5);
        }];
    }
    return _loading;
}

#pragma mark - Action

- (void)onReload:(id)sender{
    if (_onReloadBlock) {
        _onReloadBlock();
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
