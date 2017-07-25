//
//  CellForLikePeople.m
//  PikeWay
//
//  Created by YHIOS002 on 16/5/31.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "CellForLikePeople.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface CellForLikePeople()
@property (strong, nonatomic)  UIImageView *imgvAvatar;
@property (strong, nonatomic)  UILabel *labelName;
@property (nonatomic,strong)UIView *viewBotLine;
@end

@implementation CellForLikePeople

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup{
    
    self.imgvAvatar = [UIImageView new];
//    self.imgvAvatar.layer.cornerRadius = 20;
//    self.imgvAvatar.layer.masksToBounds = YES;
    self.imgvAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.imgvAvatar addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.imgvAvatar];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:14.0f];
    self.labelName.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelName];
    
    UIView *viewBotLine = [UIView new];
    viewBotLine.backgroundColor = kSeparatorLineColor;
    [self.contentView addSubview:viewBotLine];
    self.viewBotLine = viewBotLine;
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.centerY.equalTo(weakSelf.imgvAvatar.mas_centerY);
        make.right.lessThanOrEqualTo(weakSelf.contentView.mas_right).offset(-10);
    }];
    
    [self.viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
}


- (void)setUserInfo:(YHUserInfo *)userInfo{
    _userInfo = userInfo;
   
    [self.imgvAvatar sd_setImageWithURL:_userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];

    if (_userInfo.userName.length) {
         self.labelName.text = _userInfo.userName;
    }
    else{
         self.labelName.text = @"匿名用户";
    }
    
}

- (void)onAvatar:(UITapGestureRecognizer *)guesture{
    if (guesture.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(onAvatarInLikeCell:)]) {
            [_delegate onAvatarInLikeCell:self];
        }
    }
}


@end
