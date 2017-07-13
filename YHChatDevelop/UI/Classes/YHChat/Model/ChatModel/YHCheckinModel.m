//
//  YHCheckinModel.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHCheckinModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHCheckinModel

+ (NSString *)yh_primaryKey{
    return @"oriPicUrl";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"oriPicUrl":YHDB_PrimaryKey};
}

@end
