//
//  MyTextViewCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/11.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyTextViewCell.h"
#import "Masonry.h"

@implementation MyTextViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLabelText:) name:Event_MyListEdit_Count object:nil];
        
		self.textView = [[IQTextView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 225)];
        
        CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
		self.textView.font = [UIFont systemFontOfSize:16 + fontSize];
		self.textView.textColor = [UIColor colorWithWhite:0.557 alpha:1.000];
		[self addSubview:self.textView];
		self.textView.enablesReturnKeyAutomatically = NO; // UITextView内部判断send按钮是否可以用
        self.textView.layer.cornerRadius = 5;
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.borderWidth = 0.5;
        self.textView.layer.borderColor = [UIColor colorWithWhite:0.871 alpha:1.000].CGColor;
        self.count = [[UILabel alloc]init];
        self.count.font = [UIFont systemFontOfSize:11 + fontSize];
        self.count.textColor = [UIColor colorWithWhite:0.686 alpha:1.000];
        self.count.text = @"300";
        [self addSubview:self.count];
        [self masonry];
	}
	return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_MyListEdit_Count object:nil];
}

- (void)masonry
{
    WeakSelf
    [self.count mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.textView).offset(-10);
        make.bottom.equalTo(weakSelf.textView).offset(-10);
    }];
    

}




-(void)changeLabelText:(NSNotification*)sender
{
    NSInteger count = [sender.object integerValue];
    self.count.text = [NSString stringWithFormat:@"%ld",count];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSString *, id> *)change context:(void *)context
//{
//	DDLog(@"%@", change);
//}


@end
