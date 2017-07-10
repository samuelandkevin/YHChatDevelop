//
//  SqliteManager+Fris.h
//  PikeWay
//
//  Created by YHIOS002 on 17/1/3.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "SqliteManager.h"

@interface SqliteManager (Fris)

#pragma mark - 我的好友列表
/*
 *  更新Fris表多条信息
 */
- (void)updateFrisListWithFriID:(NSString *)friID frislist:(NSArray <YHUserInfo *>*)frislist complete:(void (^)(BOOL success,id obj))complete;


/**
 更新某个好友信息

 @param aFri 好友UserInfo
 @param updateItems  传nil就是更新model的所有字段,否则更新数组里面的指定字段。eg:updateItems = @[@"userName",@"job"]; //更新好友的姓名和职位，注意字段名要填写正确
 @param complete 成功失败回调
 */
- (void)updateOneFri:(YHUserInfo *)aFri updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete;


/**
 查询某个好友信息

 @param friID 好友ID
 @param complete 成功失败回调
 */
- (void)queryOneFriWithID:(NSString *)friID complete:(void (^)(BOOL success,id obj))complete;

/**
 查询多个好友
 
 @param friIDs 好友ID数组
 @param complete 成功失败回调
 */
- (void)queryFrisWithfriIDs:(NSArray<NSString *> *)friIDs complete:(void (^)(NSArray *successUserInfos,NSArray *failUids))complete;

/*
 *  查询Fris表
 *  @param userInfo       条件查询Dict
 *  @param fuzzyUserInfo  模糊查询Dict
 *  @param complete       成功失败回调
 *  备注:userInfo = nil && fuzzyUserInfo = nil 为全文搜索
 */
- (void)queryFrisTableWithFriID:(NSString *)friID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除Fris表
 */
- (void)deleteFrisTableWithFriID:(NSString *)friID complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除某一好友
 */
- (void)deleteOneFriWithfriID:(NSString *)friID fri:(YHUserInfo *)fri userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete;

/*
 *  删除多个好友
 */
- (void)deleteFrisWithFriID:(NSString *)friID frisList:(NSArray <YHUserInfo *>*)frisList complete:(void(^)(BOOL success,id obj))complete;
@end
