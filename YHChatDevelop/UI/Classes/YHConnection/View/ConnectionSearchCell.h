//
//  ConnectionSearchCell.h
//  PikeWay
//
//  Created by YHIOS003 on 16/5/26.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@interface ConnectionSearchCell : UITableViewCell

@property (nonatomic,strong) YHUserInfo *userInfo;
@property(nonatomic,strong)  UIView * baseline;
@end
