//
//  CellForWGDetail.m
//  PikeWay
//
//  Created by YHIOS002 on 16/9/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "CellForWGDetail.h"
#import "YHWorkGroupPhotoContainer.h"
#import "YHUserInfoManager.h"

#import "NSDate+Extension.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHLinkLabel.h"

static const CGFloat contentLabelFontSize = 13.0;
static const CGFloat deleteBtnHeight = 30;
static const CGFloat moreBtnHeight   = 30;

@interface CellForWGDetail()
@property (nonatomic,strong)UIImageView *imgvAvatar;
@property (nonatomic,strong)UILabel     *labelName;
@property (nonatomic,strong)UILabel     *labelIndustry;
@property (nonatomic,strong)UILabel     *labelPubTime;
@property (nonatomic,strong)UILabel     *labelCompany;
@property (nonatomic,strong)UILabel     *labelJob;
@property (nonatomic,strong)YYLabel     *labelContent;
@property (nonatomic,strong)UILabel     *labelDelete;
@property (nonatomic,strong)UILabel     *labelMore;

@property (nonatomic,strong)YHWorkGroupPhotoContainer *picContainerView;
@property (nonatomic,strong)UIView      *viewSeparator;


@end

@implementation CellForWGDetail

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
    self.labelContent.font = [UIFont systemFontOfSize:(contentLabelFontSize+addFontSize)];
    self.labelContent.numberOfLines = 0;
   
    // 不然在6/6plus上就不准确了
    self.labelContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 20;
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
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onLinkInWGDetailCell:linkType:linkText:)]) {
            [weakSelf.delegate onLinkInWGDetailCell:weakSelf linkType:linkType linkText:linkText];
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
    
    
    self.picContainerView = [[YHWorkGroupPhotoContainer alloc] initWithWidth:SCREEN_WIDTH-20];
    [self.contentView addSubview:self.picContainerView];
    
    
    
    self.viewSeparator = [UIView new];
    self.viewSeparator.backgroundColor =  [UIColor clearColor];
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
       make.top.equalTo(weakSelf.labelName.mas_bottom).offset(9).priorityLow();
        make.bottom.equalTo(weakSelf.labelCompany.mas_bottom);
        make.left.equalTo(weakSelf.labelCompany.mas_right).offset(10);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.width.mas_greaterThanOrEqualTo(80);
    }];
    
    [self.labelJob setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelJob setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(-11);
    }];
    


    [self.labelMore mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(60);
    }];
    
    [self.labelDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.labelMore.mas_centerY);
        make.left.equalTo(weakSelf.labelMore.mas_right).offset(10);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(80);
    }];
    
    
    [self.picContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelMore.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(0);
        make.right.mas_greaterThanOrEqualTo(weakSelf.contentView).offset(-10);
    }];
    [self.picContainerView setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [self.picContainerView setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    
    /*******使用FDTemplateLayoutCell*******/
//    [self.viewSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.picContainerView.mas_bottom);
//        make.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(15);
//        make.bottom.equalTo(weakSelf.contentView);
//    }];
    
    
    
    /*******使用HYBMasonryAutoCell*******/
    [self.viewSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.picContainerView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(15);
    }];
    
    self.hyb_lastViewInCell = self.viewSeparator;
    
    
}


- (void)setModel:(YHWorkGroup *)model{
    _model = model;
    [self.imgvAvatar sd_setImageWithURL:_model.userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] ];
    
    if (_model.userInfo.userName.length) {
        self.labelName.text = _model.userInfo.userName;
    }
    else{
        self.labelName.text  = @"匿名用户";
    }
    self.labelIndustry.text = _model.userInfo.industry;
    
    self.labelPubTime.text  = _model.publishTime;
    self.labelCompany.text  = _model.userInfo.company;
    self.labelJob.text      = _model.userInfo.job;
    
    /*************动态内容*************/

    
    WeakSelf
    //查看详情按钮
    self.labelMore.text     = @"全文";
    CGFloat moreBtnH = 0;
    if (_model.layout.shouldShowMore) { 
        moreBtnH = moreBtnHeight;
        if (_model.isOpening) { // 如果需要展开
            _labelMore.text = @"收起";
            _labelContent.textLayout = _model.layout.fullTextLayout;
            
            [_labelContent mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
                make.left.equalTo(weakSelf.contentView).offset(10);
                make.right.equalTo(weakSelf.contentView).offset(-10);
                make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(-11);
                make.height.mas_lessThanOrEqualTo(HUGE);
            }];
            
            
        }else{
            _labelMore.text = @"全文";
            _labelContent.textLayout = _model.layout.textLayout;
            CGFloat height = _model.layout.designatedTextHeight;
            [_labelContent mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.imgvAvatar.mas_bottom).offset(11);
                make.left.equalTo(weakSelf.contentView).offset(10);
                make.right.equalTo(weakSelf.contentView).offset(-10);
                make.bottom.equalTo(weakSelf.labelMore.mas_top).offset(-11);
                make.height.mas_lessThanOrEqualTo(height);
            }];
            
        }
    }else{
        _labelContent.textLayout = _model.layout.textLayout;
    }
    
    
    //删除按钮
    self.labelDelete.text   = @"删除";
    CGFloat delBtnH = 0;
    if ([_model.userInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]) {
        delBtnH = deleteBtnHeight;
    }
    
    //更新“查看详情”和“删除按钮”的约束
    [_labelMore mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(moreBtnH);
        make.width.mas_equalTo(60);
    }];
    
    
    [_labelDelete mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(delBtnH);
        make.width.mas_equalTo(80);
        if (moreBtnH) {
            make.left.equalTo(weakSelf.labelMore.mas_right).offset(10);
            make.centerY.equalTo(weakSelf.labelMore.mas_centerY);
        }else{
            make.left.equalTo(weakSelf.labelMore.mas_right).offset(-60);
            make.centerY.equalTo(weakSelf.labelMore.mas_centerY).offset(11);
        }
        
    }];
    
    
    
    CGFloat picTop = 0;
    if (moreBtnH) {
        picTop = 10;
    }else if(delBtnH && !moreBtnH){
        picTop = 30;
    }else{
        picTop = 0;
    }
    

    CGFloat picContainerH = [self.picContainerView setupPicUrlArray:_model.thumbnailPicUrls];
    self.picContainerView.picOriArray = _model.originalPicUrls;
    
    
    [_picContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelMore.mas_bottom).offset(picTop);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.height.mas_equalTo(picContainerH);
        make.right.mas_greaterThanOrEqualTo(weakSelf.contentView).offset(-10);
    }];;
    
    
}


#pragma mark - Gesture
- (void)onMoreTap
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(onMoreInWGDetailCell:)]) {
        [_delegate onMoreInWGDetailCell:self];
    }
}

- (void)deleteTap{
    
    if (_delegate && [_delegate respondsToSelector:@selector(onDeleteInWGDetailCell:)]) {
        [_delegate onDeleteInWGDetailCell:self];
    }
}

- (void)onAvatar:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(onAvatarInWGDetailCell:)]) {
            [_delegate onAvatarInWGDetailCell:self];
        }
    }
}

- (void)onMore{
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


