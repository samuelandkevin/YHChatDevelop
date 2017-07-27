//
//  YHMyDynManager.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"

@interface YHMyDynManager : NSObject

@property (nonatomic,strong) NSMutableArray <YHWorkGroup *>*dataArray;//我的动态列表
@property (nonatomic,assign) NSIndexPath *selIndexPath;

@property (nonatomic,strong) NSMutableArray <NSNotification *> *myDynPageNeedRefresh;//我的动态页面需要刷新（备注:接收到通知,但当前页面不是要刷新的页面,需要刷新的页面下一次进入时再刷新）

+ (instancetype)shareInstance;
@end
