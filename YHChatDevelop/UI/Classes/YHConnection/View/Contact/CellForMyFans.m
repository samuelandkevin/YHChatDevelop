//
//  CellForMyFans.m
//  MyProject
//
//  Created by samuelandkevin on 16/4/11.
//  Copyright © 2016年 kun. All rights reserved.
//

#import "CellForMyFans.h"
#import "UIImageView+WebCache.h"

@implementation CellForMyFans

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.imgvAvatar.layer.cornerRadius  = 22.5 ;
//    self.imgvAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserInfo:(YHUserInfo *)userInfo
{
    
    _userInfo = userInfo;
    
    NSString *userName = _userInfo.userName;
    if (!userName.length) {
        userName = @"匿名用户";
    }
    
    self.labelName.text = _userInfo.userName;
    if (_userInfo.company.length) {
        self.labelCompany.text = _userInfo.company;
    }
    if (_userInfo.job.length) {
          self.labelJob.text = _userInfo.job;
    }
  
    [self.imgvAvatar sd_setImageWithURL:_userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *cellId = @"CellForMyFans";
    CellForMyFans *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"CellForMyFans" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellId];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
    }
    return cell;
}

- (void)resetCell{
    self.labelName.text    = @"";
    self.labelCompany.text = @"";
    self.labelJob.text     = @"";
}

@end
