//
//  YHMyFriendsManager.m
//  PikeWay
//
//  Created by YHIOS002 on 16/6/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHMyFriendsManager.h"

@implementation YHMyFriendsManager

+ (instancetype)shareInstance{
    static YHMyFriendsManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHMyFriendsManager alloc] init];
    });
    return g_instance;
}

- (NSMutableArray <YHUserInfo*>*)allFriendsArray{
    if (!_allFriendsArray) {
        _allFriendsArray = [NSMutableArray array];
    }
    return _allFriendsArray;
}

-(NSMutableArray *)prefixLetters{
    if (!_prefixLetters) {
        _prefixLetters  = [[NSMutableArray alloc] init];
    }
    return _prefixLetters;
}

- (NSMutableDictionary *)usersDictSort{
    if (!_usersDictSort) {
        _usersDictSort  = [NSMutableDictionary dictionary];
    }
    return _usersDictSort;
    
}


@end
