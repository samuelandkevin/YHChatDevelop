//
//  YHMyDynManager.m
//  PikeWay
//
//  Created by YHIOS002 on 16/6/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHMyDynManager.h"

@implementation YHMyDynManager

+ (instancetype)shareInstance{
    static YHMyDynManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHMyDynManager alloc] init];
    });
    return g_instance;
}

- (NSMutableArray<YHWorkGroup *> *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray<NSNotification *> *)myDynPageNeedRefresh{
    if (!_myDynPageNeedRefresh) {
        _myDynPageNeedRefresh = [[NSMutableArray alloc] init];
    }
    return _myDynPageNeedRefresh;
}

@end
