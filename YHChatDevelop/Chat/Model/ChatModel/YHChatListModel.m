//
//  YHChatListModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHChatListModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHChatListModel

#pragma mark - 数据库操作
+ (NSString *)yh_primaryKey{
    return @"chatId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"chatId":YHDB_PrimaryKey};
}

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{@"sessionUserHead":[NSURL class]};
}

@end
