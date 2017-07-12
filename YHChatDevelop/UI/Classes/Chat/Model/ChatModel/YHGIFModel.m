//
//  YHGIFModel.m
//  YHChat
//
//  Created by YHIOS002 on 17/4/12.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHGIFModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHGIFModel
+ (NSString *)yh_primaryKey{
    return @"filePathInServer";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"filePathInServer":YHDB_PrimaryKey};
}
@end
