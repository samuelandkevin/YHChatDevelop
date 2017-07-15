//
//  CellForNewFri.m
//  PikeWay
//
//  Created by YHIOS002 on 17/1/14.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "CellForNewFri.h"
#import "UIImageView+WebCache.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "Masonry.h"

@interface CellForNewFri()
@property (strong, nonatomic)  UIImageView *imgvAvatar;//头像
@property (strong, nonatomic)  UILabel *labelNick;     //昵称
@property (strong, nonatomic)  UILabel *labelCompany;  //公司
@property (strong, nonatomic)  UILabel *labelJob;      //职位
@property (strong, nonatomic)  UIView *viewBotLine;


@end

@implementation CellForNewFri

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupUI{
    
    self.imgvAvatar = [UIImageView new];
//    self.imgvAvatar.layer.cornerRadius = 25;
//    self.imgvAvatar.layer.masksToBounds = YES;
    self.imgvAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.imgvAvatar addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.imgvAvatar];
    
    
    self.labelNick  = [UILabel new];
    self.labelNick.font = [UIFont systemFontOfSize:16.0];
    self.labelNick.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.labelNick];
    
    
    self.btnAccept = [UIButton new];
    self.btnAccept.layer.cornerRadius  = 5;
    self.btnAccept.layer.masksToBounds = YES;
    [self.btnAccept addTarget:self action:@selector(onAccept:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAccept setTitle:@"接受" forState:UIControlStateNormal];
    self.btnAccept.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.btnAccept.backgroundColor = kBlueColor;
    self.btnAccept.enabled = YES;
    [self.btnAccept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.btnAccept];
    
    
    self.labelCompany = [UILabel new];
    self.labelCompany.font = [UIFont systemFontOfSize:14.0f];
    [self.labelCompany setTextColor:RGBCOLOR(120, 120, 120)];
    [self.contentView addSubview:self.labelCompany];
    
    self.labelJob = [UILabel new];
    self.labelJob.font = [UIFont systemFontOfSize:14.0f];
    [self.labelJob setTextColor:RGBCOLOR(120, 120, 120)];
    [self.contentView addSubview:self.labelJob];
    
    self.labelAddReq = [UILabel new];
    self.labelAddReq.font = [UIFont systemFontOfSize:14.0f];
    self.labelAddReq.numberOfLines = 0;
    [self.labelAddReq setTextColor:RGBCOLOR(120, 120, 120)];
    [self.contentView addSubview:self.labelAddReq];
    
    self.viewBotLine = [UIView new];
    self.viewBotLine.backgroundColor = kSeparatorLineColor;
    [self.contentView addSubview:self.viewBotLine];
    
    [self layoutUI];
    
}

- (void)layoutUI{
    WeakSelf
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.top.equalTo(weakSelf.contentView).offset(15);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.labelNick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.mas_lessThanOrEqualTo(weakSelf.btnAccept.mas_left).offset(-10);
    }];
    
    [self.labelNick setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelNick setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];

    [self.btnAccept mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.top.equalTo(weakSelf.labelNick.mas_top);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    [self.labelCompany mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelNick.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.labelNick.mas_left);
    }];
    
    
    [self.labelCompany setContentHuggingPriority:248 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelCompany setContentCompressionResistancePriority:748 forAxis:UILayoutConstraintAxisHorizontal];

    
    [self.labelJob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.labelCompany.mas_centerY);
        make.left.equalTo(weakSelf.labelCompany.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(weakSelf.btnAccept.mas_left);
    }];
    
    
    [self.labelJob setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.labelJob setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.labelAddReq setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [self.labelAddReq setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    self.labelAddReq.preferredMaxLayoutWidth = SCREEN_WIDTH - 130;
    [self.labelAddReq mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.labelNick.mas_left);
        make.right.mas_lessThanOrEqualTo(weakSelf.btnAccept.mas_left);
        make.top.equalTo(weakSelf.labelCompany.mas_bottom).offset(5);
    }];
    
    
    [self.viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelAddReq.mas_bottom).offset(15);
        make.left.right.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
    
    self.hyb_lastViewInCell = self.viewBotLine;
}

#pragma mark - Action
- (void)onAvatar:(id)sender{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Action
//点击接受
- (void)onAccept:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onAccepetNewFriendInCell:)]) {
        [_delegate onAccepetNewFriendInCell:self];
    }
}

- (void)setModel:(YHUserInfo *)model{
    _model = model;
    if (_model.userName.length) {
        self.labelNick.text      = _model.userName;
    }
    else{
        self.labelNick.text      = @"匿名用户";
    }
    
    NSString *addReqContent = @"";
    NSString *company  = @"";
    NSString *userName = @"";
    
    if (_model.userName.length)
    {
        userName = _model.userName;
    }else{
        userName = @"某人";
    }
    
    if (_model.company.length)
    {
        company = _model.company;
    }
    else{
        company = @"某公司";
    }
    
    addReqContent = [NSString stringWithFormat:@"我是%@的%@,请求加你为好友",company,userName];
    
    self.labelAddReq.text    = addReqContent;
    self.labelJob.text       = _model.job;
    self.labelCompany.text   = _model.company;
    
    [self.imgvAvatar sd_setImageWithURL:_model.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    if (_model.friShipStatus == FriendShipStatus_isMyFriend)
    {
        self.btnAccept.enabled = NO;
        [self.btnAccept setTitle:@"已接受" forState:UIControlStateNormal];
        self.btnAccept.backgroundColor = [UIColor clearColor];
        [self.btnAccept setTitleColor:RGBCOLOR(150, 150, 150) forState:UIControlStateNormal];
    }
    else
    {
        
        [self.btnAccept setTitle:@"接受" forState:UIControlStateNormal];
        self.btnAccept.backgroundColor = kBlueColor;
        self.btnAccept.enabled = YES;
        [self.btnAccept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

@end
