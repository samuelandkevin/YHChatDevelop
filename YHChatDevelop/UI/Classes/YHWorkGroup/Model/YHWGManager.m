//
//  YHWGManager.m
//  PikeWay
//
//  Created by YHIOS002 on 16/6/27.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWGManager.h"

@implementation YHWGManager



+ (instancetype)shareInstance{
    static YHWGManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHWGManager alloc] init];
    });
    return g_instance;
}

- (NSMutableArray<NSNotification *> *)anotherPageNeedRefresh{
    if (!_anotherPageNeedRefresh) {
        _anotherPageNeedRefresh = [[NSMutableArray alloc] init];
    }
    return _anotherPageNeedRefresh;
}

@end
