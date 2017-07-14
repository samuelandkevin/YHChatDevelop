//
//  CellChatTips.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/16.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatTips.h"
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHUserInfoManager.h"

@interface CellChatTips()

@property (nonatomic,strong) UILabel *lbContent; //提示信息
@property (nonatomic,strong) UIView  *viewContentBG;//内容背景
@end

@implementation CellChatTips

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.imgvAvatar.hidden = YES;
    self.lbName.hidden     = YES;
    
    _viewContentBG = [UIView new];
    _viewContentBG.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self.contentView addSubview:_viewContentBG];
    
    _lbContent = [UILabel new];
    _lbContent.textColor = [UIColor whiteColor];
    _lbContent.textAlignment = NSTextAlignmentCenter;
    _lbContent.font = [UIFont systemFontOfSize:14.0];
    [_viewContentBG addSubview:_lbContent];
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self layoutCommonUI];
    
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnCheckBox.mas_right).offset(5);
    }];
    
    
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.viewContentBG);
    }];
    
    [_viewContentBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbContent.mas_left).offset(-10);
        make.top.equalTo(weakSelf.lbContent.mas_top).offset(-10);
        make.right.equalTo(weakSelf.lbContent.mas_right).offset(10);
        make.bottom.equalTo(weakSelf.lbContent.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.top.equalTo(weakSelf.viewTimeBG.mas_bottom).offset(5);
    }];
    
    self.hyb_lastViewsInCell = @[_viewContentBG,self.imgvAvatar];
    self.hyb_bottomOffsetToCell = 10;
}

#pragma mark - Super


- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    
    NSString *name = model.speakerName;
    if ([model.speakerId isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]) {
        name = @"你";
    }
    _lbContent.text = [NSString stringWithFormat:@"%@撤回了一条消息",name];
    self.lbTime.text    = self.model.createTime;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
