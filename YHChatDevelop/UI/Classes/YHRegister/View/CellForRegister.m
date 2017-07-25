//
//  CellForRegister.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/23.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "CellForRegister.h"

@implementation CellForRegister

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cell{
    CellForRegister *cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
    return  cell;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"CellForRegister";
    CellForRegister *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"CellForRegister" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellId];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
    }
    return cell;
}

- (void)resetCell{
    self.textField.enabled = YES;
    self.viewBotLine.hidden = NO;
}

- (void)setStrPlaceHolder:(NSString *)strPlaceHolder{
    _strPlaceHolder = strPlaceHolder;
    self.textField.placeholder = _strPlaceHolder;
}

@end
