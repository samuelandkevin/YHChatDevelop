//
//  CellForRegister2.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/23.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "CellForRegister2.h"


@interface CellForRegister2 ()


@end

@implementation CellForRegister2

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //设置圆角
    self.btnNext.layer.cornerRadius  = 4;
    self.btnNext.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cell{
   return  [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}


#pragma mark - Action
- (IBAction)onNext:(id)sender {
    if (_onNextBlock) {
        _onNextBlock();
    }
}


@end
