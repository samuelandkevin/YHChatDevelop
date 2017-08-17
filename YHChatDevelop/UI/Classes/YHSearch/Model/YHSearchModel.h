//
//  YHSearchModel.h
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"

@interface YHSearchModel : NSObject

@property (nonatomic,strong) NSMutableArray <YHWorkGroup*>* dynByTimeArray;
@property (nonatomic,strong) NSMutableArray <YHWorkGroup*>* dynByHotArray;

@property (nonatomic,assign) NSIndexPath *indexPathInTimePage;
@property (nonatomic,assign) NSIndexPath *indexPathInHotPage;
+ (instancetype)shareInstance;

@end
