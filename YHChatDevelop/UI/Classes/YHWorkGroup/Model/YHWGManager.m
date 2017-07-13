//
//  YHWGManager.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/27.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
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
