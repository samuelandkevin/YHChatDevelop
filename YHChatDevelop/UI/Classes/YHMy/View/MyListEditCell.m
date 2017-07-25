//
//  ListEditCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyListEditCell.h"
#import "Masonry.h"

@implementation MyListEditCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.title = [[UILabel alloc] init];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
        self.title.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.title];
        
        self.detail = [[UILabel alloc] init];
        self.detail.font = [UIFont systemFontOfSize:16];
        self.detail.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
        self.detail.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.detail];
        
        self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_Arrow"]];
        [self addSubview:self.arrow];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self masonry];
    }
    return self;
}

- (void)masonry
{
    WeakSelf
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_lessThanOrEqualTo(70);
        make.centerY.equalTo(weakSelf);
        make.left.equalTo(weakSelf).offset(15);
    }];
    
    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.title.mas_right).offset(15);
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf.arrow.mas_left).offset(-15);
    }];
    
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf).offset(-15);
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(12);
    }];
}

@end
