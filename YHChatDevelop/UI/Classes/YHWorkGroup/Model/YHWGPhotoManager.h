//
//  YHWGPhotoManager.h
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroupPhotoContainer.h"

@interface YHWGPhotoManager : NSObject

+ (instancetype)shareInstance;

//获取图片容器
- (YHWorkGroupPhotoContainer *)getContainerWithPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin;

//获取图片容器高度
- (CGFloat)containerHeightWithPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin;

//设置图片容器所有图片
- (void)setupPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin;

@end
