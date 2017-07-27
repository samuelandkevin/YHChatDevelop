//
//  YHSearchFriBar.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/10/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHSearchFriBar.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

#define kSearchBarH 44
#define kAvatarW (kSearchBarH*0.8)
#define kAvatarSpace (kSearchBarH*0.1)

@interface YHSearchFriBar()<UISearchBarDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollVSelFri;


@end

@implementation YHSearchFriBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    _scrollVSelFri = [[UIScrollView alloc] init];
    _scrollVSelFri.backgroundColor = kTbvBGColor;
    _scrollVSelFri.showsVerticalScrollIndicator = NO;
    _scrollVSelFri.showsHorizontalScrollIndicator = NO;
    _scrollVSelFri.delegate = self;
    [self addSubview:_scrollVSelFri];
    
    //去边框线
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = @"搜索";
    searchBar.layer.borderWidth = 1;
    searchBar.layer.borderColor = RGBCOLOR(240, 240, 240).CGColor;
    searchBar.barTintColor = RGBCOLOR(240, 240, 240);
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    [self addSubview:searchBar];
    _searchBar =searchBar;
    
    [self layoutUI];
}

- (void)layoutUI{
    
    WeakSelf
    [_scrollVSelFri mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.searchBar.mas_left);
        make.top.equalTo(weakSelf);
        make.height.mas_equalTo(kSearchBarH);
        make.width.mas_equalTo(0);
    }];
    
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf);
    }];

}


- (void)setupScrollViewDidSel:(BOOL)didSel userInfo:(YHUserInfo *)userInfo{
    ;
    
    if (didSel) {
        
        //设置新增头像的位置
        NSInteger newAvatarIndex = self.selAvatarArray.count;
        
        UIImageView *avtarImgV = [[UIImageView alloc] init];
        avtarImgV.userInteractionEnabled = YES;
        avtarImgV.layer.cornerRadius = kAvatarW/2.0;
        avtarImgV.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deSelectAvatar:)];
        [avtarImgV addGestureRecognizer:tapAvatar];
        avtarImgV.tag = [userInfo.uid integerValue];
        [avtarImgV sd_setImageWithURL:userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
        avtarImgV.frame = CGRectMake(newAvatarIndex*kSearchBarH+kAvatarSpace, kAvatarSpace, kAvatarW, kAvatarW);
        [self.scrollVSelFri  addSubview:avtarImgV];
        [self.selAvatarArray addObject:avtarImgV];
        
    }else{
        
        //移除scorllView中对应的头像
        for (UIImageView *imgV in self.scrollVSelFri.subviews) {
            if (imgV.tag == [userInfo.uid integerValue]) {
                [imgV removeFromSuperview];
                break;
            }
        }
        
        //删除选中数组的对应头像
        for (UIImageView *imgV in _selAvatarArray) {
            if (imgV.tag == [userInfo.uid integerValue]) {
                [_selAvatarArray removeObject:imgV];
                
                //重新调整所有选中头像的位置
                for (int i=0; i<_selAvatarArray.count; i++) {
                    UIImageView *imgv = _selAvatarArray[i];
                    imgv.frame = CGRectMake(i*kSearchBarH+kAvatarSpace, kAvatarSpace, kAvatarW, kAvatarW);
                }
                break;
            }
        }
        
        
    }
    
    NSInteger offsetIndex = self.selFriArray.count >5? 5:self.selFriArray.count;
    NSInteger offsetX = offsetIndex*kSearchBarH;
    
    _scrollVSelFri.contentSize = CGSizeMake(self.selFriArray.count*kSearchBarH, 0);
    WeakSelf
    [_scrollVSelFri mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(offsetX);
        
    }];
    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(offsetX);
    }];
    
    if (self.selFriArray.count > 5) {
        NSInteger contentOffsetX = (self.selFriArray.count - 5)*kSearchBarH;
        [_scrollVSelFri setContentOffset:CGPointMake(contentOffsetX, 0)];
    }

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    DDLog(@"%f",scrollView.contentOffset.x);
}

#pragma mark - Lazy Load
- (NSMutableArray<YHUserInfo *> *)selFriArray{
    if (!_selFriArray) {
        _selFriArray = [NSMutableArray array];
    }
    return _selFriArray;
}

- (NSMutableArray<UIImageView *> *)selAvatarArray{
    if (!_selAvatarArray) {
        _selAvatarArray = [NSMutableArray array];
    }
    return _selAvatarArray;
}

#pragma mark - Gesture
//取消选中头像
- (void)deSelectAvatar:(UITapGestureRecognizer *)gesture{
    UIImageView *imgv = (UIImageView *)[gesture view];

    if (_delegate && [_delegate respondsToSelector:@selector(deSelectAvatarWithUserInfo:)]) {
        
        for ( int i = 0; i < self.selFriArray.count; i++) {
            YHUserInfo *userInfo = self.selFriArray[i];
            if (imgv.tag == [userInfo.uid integerValue]) {
                userInfo.likeCount = 0;
                [_delegate deSelectAvatarWithUserInfo:userInfo];
                break;
            }
        }
        
       
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
