//
//  YHChatGroupModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatGroupModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHChatGroupModel

+ (NSString *)yh_primaryKey{
    return @"groupID";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"groupID":YHDB_PrimaryKey};
}

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{
             @"groupIconUrl":[NSURL class],
             @"memberHeadUrls":[NSURL class]
             };
}

+ (NSArray *)yh_propertyDonotSave{
    return @[@"isSelected"];
}

@end
