//
//  CellForLikePeople.h
//  PikeWay
//
//  Created by YHIOS002 on 16/5/31.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@class CellForLikePeople;
@protocol CellForLikePeopleDelegate <NSObject>

- (void)onAvatarInLikeCell:(CellForLikePeople *)cell;

@end

@interface CellForLikePeople : UITableViewCell

@property (strong,nonatomic)YHUserInfo *userInfo;
@property (nonatomic,weak) id<CellForLikePeopleDelegate>delegate;

@end
