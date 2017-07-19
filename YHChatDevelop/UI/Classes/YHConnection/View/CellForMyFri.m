//
//  CellForMyFri.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "CellForMyFri.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface CellForMyFri()
@property(nonatomic,strong)UIImageView *imgvAvatar;
@property(nonatomic,strong)UILabel *labelName;
@property(nonatomic,strong)UILabel *labelPhoneNum;
@property(nonatomic,strong)UIView   *viewBotLine;
@end


@implementation CellForMyFri

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    self.imgvAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.imgvAvatar addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.imgvAvatar];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:15.0f];
    self.labelName.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelName];
    
    self.labelPhoneNum = [UILabel new];
    self.labelPhoneNum.font = [UIFont systemFontOfSize:14.0f];
    self.labelPhoneNum.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelPhoneNum];
    //1.13需求改动,隐藏电话号码
    self.labelPhoneNum.hidden = YES;
    
    self.imgvSel = [UIImageView new];
    [self.contentView addSubview:self.imgvSel];
    
    self.viewBotLine = [UIView new];
    self.viewBotLine.backgroundColor = kSeparatorLineColor;
    [self.contentView addSubview:self.viewBotLine];
    
    self.btnTapScope = [UIButton new];
    [self.btnTapScope addTarget:self action:@selector(onTapCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnTapScope];
  
    [self layoutUI];
    

}

- (void)layoutUI{
    WeakSelf
    [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.width.height.mas_equalTo(35);
    }];
    
    [_labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.right.equalTo(weakSelf.labelPhoneNum.mas_left).offset(-10);
    }];
    
    [_labelName setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [_labelName setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [_labelPhoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvSel.mas_left).offset(-10);
        make.centerY.equalTo(weakSelf.mas_centerY);
//        make.width.mas_greaterThanOrEqualTo(100);
        make.width.mas_equalTo(10);//默认隐藏手机号码
        
    }];
    
    [_imgvSel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.height.mas_equalTo(18);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.right.equalTo(weakSelf.contentView).offset(-15);
    }];
    
    [_viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.labelName);
        make.right.equalTo(weakSelf.contentView).offset(20);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(weakSelf.contentView);
    }];
    
    [_btnTapScope mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.contentView);
    }];
}

- (void)setModel:(YHUserInfo *)model{
    _model = model;
    
    [self.imgvAvatar sd_setImageWithURL:_model.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] ];
    
    if (_model.userName.length) {
        self.labelName.text = _model.userName;
    }
    else{
        self.labelName.text  = @"匿名用户";
    }
    
    self.labelPhoneNum.text = _model.mobilephone;
    
    self.btnTapScope.selected = NO;
    
    NSString *imgName = _model.likeCount?@"chat_fri_choose":@"chat_fri_nor";
    self.imgvSel.image = [UIImage imageNamed:imgName];
    
    if(_isInviteFrisToGroupChat){
        //这里的isInMyBlackList指的是该好友已经存在群聊里面，不可以勾选
        if (_model.isInMyBlackList) {
             self.btnTapScope.enabled = NO;
             self.imgvSel.image = [UIImage imageNamed:@"chat_fri_cannotChoose"];
        }else{
             self.btnTapScope.enabled = YES;
        }
    }else{
        self.btnTapScope.enabled = YES;
    }
}


#pragma mark - Gesture
- (void)onAvatar:(UITapGestureRecognizer *)gesture{
    
    if(_isInviteFrisToGroupChat){
        //这里的isInMyBlackList指的是该好友已经存在群聊里面，不可以勾选
        if (!_model.isInMyBlackList) {
            if (_delegate && [_delegate respondsToSelector:@selector(didSelectOneFriend:inCell:)]) {
                [_delegate didSelectOneFriend:YES inCell:self];
            }
           
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectOneFriend:inCell:)]) {
            [_delegate didSelectOneFriend:YES inCell:self];
        }
    }
    
    
}

- (void)onTapCell:(UIButton *)sender{
    
    DDLog(@"sender.selected:%id",sender.selected);
    sender.selected  = !sender.selected;
    
    _model.likeCount = _model.likeCount?0:1;
    NSString *imgName = _model.likeCount?@"chat_fri_choose":@"chat_fri_nor";
    self.imgvSel.image = [UIImage imageNamed:imgName];
    
    BOOL didSel = _model.likeCount?YES:NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectOneFriend:inCell:)]) {
        [_delegate didSelectOneFriend:didSel inCell:self];
    }
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
