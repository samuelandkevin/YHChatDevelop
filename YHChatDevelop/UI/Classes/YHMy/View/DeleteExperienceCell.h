//
//  DeleteExperienceCell.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/23.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExperienceListController.h"
@interface DeleteExperienceCell : UITableViewCell

@property(nonatomic,strong) UIButton * deleteBtn;

@property(nonatomic, assign) MyExperience experience;

-(void)clickDisable;

-(void)clickAble;



@end
