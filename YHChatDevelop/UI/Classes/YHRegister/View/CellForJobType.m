//
//  CellForJobType.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "CellForJobType.h"

@implementation CellForJobType

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected){
        self.contentView.backgroundColor = kBlueColor;
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"CellForJobType";
    CellForJobType *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"CellForJobType" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellId];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
    }
    return cell;
}

@end
