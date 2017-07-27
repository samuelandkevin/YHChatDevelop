//
//  CellForLikePeople.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/31.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
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
