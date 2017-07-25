//
//  YHWorkGroupRepostView.m
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWorkGroupRepostView.h"
#import "YHWorkGroupPhotoContainer.h"

#import "NSDate+Extension.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"


/***********上一条动态***********/
@interface YHWorkGroupRepostView()

@property (nonatomic,strong)UIImageView *imgvAvatar;
@property (nonatomic,strong)UILabel  *labelName;
@property (nonatomic,strong)UILabel  *labelContent;
@property (nonatomic,strong)YHWorkGroupPhotoContainer *picContainerView;
@property (nonatomic,strong)UILabel  *labelPubTime;
@property (nonatomic,strong)UILabel  *labelCompany;
@property (nonatomic,strong)UILabel  *labelJob;
@property (nonatomic,strong)UILabel  *labelIndustry;

@property (nonatomic,assign)BOOL shouldOpenContentLabel;
//约束
@property (nonatomic,strong)NSLayoutConstraint *cstHeightPicContainer;
@end

static const CGFloat contentLabelFontSizeRepost = 13;

@implementation YHWorkGroupRepostView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    _shouldOpenContentLabel = NO;
    
    //头像
    _imgvAvatar = [UIImageView new];
//    _imgvAvatar.layer.cornerRadius = 22.5;
//    _imgvAvatar.layer.masksToBounds = YES;
    [self addSubview:_imgvAvatar];
    
    _labelName = [UILabel new];
    _labelName.font = [UIFont systemFontOfSize:14];
    _labelName.textAlignment = NSTextAlignmentLeft;
    _labelName.textColor = RGBCOLOR(96, 96, 96);
    [self addSubview:_labelName];
    
    _labelIndustry   = [UILabel new];
    _labelIndustry.font = [UIFont systemFontOfSize:11];
    _labelIndustry.textAlignment = NSTextAlignmentLeft;
    _labelIndustry.textColor = RGBCOLOR(96, 96, 96);
    [self addSubview:_labelIndustry];
    
    _labelPubTime = [UILabel new];
    _labelPubTime.font = [UIFont systemFontOfSize:12];
    _labelPubTime.textAlignment = NSTextAlignmentRight;
    _labelPubTime.textColor = RGBCOLOR(96, 96, 96);
    [self addSubview:_labelPubTime];
    
    
    _labelCompany = [UILabel new];
    _labelCompany.font = [UIFont systemFontOfSize:12];
    _labelCompany.textColor = RGBCOLOR(96, 96, 96);
    [self addSubview:_labelCompany];
    
    
    _labelJob      = [UILabel new];
    _labelJob.font = [UIFont systemFontOfSize:12];
    _labelJob.textColor = RGBCOLOR(96, 96, 96);
    [self addSubview:_labelJob];
    
    _labelContent = [UILabel new];
    _labelContent.font = [UIFont systemFontOfSize:contentLabelFontSizeRepost];
    _labelContent.textColor = RGBCOLOR(96, 96, 96);
    _labelContent.numberOfLines = 2;
    [self addSubview:_labelContent];
    
    // 不然在6/6plus上就不准确了
    _labelContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 30;
    _picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:SCREEN_WIDTH-40];
    [self addSubview:_picContainerView];
    
    [self layoutUI];
    
    self.backgroundColor = kTbvBGColor;

}

- (void)layoutUI{
    __weak typeof(self)weakSelf = self;
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(15);
        make.left.equalTo(weakSelf).offset(15);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(15);
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
        make.right.equalTo(weakSelf).offset(-15);
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
        make.right.equalTo(weakSelf).offset(-10);
        make.width.mas_greaterThanOrEqualTo(80);
    }];
    
    [self.labelJob setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelJob setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
        make.left.equalTo(weakSelf).offset(15);
        make.right.equalTo(weakSelf).offset(-15);
    }];
    
    [self.labelContent setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [self.labelContent setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];

    _cstHeightPicContainer = [NSLayoutConstraint constraintWithItem:self.picContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:_cstHeightPicContainer];
    [self.picContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(10);
        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(10);
        make.right.equalTo(weakSelf).offset(-10);
        make.bottom.equalTo(weakSelf).offset(-10);
    }];
    
}

-(void)setForwardModel:(YHWorkGroup *)forwardModel{
    _forwardModel = forwardModel;
    _shouldOpenContentLabel = NO;
    
    [self.imgvAvatar sd_setImageWithURL:_forwardModel.userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    if (_forwardModel.userInfo.userName.length) {
        _labelName.text   = _forwardModel.userInfo.userName;
    }
    else{
        _labelName.text    = @"匿名用户";
    }
    
    self.labelIndustry.text = _forwardModel.userInfo.industry;
    self.labelJob.text      = _forwardModel.userInfo.job;
    
    self.labelPubTime.text  = _forwardModel.publishTime;
    
    self.labelContent.text  = _forwardModel.msgContent;
    
    self.labelCompany.text  = _forwardModel.userInfo.company;
    
    self.picContainerView.picOriArray = _forwardModel.originalPicUrls;
    CGFloat picContainerH = [self.picContainerView setupPicUrlArray:_forwardModel.thumbnailPicUrls];
    _cstHeightPicContainer.constant = picContainerH;
    
    
}

@end
