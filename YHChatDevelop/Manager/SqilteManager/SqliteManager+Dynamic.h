//
//  SqliteManager+Dynamic.h
//  PikeWay
//
//  Created by YHIOS002 on 17/1/4.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "SqliteManager.h"
#import "YHWorkGroup.h"


@interface SqliteManager (Dynamic)
/**
    Readme:
    dynTag< 0 :为我的动态 / 好友动态
    dynTag>=0 :公共动态标签 (暂时包括:案例分享,财税说说,花边新闻,我的动态)
 */

/*
 *  更新Dyn表多条动态
 */
- (void)updateDynWithTag:(int)dynTag userID:(NSString *)userID dynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete;

/*
 *  分页查询Dyn表
 */
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID  lastDyn:(YHWorkGroup *)lastDyn length:(int)length complete:(void (^)(BOOL success,id obj))complete;

/*
 * 模糊/条件查询Dyn表
 */
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID   userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQLDict:(NSDictionary *)otherSQLDict complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除Dyn表
 */
- (void)deleteDynTableWithType:(int)dynTag userID:(NSString *)userID complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除某一动态
 */
- (void)deleteOneDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete;

@end
