//
//  HomePageCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyDetailEditCell.h"
#import "Masonry.h"

@implementation MyDetailEditCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		self.title = [[UILabel alloc] init];
		self.title.font = [UIFont systemFontOfSize:16];
		self.title.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
        self.title.textAlignment = NSTextAlignmentLeft;
//        self.title.backgroundColor = [UIColor greenColor];
		[self addSubview:self.title];

		self.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_avatar_80px"]];
		self.avatar.hidden = YES;
//        self.avatar.layer.cornerRadius = 30;
//        self.avatar.layer.masksToBounds = YES;
		[self addSubview:self.avatar];

		self.detail = [[UILabel alloc] init];
		self.detail.font = [UIFont systemFontOfSize:13];
		self.detail.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
        self.detail.textAlignment = NSTextAlignmentLeft;
//        self.detail.backgroundColor = [UIColor cyanColor];
		[self addSubview:self.detail];

		self.arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_Arrow"]];
		[self addSubview:self.arrow];
		[self masonry];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        
	}
	return self;
}

- (void)masonry
{
	WeakSelf
	[self.title mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(weakSelf);
		make.left.equalTo(weakSelf).offset(13);
	}];
    
	
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.right.equalTo(weakSelf.arrow.mas_left).offset(-10);
        make.top.equalTo(weakSelf).offset(15);
    }];
    
    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.title.mas_right).offset(16);
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf.arrow.mas_left).offset(-10);
    }];
    
    //    [self.detail setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.detail setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf).offset(-15);
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(12);
    }];
    

}

@end
