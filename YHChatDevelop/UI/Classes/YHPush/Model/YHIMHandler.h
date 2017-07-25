//
//  YHIMHandler.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/8.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHIMHandler.h"
//#import "APNsDynamicModel.h"
#import "YHUnReadMsg.h"


@interface YHIMHandler : NSObject

+ (YHIMHandler *)sharedInstance;

- (void)saveidOfDynamic:(NSString *)idOfDynamic andIdOfMsg:(id)_j_msgid;

//@property (nonatomic, strong) NSMutableArray <APNsDynamicModel *> *dataArray;

@property (nonatomic, assign) NSInteger totalBadge;

@property (nonatomic, strong) YHUnReadMsg * badgeModel;

- (BOOL)setBadgeModelIfNeed:(YHUnReadMsg *)badgeModel;

- (void)updateTotalBadge;

- (void)handleUnloadDynamic;

- (void)requestDynamicWithID:(NSString *)idOfDynamic;

@end
