//
//  YHWGManager.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/27.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHWGManager : NSObject

@property (nonatomic,strong) NSDictionary *workGroupDict;
@property (nonatomic,strong) NSDictionary *selIndexPathDict;
@property (nonatomic,assign) NSInteger currentPage;//当前动态标签页面

@property (nonatomic,strong) NSMutableArray <NSNotification *> *anotherPageNeedRefresh;//其他的一个页面需要刷新（备注:接收到通知,但当前页面不是要刷新的页面,需要刷新的页面下一次进入时再刷新）

+ (instancetype)shareInstance;

@end
