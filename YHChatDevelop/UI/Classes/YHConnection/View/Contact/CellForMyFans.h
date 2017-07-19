//
//  CellForMyFans.h
//  MyProject
//
//  Created by samuelandkevin on 16/4/11.
//  Copyright © 2016年 kun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@interface CellForMyFans : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelJob;
@property (weak, nonatomic) IBOutlet UILabel *labelCompany;
@property (strong,nonatomic) YHUserInfo *userInfo;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)resetCell;
@end
