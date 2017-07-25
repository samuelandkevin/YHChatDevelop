//
//  MyMapCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/13.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyMapCell.h"
#import "Masonry.h"

@implementation MyMapCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		self.title = [[UILabel alloc] init];
		self.title.font = [UIFont systemFontOfSize:16];
		self.title.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
		self.title.textAlignment = NSTextAlignmentLeft;
		self.title.lineBreakMode = NSLineBreakByTruncatingTail;
		self.title.numberOfLines = 1;
		[self addSubview:self.title];

		self.detail = [[UILabel alloc] init];
		self.detail.font = [UIFont systemFontOfSize:14];
		self.detail.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
		self.detail.textAlignment = NSTextAlignmentLeft;
		self.detail.numberOfLines = 1;
		self.detail.lineBreakMode = NSLineBreakByTruncatingTail;
		[self addSubview:self.detail];

//		self.title.backgroundColor = [UIColor cyanColor];
//		self.detail.backgroundColor = [UIColor greenColor];

		[self masonry];
	}
	return self;
}

- (void)masonry
{
	WeakSelf

	[self.title mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(weakSelf);
		make.left.equalTo(weakSelf).offset(15);
	}];

	[self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(weakSelf);
		make.left.equalTo(weakSelf.title.mas_right).offset(15);
	}];
}

//-(void)layoutIfNeeded
//{
//    [super layoutIfNeeded];
//    CGFloat width = self.width - CGRectGetMaxX(self.title.frame) - 30;
//    self.detail.width = width;
//
//}

@end
