//
//  YHSynthesisSearch.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHSynthesisSearch.h"

@implementation YHSynthesisSearch

+ (instancetype)shareInstance{
    static YHSynthesisSearch *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHSynthesisSearch alloc] init];
    });
    return g_instance;
}

- (NSMutableArray<YHWorkGroup *> *)dynArray{
    if (!_dynArray) {
        _dynArray = [NSMutableArray array];
    }
    return _dynArray;
}

- (NSMutableArray<YHUserInfo *> *)friArray{
    if (!_friArray) {
        _friArray = [NSMutableArray array];
    }
    return _friArray;
}

- (NSMutableArray<YHUserInfo *> *)conArray{
    if (!_conArray) {
        _conArray = [NSMutableArray array];
    }
    return _conArray;
}

@end

