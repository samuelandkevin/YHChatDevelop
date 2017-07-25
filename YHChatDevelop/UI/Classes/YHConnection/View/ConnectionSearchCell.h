//
//  ConnectionSearchCell.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/26.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@interface ConnectionSearchCell : UITableViewCell

@property (nonatomic,strong) YHUserInfo *userInfo;
@property(nonatomic,strong)  UIView * baseline;
@end
