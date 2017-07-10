//
//  YHCompanyInfo.m
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/25.
//  Copyright © 2017年 YHSoft. All rights reserved.
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
