//
//  YHSharePresentView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/27.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHSharePresentView.h"
//#import "YHSocialShareManager.h"
#import "Masonry.h"

#define kPopViewBGColor RGBCOLOR(224.0f, 224.0f, 224.0f)       //collectionView背景颜色
#define kMaskBGColor [[UIColor blackColor] colorWithAlphaComponent:0.5] //遮罩背景颜色
#define kTextColor [UIColor blackColor]


//collectionview边距
static const CGFloat kLSpace = 10.0f;//左
static const CGFloat kRSpace = 10.0f;//右
static const CGFloat kTSpace = 15.0f;//上
static const CGFloat kBSpace = 10.0f;//下
static const CGFloat kLineSpace  = 15.0f;//行边距

static const CGFloat kTitleH     = 30.0f;
static const CGFloat kCancelBtnH = 55.0f;      //取消按钮高度
static const CGFloat kIconW    = 55.0f;        //图标宽(默认宽高相等)
static const CGFloat kFontSize = 10.0f;     //字体大小
static const int     kNumberOfItemsInRow = 4; //一行显示的items数量
#define kItemH (kIconW+20)                    //item高度

@interface ColCellForShareItem : UICollectionViewCell
@property (nonatomic,strong) UILabel *lbItemName;
@property (nonatomic,strong) UIImageView *imgvIcon;
@property (nonatomic,strong) NSDictionary *dictConfig;
@end

@implementation ColCellForShareItem


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
     
    }
    return self;
}

- (void)setup{
    UIImageView *imgvIcon = [UIImageView new];
    [self.contentView addSubview:imgvIcon];
    _imgvIcon = imgvIcon;
    
    
    UILabel *lbItemName = [UILabel new];
    lbItemName.font = [UIFont systemFontOfSize:kFontSize];
    lbItemName.textColor = kTextColor;
    lbItemName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:lbItemName];
    _lbItemName = lbItemName;
    
    [self layoutUI];
    
}

- (void)layoutUI{
    WeakSelf
    [_imgvIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.width.height.mas_equalTo(kIconW);
        make.bottom.equalTo(weakSelf.lbItemName.mas_top).offset(-5);
    }];
    
    [_lbItemName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.contentView);
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.width.equalTo(weakSelf.contentView.mas_width).multipliedBy(0.9);
    }];
}

#pragma mark - Setter
- (void)setDictConfig:(NSDictionary *)dictConfig{
    _dictConfig = dictConfig;
    
    CGFloat fontSize  = [_dictConfig[@"fontSize"] floatValue];
    if (fontSize) {
        _lbItemName.font = [UIFont systemFontOfSize:fontSize];
    }
    
    CGFloat cancelBtnH  =[_dictConfig[@"cancelBtnH"] floatValue];
    if (cancelBtnH) {
        
    }
    UIColor *textColor  =_dictConfig[@"textColor"];
    _lbItemName.textColor = textColor;
    
    
    
}

@end

@interface YHFLayoutShareItem : UICollectionViewFlowLayout

@end

@implementation YHFLayoutShareItem


- (void)prepareLayout{
    
    self.sectionInset = UIEdgeInsetsMake(kTSpace, kLSpace, kBSpace, kRSpace);
    CGFloat itemW = (SCREEN_WIDTH - kLSpace - kRSpace)/4;
    self.itemSize = CGSizeMake(itemW, kItemH);
    self.minimumLineSpacing      = kLineSpace;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

@end


@interface YHSharePresentView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UIView *viewTitle;//标题View
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UILabel *lbCancel;
@property (nonatomic,strong) UIView *viewBG;
@property (nonatomic,strong) UIButton *btnCustomCancel;
@property (nonatomic,strong) UIView *viewCancelContainer;
@property (nonatomic,strong) NSMutableArray *itemHiddenArray;
//标记变量
@property (nonatomic,copy) DismissBlock dBlock;
@property (nonatomic,assign) CGFloat popViewH;
@property (nonatomic,strong) NSDictionary *dictConfig;
@end

@implementation YHSharePresentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return  self;
}

- (void)setup{
    
    
    UIView *viewBG = [UIView new];
//    viewBG.backgroundColor = kMaskBGColor;
    viewBG.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapViewBG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
    [viewBG addGestureRecognizer:tapViewBG];
    [self addSubview:viewBG];
    _viewBG = viewBG;
    
    
    
    UIView *viewTitle = [UIView new];
    viewTitle.backgroundColor = kPopViewBGColor;
    [self addSubview:viewTitle];
    _viewTitle = viewTitle;
    
    UILabel *lbTitle = [UILabel new];
    lbTitle.text = @"分享到";
    lbTitle.textAlignment = NSTextAlignmentLeft;
    lbTitle.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
    lbTitle.backgroundColor = kPopViewBGColor;
    lbTitle.font = [UIFont systemFontOfSize:14.0f];
    [viewTitle addSubview:lbTitle];
    _lbTitle = lbTitle;
    
    
    YHFLayoutShareItem *layout = [[YHFLayoutShareItem alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = kPopViewBGColor;
    collectionView.delegate   = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ColCellForShareItem class] forCellWithReuseIdentifier:NSStringFromClass([ColCellForShareItem class])];
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    _collectionView = collectionView;
    
    /********“取消按钮”样式一（默认）********/
    //默认“取消按钮”
    UILabel *lbCancel = [UILabel new];
    lbCancel.font = [UIFont systemFontOfSize:14.0];
    lbCancel.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tapLbCancel =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
    [lbCancel addGestureRecognizer:tapLbCancel];
    lbCancel.text = @"取消";
    lbCancel.textColor = [UIColor whiteColor];
    lbCancel.backgroundColor = kBlueColor;
    [self addSubview:lbCancel];
    _lbCancel = lbCancel;
    
   /********“取消按钮”样式二（自定义）********/
    //取消按钮容器
    UIView *viewCancelContainer = [UIView new];
    viewCancelContainer.backgroundColor = [UIColor whiteColor];
    [self addSubview:viewCancelContainer];
    _viewCancelContainer  = viewCancelContainer;
    
    //自定义取消按钮
    UIButton *btnCustomCancel = [UIButton new];
    [btnCustomCancel setImage:[UIImage imageNamed:@"action_button_cancel"] forState:UIControlStateNormal];
    [btnCustomCancel addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [viewCancelContainer addSubview:btnCustomCancel];
    _btnCustomCancel = btnCustomCancel;
    
   
}


- (void)layoutUI{
    //总item数
    CGFloat itemCount = self.itemNameArray.count;
    NSParameterAssert(itemCount);
    
    //一行显示的item个数
    int numberOfItemsInRow = kNumberOfItemsInRow;
    if(itemCount<kNumberOfItemsInRow && itemCount>0 ){
        numberOfItemsInRow = itemCount;
    }
    
    //item小于4个, 重新布局
    if (self.iconNameArray.count < kNumberOfItemsInRow) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(kTSpace, kLSpace, kBSpace, kRSpace);
        CGFloat itemW = (SCREEN_WIDTH - kLSpace - kRSpace)/self.iconNameArray.count;
        layout.itemSize = CGSizeMake(itemW, kItemH);
        layout.minimumLineSpacing      = kLineSpace;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView.collectionViewLayout = layout;
    }
    

    //行数
    CGFloat rows = ceilf(itemCount / numberOfItemsInRow);
    

    //item所有行的行高
    CGFloat collectionViewH = (kItemH *rows + (rows-1)*kLineSpace + kTSpace + kBSpace);
    

    //取消按钮高度
    _cancelBtnH = _cancelBtnH? _cancelBtnH:kCancelBtnH;
    
    if (_customcancelBtn) {
        _lbCancel.hidden = YES;
        _cancelBtnH = 60;
    }
    
    //弹出视图高度
    _popViewH = collectionViewH+kCancelBtnH+kTitleH;

    
    WeakSelf
    [self.viewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.height.mas_equalTo(kTitleH);
    }];
    
    [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.viewTitle).offset(15);
        make.bottom.right.equalTo(weakSelf.viewTitle);
    }];
    
   
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.viewTitle.mas_bottom);
        make.left.right.equalTo(weakSelf);
        if (_customcancelBtn) {
            make.bottom.equalTo(weakSelf.viewCancelContainer.mas_top);
        }else{
            make.bottom.equalTo(weakSelf.lbCancel.mas_top);
        }
        make.height.mas_equalTo(collectionViewH);
    }];
    
    if (_customcancelBtn) {
        [self.viewCancelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf).offset(weakSelf.popViewH);
            make.height.mas_equalTo(weakSelf.cancelBtnH);
        }];
        [self.btnCustomCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf.viewCancelContainer);
            make.width.height.mas_equalTo(weakSelf.cancelBtnH);
        }];
        
    }else{
        [self.lbCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf).offset(weakSelf.popViewH);
            make.height.mas_equalTo(weakSelf.cancelBtnH);
        }];
    }
    
    
    [self.viewBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

#pragma mark - Lazy Load
- (NSDictionary *)dictConfig{
    if (!_dictConfig) {
        _textColor = _textColor?_textColor:kTextColor;
        _maskColor = _maskColor?_maskColor:kMaskBGColor;
        _popViewBGColor = _popViewBGColor?_popViewBGColor:kPopViewBGColor;
        _cancelBtnColor = _cancelBtnColor?_cancelBtnColor:kBlueColor;
        _dictConfig = @{
                        
                        @"fontSize":@(_fontSize),
                        
                        @"textColor":_textColor,
                        @"maskColor":_maskColor,
                        @"popViewBGColor":_popViewBGColor,
                        @"cancelBtnColor":_cancelBtnColor
                       
                        };
        
        WeakSelf
        if (_cancelBtnH) {
            [self.lbCancel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(weakSelf.cancelBtnH);
            }];
        }
        
    }
    return _dictConfig;
}

- (NSMutableArray *)itemHiddenArray{
    if (!_itemHiddenArray) {
        _itemHiddenArray = [NSMutableArray new];
    }
    return _itemHiddenArray;
}

#pragma mark - Setter
- (void)setCancelBtnColor:(UIColor *)cancelBtnColor{
    _cancelBtnColor = cancelBtnColor;
    if (_cancelBtnColor) {
        self.lbCancel.backgroundColor = _cancelBtnColor;
    }
}

- (void)setPopViewBGColor:(UIColor *)popViewBGColor{
    _popViewBGColor = popViewBGColor;
    if (_popViewBGColor) {
        self.collectionView.backgroundColor = _popViewBGColor;
    }
    
}

- (void)setMaskColor:(UIColor *)maskColor{
    _maskColor = maskColor;
    if (_maskColor) {
        self.viewBG.backgroundColor = _maskColor;
    }
}

- (void)setShareType:(ShareType)shareType{
    _shareType = shareType;
    self.itemHiddenArray = [NSMutableArray arrayWithArray:@[@(NO),@(NO),@(NO)]];
    switch (_shareType) {
        case ShareType_WorkGroup:
        {

        
            
//            if (![[YHSocialShareManager sharedInstance]isInstallClient:YHSharePlatform_Weixin]){
//                self.itemHiddenArray[0]  = @(YES);
//                self.itemHiddenArray[1]  = @(YES);
//            }
            
            self.iconNameArray = @[@"workgroup_sharetowechatfriendcircle",@"workgroup_sharetowechatfriend",@"workgroup_sharetopikewaydynamic"];
            self.itemNameArray = @[@"朋友圈",@"微信好友",@"税道动态"];
        }
            break;
        case ShareType_Card:
        {

            
//            if (![[YHSocialShareManager sharedInstance]isInstallClient:YHSharePlatform_Weixin]){
//                self.itemHiddenArray[0]  = @(YES);
//                self.itemHiddenArray[1]  = @(YES);
//            }
            
            self.iconNameArray = @[@"workgroup_sharetowechatfriendcircle",@"workgroup_sharetowechatfriend"];
            self.itemNameArray = @[@"朋友圈",@"微信好友"];
        }
            break;
        case ShareType_News:
        {
           
//            if (![[YHSocialShareManager sharedInstance]isInstallClient:YHSharePlatform_Weixin]){
//                self.itemHiddenArray[1]  = @(YES);
//                self.itemHiddenArray[2]  = @(YES);
//            }
//            if (![[YHSocialShareManager sharedInstance]isInstallClient:YHSharePlatform_QQ]) {
//               self.itemHiddenArray[0]  = @(YES);
//            }
            
            self.iconNameArray = @[@"common_img_qq",@"common_img_timeline",@"common_img_wechatFri"];
            self.itemNameArray = @[@"qq",@"朋友圈",@"微信好友"];
        }
            break;
        case ShareType_Tabbar:
        {
            self.viewTitle.hidden = YES;
            self.customcancelBtn  = YES;
            
            self.iconNameArray = @[@"action_img_xuanshang",@"action_img_store"];
            self.itemNameArray = @[@"悬赏",@"店铺"];
            
            
        }
            break;
            
        default:
            break;
    }
}


- (void)setItemNameArray:(NSArray *)itemNameArray{
    _itemNameArray = itemNameArray;
    [self layoutUI];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ColCellForShareItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ColCellForShareItem class]) forIndexPath:indexPath];
    if (indexPath.row < self.iconNameArray.count) {
        cell.imgvIcon.image = [UIImage imageNamed:self.iconNameArray[indexPath.row]];
    }
    if (indexPath.row < self.itemNameArray.count) {
        cell.lbItemName.text = self.itemNameArray[indexPath.row];
    }
    if (indexPath.row < self.itemHiddenArray.count) {
        BOOL hidden = [self.itemHiddenArray[indexPath.row] boolValue];
        cell.hidden = hidden;
    }
    cell.dictConfig = self.dictConfig;
    return  cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_dBlock) {
        _dBlock(NO,indexPath.row);
    }
    [self hide];
}

#pragma mark - Action
- (void)onCancel:(id)sender{
    [self hide];
    if (_dBlock) {
        _dBlock(YES,-1);
    }
}



#pragma mark - Public
- (void)show{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [KEYWINDOW addSubview:self];
    
    //视图弹出
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.customcancelBtn) {
            [weakSelf.viewCancelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf);
            }];
        }else{
            [weakSelf.lbCancel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf);
            }];
        }
        
        
        [UIView animateWithDuration:0.15 animations:^{
            weakSelf.viewBG.backgroundColor = kMaskBGColor;
            [weakSelf layoutIfNeeded];
        }];
    });
}

- (void)hide{
    WeakSelf
    if (_customcancelBtn) {
        [weakSelf.viewCancelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf).offset(weakSelf.popViewH);
        }];
    }else{
        [weakSelf.lbCancel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf).offset(weakSelf.popViewH);
        }];
    }
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    
}

- (void)dismissHandler:(DismissBlock)handler{
    _dBlock = handler;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
