//
//  MySettingCommonCell.m
//  PikeWay
//
//  Created by YHIOS003 on 16/6/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MySettingCommonCell.h"
#import "Masonry.h"

@implementation MySettingCommonCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.title = [self labelCreateWithFontSize:16 withFontColor:[UIColor colorWithWhite:0.188 alpha:1.000]];
        
        self.detail = [self labelCreateWithFontSize:13 withFontColor:[UIColor colorWithWhite:0.376 alpha:1.000]];
        
        self.arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TableViewArrow"]];
        
        self.line = [[UIView alloc]init];
        self.line.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
        self.line.hidden = YES;
        [self addSubview:self.line];
        
        [self addSubview:self.title];
        [self addSubview:self.detail];
        [self addSubview:self.arrow];
        WeakSelf
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf);
            make.left.equalTo(weakSelf).offset(15);
        }];
        
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf);
            make.right.equalTo(weakSelf.arrow.mas_left).offset(-5);
        }];
        
        [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf);
            make.right.equalTo(weakSelf).offset(-14.5);
            make.width.height.mas_equalTo(15);
        }];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf);
            make.height.mas_equalTo(0.5);
            make.width.equalTo(weakSelf);
            make.left.equalTo(weakSelf);
        }];
        
    }
    return self;
}

- (UILabel *)labelCreateWithFontSize:(NSInteger)fontSize withFontColor:(UIColor *)fontColor
{
    UILabel *label = [[UILabel alloc] init];
    
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = fontColor;
    return label;
}

@end
