//
//  YHPicModel.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHPicModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHPicModel

+ (NSString *)yh_primaryKey{
    return @"oriPicUrl";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"oriPicUrl":YHDB_PrimaryKey};
}

@end
