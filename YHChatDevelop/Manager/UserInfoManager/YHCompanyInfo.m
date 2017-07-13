//
//  YHCompanyInfo.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  企业用户信息

#import "YHCompanyInfo.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHCompanyInfo

+ (NSString *)yh_primaryKey{
    return @"uid";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"uid":YHDB_PrimaryKey};
}

@end
