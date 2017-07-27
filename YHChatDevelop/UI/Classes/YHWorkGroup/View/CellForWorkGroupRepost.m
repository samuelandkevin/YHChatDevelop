//
//  CellForWorkGroupRepost.m
//  HKPTimeLine
//
//  Created by samuelandkevin on 16/9/20.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "CellForWorkGroupRepost.h"
#import "YHWorkGroupPhotoContainer.h"
#import "YHUserInfoManager.h"

#import "YHWorkGroupRepostView.h"
#import "YHUserInfoManager.h"
#import "NSDate+Extension.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHLinkLabel.h"

#pragma mark - CellForWorkGroupRepost

/***发布动态视图**/

static const CGFloat contentLabelFontSizeRepost = 13;
static const CGFloat moreBtnHeight   = 30;
static const CGFloat deleteBtnHeight = 30;

@interface CellForWorkGroupRepost()<YHWorkGroupBottomViewDelegate>

@property (nonatomic,strong)UIImageView *imgvAvatar;
@property (nonatomic,strong)UILabel     *labelName;
@property (nonatomic,strong)UILabel     *labelIndustry;
@property (nonatomic,strong)UILabel     *labelPubTime;
@property (nonatomic,strong)UILabel     *labelCompany;
@property (nonatomic,strong)UILabel     *labelJob;
@property (nonatomic,strong)YYLabel     *labelContent;
@property (nonatomic,strong)UILabel     *labelDelete;
@property (nonatomic,strong)UILabel     *labelMore;

@property (nonatomic,strong)YHWorkGroupRepostView *repostView;
@property (nonatomic,strong)UIView      *viewSeparator;

@property (nonatomic,assign)CGFloat     addFontSize;

//约束
@property (nonatomic,strong)NSLayoutConstraint *cstHeightlbMore;
@property (nonatomic,strong)NSLayoutConstraint *cstHeightlbDelete;
@property (nonatomic,strong)NSLayoutConstraint *cstCenterYlbDelete;
@property (nonatomic,strong)NSLayoutConstraint *cstLeftlbDelete;
@property (nonatomic,strong)NSLayoutConstraint *cstHeightlbContent;
@property (nonatomic,strong)NSLayoutConstraint *cstTopRepostView;
@property (nonatomic,strong)NSLayoutConstraint *cstTopViewBottom;

@end




@implementation CellForWorkGroupRepost

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup{
    self.imgvAvatar = [UIImageView new];
//    self.imgvAvatar.layer.cornerRadius = 22.5;
//    self.imgvAvatar.layer.masksToBounds = YES;
    self.imgvAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.imgvAvatar addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.imgvAvatar];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:14.0f];
    self.labelName.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelName];
    
    self.labelIndustry = [UILabel new];
    self.labelIndustry.font = [UIFont systemFontOfSize:12.0f];
    self.labelIndustry.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelIndustry];
    
    self.labelPubTime = [UILabel new];
    self.labelPubTime.font = [UIFont systemFontOfSize:13.0f];
    [self.contentView addSubview:self.labelPubTime];
    
    self.labelCompany = [UILabel new];
    self.labelCompany.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:self.labelCompany];
    
    self.labelJob = [UILabel new];
    self.labelJob.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:self.labelJob];
    
    self.labelContent = [YHLinkLabel new];
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    self.labelContent.font = [UIFont systemFontOfSize:(contentLabelFontSizeRepost+addFontSize)];
    self.labelContent.textColor = RGB16(0x303030);
    self.labelContent.numberOfLines = 0;
    [self.contentView addSubview:self.labelContent];
    
    WeakSelf
    _labelContent.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        
        NSString *linkText = [text.string substringWithRange:range];
        int linkType = 0;
        if([linkText hasPrefix:@"http"]){
            linkType = 1;
        }else if ([linkText hasPrefix:@"@"]){
            linkType = 0;
        }
        DDLog(@"点击:\n%@",linkText);
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onLinkInRepostCell:linkType:linkText:)]) {
            [weakSelf.delegate onLinkInRepostCell:weakSelf linkType:linkType linkText:linkText];
        }
    };
    
    
    self.labelDelete = [UILabel new];
    self.labelDelete.font = [UIFont systemFontOfSize:14.0f];
    self.labelDelete.textColor = RGBCOLOR(61, 95, 155);
    self.labelDelete.userInteractionEnabled = YES;
    UITapGestureRecognizer *deleteTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap)];
    [self.labelDelete addGestureRecognizer:deleteTap];
    [self.contentView addSubview:self.labelDelete];
    
    self.labelMore = [UILabel new];
    self.labelMore.font = [UIFont systemFontOfSize:14.0f];
    self.labelMore.textColor = kBlueColor;
    self.labelMore.userInteractionEnabled = YES;
    UITapGestureRecognizer *moreTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMoreTap)];
    [self.labelMore addGestureRecognizer:moreTap];
    [self.contentView addSubview:self.labelMore];
    
    self.repostView = [YHWorkGroupRepostView new];
    UITapGestureRecognizer *tapRepostView =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRepostView:)];
    [self.repostView addGestureRecognizer:tapRepostView];
    [self.contentView addSubview:self.repostView];
    
    self.viewBottom = [YHWorkGroupBottomView new];
    self.viewBottom.delegate = self;
    [self.contentView addSubview:self.viewBottom];
    
    self.viewSeparator = [UIView new];
    self.viewSeparator.backgroundColor = kTbvBGColor;
    [self.contentView addSubview:self.viewSeparator];
    
    
    [self layoutUI];
    
    
}

- (void)layoutUI{
    __weak typeof(self)weakSelf = self;
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(15);
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.width.height.mas_equalTo(45);
    }];
    
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(15);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.right.equalTo(weakSelf.labelIndustry.mas_left).offset(-10);
    }];
    
    
    [self.labelIndustry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.labelName.mas_bottom);
        make.left.equalTo(weakSelf.labelName.mas_right).offset(10);
        make.right.equalTo(weakSelf.labelPubTime.mas_left).offset(-10);
        make.width.mas_greaterThanOrEqualTo(60);
    }];
    
    [self.labelIndustry setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelIndustry setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.labelPubTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.labelName.mas_bottom);
        make.right.equalTo(weakSelf.contentView).offset(-15);
    }];
    [self.labelPubTime setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelPubTime setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.labelCompany mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelName.mas_bottom).offset(9);
        make.left.equalTo(weakSelf.labelName.mas_left);
        make.right.equalTo(weakSelf.labelJob.mas_left).offset(-10);
    }];
    
    [self.labelJob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelName.mas_bottom).offset(9);
        make.left.equalTo(weakSelf.labelCompany.mas_right).offset(10);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.width.mas_greaterThanOrEqualTo(80);
    }];
    
    [self.labelJob setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelJob setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    // 不然在6/6plus上就不准确了
    self.labelContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 20;
    _cstHeightlbContent = [NSLayoutConstraint constraintWithItem:self.labelContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstHeightlbContent];
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(-11);
    }];
    
    
    _cstHeightlbMore = [NSLayoutConstraint constraintWithItem:self.labelMore attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstHeightlbMore];
    [self.labelMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView);
        make.width.mas_equalTo(60);
    }];
    
    
    _cstHeightlbDelete = [NSLayoutConstraint constraintWithItem:self.labelDelete attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstHeightlbDelete];
    _cstCenterYlbDelete = [NSLayoutConstraint constraintWithItem:self.labelDelete attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.labelMore attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstCenterYlbDelete];
    _cstLeftlbDelete    = [NSLayoutConstraint constraintWithItem:self.labelDelete attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.labelMore attribute:NSLayoutAttributeRight multiplier:1.0 constant:10];
    [self.contentView addConstraint:_cstLeftlbDelete];
    [self.labelDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
    }];
    
    
    _cstTopRepostView = [NSLayoutConstraint constraintWithItem:self.repostView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.labelMore attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10];
    [self.contentView addConstraint:_cstTopRepostView];
    [self.repostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.right.equalTo(weakSelf.contentView).offset(-10);
    }];
    
    
    [self.viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.repostView.mas_bottom).offset(15).priorityLow();
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    /*******使用FDTemplateLayoutCell*******/
//    [self.viewSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.viewBottom.mas_bottom);
//        make.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(15);
//        make.bottom.equalTo(weakSelf.contentView);
//    }];
    
    /*******使用HYBMasonryAutoCell*******/
    [self.viewSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.viewBottom.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(15);
    }];
    
    self.hyb_lastViewInCell = self.viewSeparator;
}

- (void)setModel:(YHWorkGroup *)model{
    _model = model;
    _model.isRepost = YES;
    [self.imgvAvatar sd_setImageWithURL:_model.userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] ];
    
    if (_model.userInfo.userName.length) {
        self.labelName.text = _model.userInfo.userName;
    }
    else{
        self.labelName.text  = @"匿名用户";
    }
    self.labelIndustry.text = _model.userInfo.industry;
    
    self.labelPubTime.text  = _model.publishTimeFormat;
    self.labelCompany.text  = _model.userInfo.company;
    self.labelJob.text      = _model.userInfo.job;
    
    /*************动态内容*************/
    ;
    self.labelContent.textLayout  = _model.layout.textLayout;

    //查看详情按钮
    self.labelMore.text     = @"   全文";
    CGFloat moreBtnH = 0;
    if (_model.layout.shouldShowMore) {
        moreBtnH = moreBtnHeight;
        if (_model.isOpening) { // 如果需要展开
            _labelMore.text = @"   收起";
            _labelContent.textLayout     = _model.layout.fullTextLayout;
            _cstHeightlbContent.constant = HUGE;
            
        }else {
            _labelMore.text = @"   全文";
            _labelContent.textLayout = _model.layout.textLayout;
            CGFloat height = _model.layout.designatedTextHeight;
            _cstHeightlbContent.constant = height;
            
        }
    }else{
        _labelContent.textLayout     = _model.layout.textLayout;
        _cstHeightlbContent.constant = _model.layout.shrinkTextHeight;
    }
    
    //删除按钮
    self.labelDelete.text   = @"   删除";
    CGFloat delBtnH = 0;
    if ([_model.userInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]) {
        delBtnH = deleteBtnHeight;
    }
    
    //更新“查看详情”和“删除按钮”的约束
    _cstHeightlbMore.constant   = moreBtnH;
    _cstHeightlbDelete.constant = delBtnH;
    if (moreBtnH) {
        _cstLeftlbDelete.constant    = 10;
        _cstCenterYlbDelete.constant = 0;
    }else{
        _cstLeftlbDelete.constant    = -60;
        _cstCenterYlbDelete.constant = 11;
    }

    
    CGFloat repostVTop = 0;
    if (moreBtnH) {
        repostVTop = 10;
    }else if(delBtnH && !moreBtnH){
        repostVTop = 30;
    }else{
        repostVTop = 0;
    }
    _cstTopRepostView.constant    = repostVTop;
    
    self.repostView.forwardModel = _model.forwardModel;
    
    _viewBottom.btnLike.selected = _model.isLike? YES: NO;
    UIImage *imageLike = _model.isLike?[UIImage imageNamed:@"workgroup_img_like_sel"]:[UIImage imageNamed:@"workgroup_img_like"];
    [_viewBottom.btnLike setImage:imageLike forState:UIControlStateNormal];
    UIColor *colLike = _model.isLike?kBlueColor:RGBCOLOR(151, 161, 173);
    [_viewBottom.btnLike setTitleColor:colLike forState:UIControlStateNormal];
    
    [_viewBottom.btnComment setTitle:[NSString stringWithFormat:@"%d",_model.commentCount] forState:UIControlStateNormal];//评论数
    [_viewBottom.btnLike setTitle:[NSString stringWithFormat:@"%d",_model.likeCount] forState:UIControlStateNormal];          //点赞数
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Private
- (CGFloat)addFontSize{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
}

#pragma mark - Public
- (void)showLikeAnimationWithLikeCount:(int)likeCount complete:(void(^)(BOOL finished))complete{
    
    CGRect rect = [self.viewBottom.btnLike convertRect:self.viewBottom.btnLike.frame toView:[[UIApplication sharedApplication].delegate window]];
    
    UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(rect.origin.x - rect.size.width-6, rect.origin.y, rect.size.width, rect.size.height)];
    [btnLike setImage:[UIImage imageNamed:@"workgroup_img_like_sel"] forState:UIControlStateNormal];
    [[[UIApplication sharedApplication].delegate window] addSubview:btnLike];
    
    NSTimeInterval duration = 0.8;
    btnLike.transform = CGAffineTransformIdentity;
    WeakSelf
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations: ^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration / 2 animations: ^{
            
            btnLike.transform = CGAffineTransformMakeScale(2, 2);
            
            [weakSelf.viewBottom.btnLike setTitleColor:kBlueColor forState:UIControlStateNormal];
            [weakSelf.viewBottom.btnLike setTitle:[NSString stringWithFormat:@"%d",likeCount] forState:UIControlStateNormal];
            
        }];
        
        [UIView addKeyframeWithRelativeStartTime:duration/2 relativeDuration:duration/2 animations: ^{
            
            btnLike.transform = CGAffineTransformMakeScale(1, 1);
        }];
        
    } completion:^(BOOL finished){
        if (finished) {
            [btnLike removeFromSuperview];
        }
        if (complete) {
            complete(finished);
        }
    }];
}

#pragma mark - Gesture

- (void)onAvatar:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(onAvatarInRepostCell:)]) {
            [_delegate onAvatarInRepostCell:self];
        }
    }
}

- (void)tapRepostView:(UIGestureRecognizer *)guesture{
    if (guesture.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(onTapRepostViewInCell:)]) {
            [_delegate onTapRepostViewInCell:self];
        }
    }
}

#pragma mark - YHWorkGroupBottomViewDelegate

- (void)onComment{
    if (_delegate && [_delegate respondsToSelector:@selector(onCommentInRepostCell:)]) {
        [_delegate onCommentInRepostCell:self];
    }
}

- (void)onLikeInView:(YHWorkGroupBottomView *)inView{
    if (_delegate && [_delegate respondsToSelector:@selector(onLikeInRepostCell:)]) {
        [_delegate onLikeInRepostCell:self];
    }
}

- (void)onShare{
    if (_delegate && [_delegate respondsToSelector:@selector(onShareInRepostCell:)]) {
        [_delegate onShareInRepostCell:self];
    }
}

- (void)onMoreTap
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(onMoreInRespostCell:)]) {
        [_delegate onMoreInRespostCell:self];
    }
}

- (void)deleteTap{
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDeleteInRepostCell:)]) {
        [_delegate onDeleteInRepostCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
