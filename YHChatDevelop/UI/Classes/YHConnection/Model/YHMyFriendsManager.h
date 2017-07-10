//
//  YHMyFriendsManager.h
//  PikeWay
//
//  Created by YHIOS002 on 16/6/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHUserInfo.h"

@interface YHMyFriendsManager : NSObject

@property (nonatomic,strong) NSMutableArray <YHUserInfo*>*allFriendsArray;
@property (nonatomic,strong) NSMutableArray      *prefixLetters;
@property (nonatomic,strong) NSMutableDictionary *usersDictSort;
@property (nonatomic,strong) NSString *selPrefixLetter;//当前中的key

+ (instancetype)shareInstance;
@end
