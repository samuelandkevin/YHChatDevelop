//
//  YHSearchModel.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHSearchModel.h"

@implementation YHSearchModel

+ (instancetype)shareInstance{
    static YHSearchModel *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHSearchModel alloc] init];
    });
    return g_instance;
}

- (NSMutableArray<YHWorkGroup *> *)dynByTimeArray{
    if (!_dynByTimeArray) {
        _dynByTimeArray = [NSMutableArray array];
    }
    return _dynByTimeArray;
}

- (NSMutableArray<YHWorkGroup *> *)dynByHotArray{
    if (!_dynByHotArray) {
        _dynByHotArray = [NSMutableArray array];
    }
    return _dynByHotArray;
}

@end
