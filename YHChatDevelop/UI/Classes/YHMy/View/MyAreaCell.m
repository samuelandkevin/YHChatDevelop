//
//  MyAreaCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/16.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyAreaCell.h"
#import "Masonry.h"

@implementation MyAreaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self)
	{
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.title = [[UILabel alloc]init];
        self.title.font = [UIFont systemFontOfSize:15];
        self.title.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
        [self addSubview:self.title];
        WeakSelf
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(weakSelf);
        }];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor colorWithWhite:0.871 alpha:1.000].CGColor;
        self.layer.borderWidth = 0.5;
    }
	return self;
}

-(void)provinceDidSelect{
    self.backgroundColor = [UIColor colorWithRed:0.000 green:0.749 blue:0.561 alpha:1.000];
}

-(void)cityDidSelect
{
    self.backgroundColor = [UIColor colorWithRed:0.502 green:0.875 blue:0.780 alpha:1.000];
}

-(void)notSelect{
    self.backgroundColor = [UIColor whiteColor];
}

@end
