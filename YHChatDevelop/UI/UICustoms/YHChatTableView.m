//
//  YHChatTableView.m
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatTableView.h"
#import "Masonry.h"

NSString *const YHChatTableViewKeyPathContentOffset = @"contentOffset";
const CGFloat YHChatTableViewHeaderViewHeight = 40;

@interface YHChatTableView()

@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,strong)UIActivityIndicatorView *activity;
@property (nonatomic,assign)BOOL isRefreshing;
@property (nonatomic,assign)BOOL isNoMoreData;
@end

@implementation YHChatTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - init
- (instancetype)init{
    if (self = [super init]) {
        [self _setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self _setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self _setupUI];
    }
    return self;
}


#pragma mark - Private

- (void)_setupUI{
    
    _headerView = [UIView new];
    _headerView.backgroundColor = [UIColor clearColor];
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_headerView addSubview:_activity];
    
    self.tableHeaderView = _headerView;
    _headerView.hidden = YES;
    
    [self addObservers];
    
    [self _layoutUI];
}

- (void)_layoutUI{
     WeakSelf
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(weakSelf.mas_width);
        make.height.mas_equalTo(YHChatTableViewHeaderViewHeight);
    }];
    
    [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.headerView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

#pragma mark - Public
//开始加载
- (void)loadBegin{
    _headerView.hidden = NO;
    [_activity startAnimating];
    _isRefreshing = YES;
}

//结束加载
- (void)loadFinish{
    [_activity stopAnimating];
    _headerView.hidden = YES;
    _isRefreshing = NO;
}

//没有更多数据
- (void)setNoMoreData{
    [self loadFinish];
    _isNoMoreData = YES;
    [self setContentInset:UIEdgeInsetsMake(-YHChatTableViewHeaderViewHeight, 0, 0, 0)];
}

#pragma mark - KVO
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self addObserver:self forKeyPath:YHChatTableViewKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers
{
    [self removeObserver:self forKeyPath:YHChatTableViewKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:YHChatTableViewKeyPathContentOffset]) {
        if (self.contentOffset.y <0  && !_isRefreshing && !_isNoMoreData){
            _isRefreshing = YES;
            [self loadBegin];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadMoreData)]) {
                    [_refreshDelegate loadMoreData];
                }
            });
            
        }
    }
}


#pragma mark - Life
- (void)dealloc{
    [self removeObservers];
}


#pragma mark - Setter
- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}

@end
