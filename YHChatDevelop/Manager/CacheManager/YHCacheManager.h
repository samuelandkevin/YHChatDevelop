//
//  YHCacheManager.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/3.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "YHWorkGroup.h"
//#import "YHABUserInfo.h"
#import "YHIMHandler.h"
//#import "YHThirdPModel.h"
#import "YHUserInfo.h"

@interface YHCacheManager : NSObject

+ (instancetype)shareInstance;

//退出登录清除缓存
- (void)clearCacheWhenLogout;

#pragma mark - /*******我的名片*********/
//是否要更新
- (BOOL)needUpdateMyCard;
//缓存
- (void)cacheMyCard:(YHUserInfo*)userInfo;
//取出缓存
- (YHUserInfo*)getCacheMyCard;
/**
 清除缓存
 */
- (void)clearCacheMyCard;

#pragma mark - /*******工作圈动态列表*********/
////是否要更新
//- (BOOL)needUpdateCacheWorkGroupDynamicList;
//
///**
// 缓存
// @param listData 动态列表数据
// */
//- (void)cacheWorkGroupDynamicList:(NSArray<YHWorkGroup*>*)listData;
////取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheWorkGroupDynamiList;
////清除缓存
//- (void)clearCacheWorkGroupDynamiList;
//
////按照动态类型缓存动态列表
//- (void)cacheWorkGroupDynamicList:(NSArray<YHWorkGroup*>*)listData dynamicType:(NSInteger)dynamicType;
////按照动态类型取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheWorkGroupDynamiListWithDynamicType:(NSInteger)dynamicType;

#pragma mark - /*******我的动态列表*********/
////是否要更新
//- (BOOL)needUpdateCacheMyDynamicList;
////缓存
//- (void)cacheMyDynamciList:(NSArray<YHWorkGroup*>*)listData;
////取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheMyDynamiList;
////清除缓存
//- (void)clearCacheMyDynamiList;

#pragma mark - /*******我的好友列表*********/
//是否要更新
- (BOOL)needUpdateCacheMyFriendsList;
//缓存
- (void)cacheMyFriendsList:(NSArray<YHUserInfo*>*)listData;
//取出缓存
- (NSArray<YHUserInfo*>*)getCacheMyFriendsList;
//清除缓存
- (void)clearCacheMyFriendsList;

#pragma mark - /*******我的通讯录*********/
//是否要更新
- (BOOL)needUpdateCacheMyABContactList;
//缓存
- (void)cacheMyABContactList:(NSArray*)listData;
//取出缓存
- (NSArray*)getCacheMyABContactList;
//清除缓存
- (void)clearCacheMyABContactList;


#pragma mark - /*******大咖列表列表*********/
//是否要更新
- (BOOL)needUpdateBigNameList;
//缓存
- (void)cacheBigNameList:(NSArray<YHUserInfo*>*)listData;
//取出缓存
- (NSArray<YHUserInfo*>*)getCacheBigNameList;
//清除缓存
- (void)clearCacheBigNameList;

#pragma mark - /*******我的访客*********/
//是否要更新
- (BOOL)needUpdateMyVisitorsList;
//缓存
- (void)cacheMyVisitorsList:(NSArray<YHUserInfo*>*)listData;
//取出缓存
- (NSArray<YHUserInfo*>*)getCacheMyVisitorsList;
//清除缓存
- (void)clearCacheMyVisitorsList;

#pragma mark - /*******新的好友*********/
//是否要更新
- (BOOL)needUpdateNewFriendsList;
//缓存
- (void)cacheNewFriendsList:(NSArray<YHUserInfo*>*)listData;
//取出缓存
- (NSArray<YHUserInfo*>*)getCacheNewFriendsList;
//清除缓存
- (void)clearCacheNewFriendsList;

#pragma mark - /*******行业职位列表*********/
//是否要更新
- (BOOL)needUpdateIndustryList;
//缓存
- (void)cacheIndustryList:(NSArray<NSDictionary*>*)listData;
//取出缓存
- (NSArray<NSDictionary*>*)getCacheIndustryList;
//清除缓存
- (void)clearCacheIndustryList;

#pragma mark - /*******评论推送列表*********/
//是否要更新
- (BOOL)needUpdateNotiCommentSingleton;
//缓存
- (void)cacheNotiCommentSingleton:(YHIMHandler *)singleton;
//取出缓存
- (YHIMHandler *)getCacheNotiCommentSingleton;
//清除缓存
- (void)clearCacheNotiCommentSingleton;

#pragma mark - /*******会话列表*********/
//是否要更新
//- (BOOL)needUpdateConversationSingleton;
////清除缓存
//- (void)clearCacheConversationSingleton;

#pragma mark - /*******第三方账号*********/
//- (void)cacheThirdPartyAccount:(YHThirdPModel *)dict;
//- (NSMutableDictionary<NSString *,YHThirdPModel *> *)getCacheThirdPartyAccountDict;
//- (void)clearCacheThirdPartyAccountDict;

#pragma mark -


@end
