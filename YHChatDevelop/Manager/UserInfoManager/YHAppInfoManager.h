//
//  YHAppInfo.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHAppInfoManager : NSObject

@property (nonatomic, assign)BOOL canOpenSideMenu;//可以打开侧边栏
@property (nonatomic, copy)  NSString *userAgent;
@property (nonatomic, assign)BOOL webCacheUseURLProtocol;//网页缓存使用协议加载（默认是使用NSURLCache加载）

+ (instancetype)shareInstanced;


- (void)canOpenSideMenu:(void(^)(BOOL canOpen,id obj))complete;
@end
