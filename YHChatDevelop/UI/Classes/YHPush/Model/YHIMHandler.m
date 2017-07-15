//
//  YHIMHandler.m
//  PikeWay
//
//  Created by YHIOS003 on 16/6/8.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHNetManager.h"
#import "YHIMHandler.h"
//#import "YHCacheManager.h"
//#import "YHSerializeKit.h"
//#import "JPUSHService.h"
//#import "MJRefresh.h"
#import "YHNetManager.h"

@interface YHIMHandler ()

@end

@implementation YHIMHandler

//SingletonCreate(YHIMHandler)
//
//YHSERIALIZE_CODER_DECODER();
//
//YHSERIALIZE_COPY_WITH_ZONE();

+ (YHIMHandler *)sharedInstance{
    static YHIMHandler *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHIMHandler alloc] init];
    });
    return g_instance;
}

- (instancetype)init
{
	self = [super init];

	if (self)
	{
		
	}
	return self;
}



- (BOOL)setBadgeModelIfNeed:(YHUnReadMsg *)badgeModel{
    
    self.badgeModel = badgeModel;
    [[NSNotificationCenter defaultCenter] postNotificationName:Event_TabbarBadeg_Update object:nil];
    return true;
}

-(BOOL)isTheSameBadgeModel:(YHUnReadMsg*)model{
    BOOL isSame = NO;
    
    if (model.groupChat == self.badgeModel.groupChat) {
        isSame = YES;
    }else{
        isSame = NO;
    }
    
    if (model.privateChat == self.badgeModel.privateChat) {
        isSame = YES;
    }else{
        isSame = NO;
    }
    
    if (model.newFri == self.badgeModel.newFri) {
        isSame = YES;
    }else{
        isSame = NO;
    }
    
    return isSame;
    
}

- (void)updateTotalBadge
{
	self.totalBadge = 0;
}

@end
