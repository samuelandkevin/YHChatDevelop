//
//  OCtoSwiftUtil.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/11/3.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  OC转Swift工具

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface OCtoSwiftUtil : NSObject

/*******JS的OC转Swift*****/

+ (void )convertWithJSContext:(JSContext *)jsContext funcName:(NSString *)funcName complete:(void(^)())complete;


+ (id)convertToObjectWithJsonString:(NSString *)jsonString;

/*******非JS的OC转Swift*****/

//获取Url路径
+ (NSURL *)getUrlWithPath:(NSString *)path encode:(BOOL)encode;


//像素绘图
+ (UIImage *)specialColorImage:(UIImage*)image withRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

+ (NSInteger)getLocationWithTargetString:(NSString *)targetString sourceString:(NSString *)sourceString;
@end
