//
//  CellForChatGroup.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellForChatGroup.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHGroupIconView.h"

#define kGroupIconW 50
@interface CellForChatGroup()

@property(nonatomic,strong)YHGroupIconView *groupIcon;
@property(nonatomic,strong)UILabel  *labelName;
@property(nonatomic,strong)UIView   *viewBotLine;

@end


@implementation CellForChatGroup

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
    self.groupIcon = [YHGroupIconView new];
    self.groupIcon.containerW      = kGroupIconW;
    self.groupIcon.backgroundColor = RGBCOLOR(221, 222, 224);
    self.groupIcon.layer.cornerRadius  = 2;
    self.groupIcon.layer.masksToBounds = YES;
    self.groupIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.groupIcon addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.groupIcon];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:14.0f];
    self.labelName.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelName];
    
    
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
    [_groupIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.width.height.mas_equalTo(kGroupIconW);
    }];
    
    [_labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.groupIcon.mas_right).offset(10);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.right.equalTo(weakSelf.imgvSel.mas_left).offset(-10);
    }];
    
    [_labelName setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [_labelName setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
  
    [_imgvSel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(15);
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

- (void)setModel:(YHChatGroupModel *)model{
    _model = model;
    
    self.groupIcon.picUrlArray = _model.groupIconUrl;
    
    if (_model.groupName) {
        self.labelName.text = [NSString stringWithFormat:@"%@(%d)",_model.groupName,_model.memberCount];
    }
    else{
        self.labelName.text  = @"匿名群";
    }
    
    if (!_isOnlyShowGroup) {
        self.btnTapScope.selected = NO;
        
        NSString *imgName = _model.isSelected?@"chat_fri_choose":@"chat_fri_nor";
        self.imgvSel.image = [UIImage imageNamed:imgName];
    }
    
   
}


#pragma mark - Gesture
- (void)onAvatar:(UITapGestureRecognizer *)gesture{
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectOneGroup:inCell:)]) {
        [_delegate didSelectOneGroup:YES inCell:self];
    }
    
}

- (void)onTapCell:(UIButton *)sender{
    
    DDLog(@"sender.selected:%id",sender.selected);
    
    sender.selected  = !sender.selected;
    
    _model.isSelected = !_model.isSelected;
    
    if (!_isOnlyShowGroup) {
        NSString *imgName = _model.isSelected?@"chat_fri_choose":@"chat_fri_nor";
        self.imgvSel.hidden = NO;
        self.imgvSel.image  = [UIImage imageNamed:imgName];
    }else{
        self.imgvSel.hidden = YES;
    }
    
    BOOL didSel = _model.isSelected?YES:NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectOneGroup:inCell:)]) {
        [_delegate didSelectOneGroup:didSel inCell:self];
    }

   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
