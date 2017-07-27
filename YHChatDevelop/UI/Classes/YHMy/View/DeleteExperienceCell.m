//
//  DeleteExperienceCell.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/23.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "DeleteExperienceCell.h"
#import "Masonry.h"

@implementation DeleteExperienceCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.deleteBtn.backgroundColor = kBlueColor;
        [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.deleteBtn.layer.cornerRadius = 5;
        self.deleteBtn.layer.masksToBounds = YES;
        [self.deleteBtn addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.deleteBtn];
        [self masonry];
    }
    return self;
}

-(void)doDelete:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:Event_Experience_Delete object:[NSNumber numberWithInteger:self.experience]];
}

-(void)clickAble
{
    self.deleteBtn.backgroundColor =kBlueColor;
    self.deleteBtn.userInteractionEnabled = YES;
}

-(void)clickDisable
{
    self.deleteBtn.backgroundColor = [UIColor lightGrayColor];
    self.deleteBtn.userInteractionEnabled = NO;
}

-(void)masonry
{
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(10, 15, 10, 15));
    }];
}

@end
