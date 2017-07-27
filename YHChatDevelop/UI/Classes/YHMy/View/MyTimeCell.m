//
//  TimeCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/11.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "MyTimeCell.h"
#import "Masonry.h"

@implementation MyTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		self.title = [[UILabel alloc] init];
		self.title.font = [UIFont systemFontOfSize:16];
		self.title.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
		self.title.textAlignment = NSTextAlignmentRight;

		[self addSubview:self.title];

		self.upline = [[UIImageView alloc] init];
		[self addSubview:self.upline];

		self.downline = [[UIImageView alloc] init];
		[self addSubview:self.downline];

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

	[self.upline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(weakSelf.mas_centerY).offset(7);
		
        make.left.equalTo(weakSelf).offset(12);
	}];

	[self.downline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(8);
        make.top.equalTo(weakSelf.mas_centerY).offset(-7);
        make.height.mas_equalTo(52);
        make.left.equalTo(weakSelf).offset(12);
	}];

	[self.title mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.mas_equalTo(70);
		make.centerY.equalTo(weakSelf);
		make.left.equalTo(weakSelf.downline).offset(15);
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
