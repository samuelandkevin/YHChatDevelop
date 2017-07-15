//
//  ConnectionSearchCell.m
//  PikeWay
//
//  Created by YHIOS003 on 16/5/26.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "ConnectionSearchCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface ConnectionSearchCell()

@property(nonatomic,strong) UIImageView * avatar;
@property(nonatomic,strong) UILabel * name;
@property(nonatomic,strong) UILabel * company;
@property(nonatomic,strong) UILabel * position;


@end

@implementation ConnectionSearchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatar = [[UIImageView alloc]init];
        
        self.name = [[UILabel alloc]init];
        self.name.font = [UIFont systemFontOfSize:16];
        self.name.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
        self.company = [[UILabel alloc]init];
        self.company.font = [UIFont systemFontOfSize:12];
        self.company.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
        self.position= [[UILabel alloc]init];
        self.position.font = [UIFont systemFontOfSize:12];
        self.position.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];

        self.baseline = [[UIView alloc]init];
        self.baseline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
    
        [self addSubview:self.avatar];
        [self addSubview:self.name];
        [self addSubview:self.company];
        [self addSubview:self.baseline];
        [self addSubview:self.position];
        [self masonry];
        self.avatar.image = [UIImage imageNamed:@"common_avatar_80px"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    return self;
}

-(void)masonry
{
    WeakSelf
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.centerY.equalTo(weakSelf);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.avatar.mas_right).offset(10);
        make.centerY.equalTo(weakSelf);
        make.width.mas_lessThanOrEqualTo(60);
    }];
    
    [self.baseline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.name);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf).offset(-15);
        make.left.equalTo(weakSelf.company.mas_right).offset(5);
    }];
    
    [self.company mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.left.equalTo(weakSelf.avatar.mas_right).offset(70);
//        make.right.equalTo(ws.position.mas_left).offset(-5);
    }];
    
   
}

-(void)setUserInfo:(YHUserInfo *)userInfo{
    _userInfo = userInfo;
    self.name.text     = _userInfo.userName;
    self.company.text  = _userInfo.company;
    self.position.text = _userInfo.job;
    [self.avatar sd_setImageWithURL:_userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
}


@end
