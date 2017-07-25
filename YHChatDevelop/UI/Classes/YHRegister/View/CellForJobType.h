//
//  CellForJobType.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellForJobType : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
