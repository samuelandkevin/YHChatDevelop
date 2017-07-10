//
//  YHConfig.h
//  PikeWay
//
//  Created by YHIOS002 on 16/4/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  配置文件

#import <Foundation/Foundation.h>

@interface YHConfig : NSObject

extern const int   kDynamciTextMaxLength;   //发动态长度
extern const int   lengthForEveryRequest;   //每次请求n条
extern const int   kVerifyCodeValidDuration;//验证码有效时长

/**
 * 配置网页缓存(离线缓存+加载缓存)
 */
void configWebViewCache();
@end
