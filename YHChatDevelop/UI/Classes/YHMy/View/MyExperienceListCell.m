//
//  ExperienceListCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "MyExperienceListCell.h"
#import "Masonry.h"

@implementation MyExperienceListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        
		self.name = [[UILabel alloc] init];
		self.name.font = [UIFont systemFontOfSize:16];
		self.name.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
		[self addSubview:self.name];

		self.time = [[UILabel alloc] init];
		self.time.font = [UIFont systemFontOfSize:12];
		self.time.textColor = [UIColor colorWithWhite:0.376 alpha:1.000];
		[self addSubview:self.time];

		self.imageV = [[UIImageView alloc] init];
		[self addSubview:self.imageV];
    
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self masonry];
	}
	return self;
}

- (void)masonry
{
	WeakSelf
	[self.name mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(weakSelf);
		make.left.equalTo(weakSelf).offset(15);
	}];
    
    [self.name setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [self.name setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf.imageV.mas_left).offset(-15);
        make.left.equalTo(weakSelf.name.mas_right).offset(15);
    }];
    
    

	[self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerY.equalTo(weakSelf);
		make.right.equalTo(weakSelf).offset(-15);
		make.height.width.mas_equalTo(16);
	}];
}

@end
