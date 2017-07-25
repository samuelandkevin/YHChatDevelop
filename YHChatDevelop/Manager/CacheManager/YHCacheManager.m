//
//  YHCacheManager.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/3.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHCacheManager.h"
#import <objc/runtime.h>
#import "YHSerializeKit.h"
#import "YHChatDevelop-Swift.h"

//有效率时长
static  long const kMyCardValidDuration = 0;
static  long const kWorkgroupDynamicListValidDuration = 3600 * 1;
static  long const kMyDynamicListValidDuration = 3600 * 1;
static  long const kMyFriendsListValidDuration = 60;
static  long const kMyABContactListValidDuration = 0;
static  long const kBigNameListValidDuration = 0;
static  long const kMyVisitorsListValidDuration = 0;
static  long const kNewFriendsListValidDuration = 0;
static  long const kIndustryListValidDuration   = 3600 * 24 * 7;
static  long const kNotiCommentSingletonValidDuration = 3600 * 24 * 30;
static  long const kConversationSingletonValidDuration = 0;

//date key
#define kcacheDateMyCard @"cacheDateMyCard"
#define kcacheDateWorkGroupDynamicList       @"cacheDateWorkgroupDynamicList"
#define kcacheDateMyDynamciList @"cacheDateMyDynamciList"
#define kcacheDateMyfriendsList @"cacheDateMyfriendsList"
#define kcacheDateMyABContactList @"cacheDateMyABContactList"
#define kcacheDateBigNameList @"cacheDateBigNameList"
#define kcacheDateMyVisitorsList @"cacheDateMyVisitorsList"
#define kcacheDateNewFriensList @"cacheDateNewFriensList"
#define kcacheDateIndustryList @"cacheDateIndustryList"
#define kcacheDateNotiCommentSingleton @"cacheDateNotiCommentSingleton"
#define kcacheDateConversationSingleton @"cacheDateConversationSingleton"
#define kcacheDateThirdPartyDict @"cacheDateThirdPartyDict"


//archive key
#define kArchiveKeyMyCard @"ArchiveKeyMyCard"
#define kArchiveKeyWorkGroupDynamicList @"ArchiveKeyWorkGroupDynamicList"
#define kArchiveKeyMyDynamciList @"ArchiveKeyMyDynamciList"
#define kArchiveKeyMyfriendsList @"ArchiveKeyMyfriendsList"
#define kArchiveKeyMyABContactList @"ArchiveKeyMyABContactList"
#define kArchiveKeyBigNameList @"ArchiveKeyBigNameList"
#define kArchiveKeyMyVisitorsList @"ArchiveKeyMyVisitorsList"
#define kArchiveKeyNewFriensList @"ArchiveKeyNewFriensList"
#define kArchiveKeyIndustryList @"ArchiveKeyIndustryList"
#define kArchiveKeyNotiCommentSingleton @"ArchiveKeyNotiCommentSingleton"
#define kArchiveKeyConversationSingleton @"ArchiveKeyConversationSingleton"
#define kArchiveKeyCacheThirdPartyDict @"ArchiveKeyCacheThirdPartyDict"


@interface YHCacheManager ()

@property (nonatomic,strong) YHUserInfo *cacheUserInfo;//我的名片
@property (nonatomic,strong) NSMutableArray *cacheDynamicList;  //工作圈动态
@property (nonatomic,strong) NSMutableArray *cacheMyDynamicList;//我的动态
@property (nonatomic,strong) NSMutableArray *cacheMyFriendsList;//我的好友
@property (nonatomic,strong) NSMutableArray *cacheMyABContactList;//我的通讯录
@property (nonatomic,strong) NSMutableArray *cacheBigNameList; //大咖列表
@property (nonatomic,strong) NSMutableArray *cacheMyVisitorsList;//我的访客列表
@property (nonatomic,strong) NSMutableArray *cacheNewFriendsList;//新的好友列表
@property (nonatomic,strong) NSMutableArray *cacheIndustryList;//行业职位列表
@property (nonatomic,strong) YHIMHandler    *cacheNotiCommentSingleton;//评论推送单例
@property (nonatomic,strong) NSDictionary *workgroupDict;//工作圈动态字典（按照动态类型保存动态）
@property (nonatomic,strong) NSMutableDictionary *thirdPartyDict;

@end

@implementation YHCacheManager

+ (instancetype)shareInstance
{
    static YHCacheManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHCacheManager alloc] init];
    });
    return g_instance;
    
}

- (instancetype)init{
    if (self = [super init]) {
       
    }
    return  self;
}

#pragma mark - Private
/**
 *  是否过期
 *
 *  @param cacheKey      缓存时间点的Key
 *  @param validDuration 有限时长
 *
 *  @return YES:过期 NO:有效
 */
- (BOOL)isExpiredWithCacheKey:(NSString *)cacheKey validDuration:(long)validDuration{
    //取出
    NSInteger ts = [[NSUserDefaults standardUserDefaults] integerForKey:cacheKey];
    if (ts == 0) {
        ts = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setObject:@(ts) forKey:cacheKey];
    }
    
    //旧时间日期
    NSDate *oDate = [NSDate dateWithTimeIntervalSince1970:ts];
    //时间间隔
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:oDate];
    
    if (distance > validDuration) {
        return YES;
    }
    return NO;
}

//缓存当前日期
- (void)cacheCurrentDateWithKey:(NSString *)cacheDateKey{
    if(!cacheDateKey)
        return;
    NSTimeInterval interval =  [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:cacheDateKey];
}

#pragma mark - Public

- (void)clearCacheWhenLogout{
    [self clearCacheMyCard];
    [self clearCacheMyDynamiList];
    [self clearCacheMyFriendsList];
    [self clearCacheMyVisitorsList];
    [self clearCacheNewFriendsList];
    [self clearCacheNotiCommentSingleton];
    [self clearCacheThirdPartyAccountDict];
}

/*******我的名片*********/
#pragma mark - 我的名片
//是否要更新
- (BOOL)needUpdateMyCard{
    if (!self.cacheUserInfo || [self isMyCardExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheMyCard:(YHUserInfo*)userInfo
{
    if (userInfo) {
        self.cacheUserInfo = userInfo;
        //缓存名片
    YHSERIALIZE_ARCHIVE(self.cacheUserInfo,kArchiveKeyMyCard,[self cacheMyCardFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateMyCard];
    }
}

//取出缓存
- (YHUserInfo*)getCacheMyCard
{
    
    YHSERIALIZE_UNARCHIVE(self.cacheUserInfo, kArchiveKeyMyCard, [self cacheMyCardFilePath]);
    return self.cacheUserInfo;
    
}

//清除缓存
- (void)clearCacheMyCard{
    [self deleteFileAtPath:[self cacheMyCardFilePath]];
}

//我的名片过期
- (BOOL)isMyCardExpired{
    
    return [self isExpiredWithCacheKey:kcacheDateMyCard validDuration:kMyCardValidDuration];
}


#pragma mark - 工作圈动态列表
//是否要更新
- (BOOL)needUpdateCacheWorkGroupDynamicList
{
    if (!self.cacheDynamicList.count || [self isWorkGroupDynamicListExpired]) {
        return YES;
    }
    return NO;
}

////缓存
//- (void)cacheWorkGroupDynamicList:(NSArray<YHWorkGroup*>*)listData
//{
//    
//    if (listData.count && listData) {
//        self.cacheDynamicList = [listData mutableCopy];
//        //缓存工作圈动态
//  YHSERIALIZE_ARCHIVE(self.cacheDynamicList,kArchiveKeyWorkGroupDynamicList,[self cacheWorkGroupListFilePath]);
//         [self cacheCurrentDateWithKey:kcacheDateWorkGroupDynamicList];
//    }
//}

//取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheWorkGroupDynamiList{
//    
//     YHSERIALIZE_UNARCHIVE(self.cacheDynamicList, kArchiveKeyWorkGroupDynamicList, [self cacheWorkGroupListFilePath]);
//    return self.cacheDynamicList;
//    
//}

//清除缓存
- (void)clearCacheWorkGroupDynamiList{
    [self deleteFileAtPath:[self cacheWorkGroupListFilePath]];
}

//工作圈列表过期
- (BOOL)isWorkGroupDynamicListExpired{

    return [self isExpiredWithCacheKey:kcacheDateWorkGroupDynamicList validDuration:kWorkgroupDynamicListValidDuration];
}


//按照动态标签类型缓存动态列表
//- (void)cacheWorkGroupDynamicList:(NSArray<YHWorkGroup*>*)listData dynamicType:(NSInteger)dynamicType{
//    if (listData) {
// 
//        NSString *cacheKey = [NSString stringWithFormat:@"ArchiveKeyDynList%@",[@(dynamicType) stringValue]];
//        NSString *cacheDateKey = [NSString stringWithFormat:@"cacheDateDynList%@",[@(dynamicType) stringValue]];
//        //缓存工作圈动态
//        YHSERIALIZE_ARCHIVE(listData,cacheKey,[self cacheWorkGroupListFilePathWithDynamicType:dynamicType]);
//        [self cacheCurrentDateWithKey:cacheDateKey];
//
//    }
//}
//
////按照动态类型取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheWorkGroupDynamiListWithDynamicType:(NSInteger)dynamicType{
//    
//    NSArray *retArray = [NSArray new];
//    NSString *cacheKey = [NSString stringWithFormat:@"ArchiveKeyDynList%@",[@(dynamicType) stringValue]];
//    YHSERIALIZE_UNARCHIVE(retArray, cacheKey, [self cacheWorkGroupListFilePathWithDynamicType:dynamicType]);
//    return retArray;
//}



#pragma mark - 我的动态列表
//是否要更新
- (BOOL)needUpdateCacheMyDynamicList{
    if (!self.cacheMyDynamicList.count || [self isMyDynamicListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
//- (void)cacheMyDynamciList:(NSArray<YHWorkGroup*>*)listData{
//    if (listData.count && listData) {
//        self.cacheMyDynamicList = [listData mutableCopy];
//
//  YHSERIALIZE_ARCHIVE(self.cacheMyDynamicList,kArchiveKeyMyDynamciList,[self cacheMyDynamicListFilePath]);
//        [self cacheCurrentDateWithKey:kcacheDateMyDynamciList];
//    }
//}

//取出缓存
//- (NSArray<YHWorkGroup*>*)getCacheMyDynamiList{
//   
//    YHSERIALIZE_UNARCHIVE(self.cacheMyDynamicList, kArchiveKeyMyDynamciList, [self cacheMyDynamicListFilePath]);
//    
//    return self.cacheMyDynamicList;
//}

//清除缓存
- (void)clearCacheMyDynamiList{
    [self deleteFileAtPath:[self cacheMyDynamicListFilePath]];
}

//我的动态列表过期
- (BOOL)isMyDynamicListExpired{
    
    return [self isExpiredWithCacheKey:kcacheDateMyDynamciList validDuration:kMyDynamicListValidDuration];
}

#pragma mark - 我的好友列表
//是否要更新
- (BOOL)needUpdateCacheMyFriendsList
{
    if (!self.cacheMyFriendsList.count || [self isMyFriendsListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheMyFriendsList:(NSArray<YHUserInfo*>*)listData{
    if (listData) {
        self.cacheMyFriendsList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheMyFriendsList,kArchiveKeyMyfriendsList,[self cacheMyFriendsListFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateMyfriendsList];
    }
}


//取出缓存
- (NSArray<YHUserInfo*>*)getCacheMyFriendsList{

    YHSERIALIZE_UNARCHIVE(self.cacheMyFriendsList, kArchiveKeyMyfriendsList, [self cacheMyFriendsListFilePath]);
    return self.cacheMyFriendsList;
}

//清除缓存
- (void)clearCacheMyFriendsList{
    [self deleteFileAtPath:[self cacheMyFriendsListFilePath]];
}

//我的好友列表过期
- (BOOL)isMyFriendsListExpired{
    
    return [self isExpiredWithCacheKey:kcacheDateMyfriendsList validDuration:kMyFriendsListValidDuration];
}

/*******我的通讯录*********/
#pragma mark - 我的通讯录
//是否要更新
- (BOOL)needUpdateCacheMyABContactList{
    if (!self.cacheMyABContactList.count || [self isMyABContactListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheMyABContactList:(NSArray<YHABUserInfo*>*)listData{
    if (listData.count && listData) {
        self.cacheMyABContactList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheMyABContactList,kArchiveKeyMyABContactList,[self cacheMyABContactListFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateMyABContactList];
    }

}

//取出缓存
- (NSArray<YHABUserInfo*>*)getCacheMyABContactList{
    
    YHSERIALIZE_UNARCHIVE(self.cacheMyABContactList, kArchiveKeyMyABContactList, [self cacheMyABContactListFilePath]);
    return self.cacheMyABContactList;
}

//清除缓存
- (void)clearCacheMyABContactList{
    [self deleteFileAtPath:[self cacheMyABContactListFilePath]];
}

//我的通讯录列表过期
- (BOOL)isMyABContactListExpired{
    
    return [self isExpiredWithCacheKey:kcacheDateMyABContactList validDuration:kMyABContactListValidDuration];
}

/*******大咖列表列表*********/
#pragma mark - 大咖列表列表
//是否要更新
- (BOOL)needUpdateBigNameList{
    if (!self.cacheBigNameList.count || [self isBigNameListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheBigNameList:(NSArray<YHUserInfo*>*)listData{
    
    if (listData.count && listData) {
        self.cacheBigNameList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheBigNameList,kArchiveKeyBigNameList,[self cacheBigNameListFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateBigNameList];
    }

    
}

//取出缓存
- (NSArray<YHUserInfo*>*)getCacheBigNameList{

    YHSERIALIZE_UNARCHIVE(self.cacheBigNameList, kArchiveKeyBigNameList, [self cacheBigNameListFilePath]);
    return self.cacheBigNameList;
}

//清除缓存
- (void)clearCacheBigNameList{
    [self deleteFileAtPath:[self cacheBigNameListFilePath]];
}

//大咖列表过期
- (BOOL)isBigNameListExpired{
   return [self isExpiredWithCacheKey:kcacheDateBigNameList validDuration:kBigNameListValidDuration];
}

/*******我的访客*********/
#pragma mark - 我的访客
//是否要更新
- (BOOL)needUpdateMyVisitorsList{
    if (!self.cacheMyVisitorsList.count || [self isMyVisitorsListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheMyVisitorsList:(NSArray<YHUserInfo*>*)listData{
    
    if (listData.count && listData) {
        self.cacheMyVisitorsList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheMyVisitorsList,kArchiveKeyMyVisitorsList,[self cacheMyVisitorsListFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateMyVisitorsList];
    }

}

//取出缓存
- (NSArray<YHUserInfo*>*)getCacheMyVisitorsList{
    
    YHSERIALIZE_UNARCHIVE(self.cacheMyVisitorsList, kArchiveKeyMyVisitorsList, [self cacheMyVisitorsListFilePath]);
    return self.cacheMyVisitorsList;
}

//清除缓存
- (void)clearCacheMyVisitorsList{
    [self deleteFileAtPath:[self cacheMyVisitorsListFilePath]];
}

//我的访客列表过期
- (BOOL)isMyVisitorsListExpired{
    return [self isExpiredWithCacheKey:kcacheDateMyVisitorsList validDuration:kMyVisitorsListValidDuration];
}

/*******新的好友*********/
#pragma mark - 新的好友
//是否要更新
- (BOOL)needUpdateNewFriendsList{
    if (!self.cacheNewFriendsList.count || [self isNewFriendsListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheNewFriendsList:(NSArray<YHUserInfo*>*)listData{
    if (listData.count && listData) {
        self.cacheNewFriendsList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheNewFriendsList,kArchiveKeyNewFriensList,[self cacheNewFriendsListFilePath]);
         [self cacheCurrentDateWithKey:kcacheDateNewFriensList];
    }
}
//取出缓存
- (NSArray<YHUserInfo*>*)getCacheNewFriendsList{
    
    YHSERIALIZE_UNARCHIVE(self.cacheNewFriendsList, kArchiveKeyNewFriensList, [self cacheNewFriendsListFilePath]);
    return self.cacheNewFriendsList;
}

- (void)clearCacheNewFriendsList{
    [self deleteFileAtPath:[self cacheNewFriendsListFilePath]];
}

//新的好友列表过期
- (BOOL)isNewFriendsListExpired{
    return [self isExpiredWithCacheKey:kcacheDateNewFriensList validDuration:kNewFriendsListValidDuration];
}


/*******行业职位列表*********/
#pragma mark - 行业职位列表
//是否要更新
- (BOOL)needUpdateIndustryList{
    if (!self.cacheIndustryList.count || [self isIndustryListExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheIndustryList:(NSArray<NSDictionary*>*)listData{
    if (listData.count && listData) {
        self.cacheIndustryList = [listData mutableCopy];
        
        YHSERIALIZE_ARCHIVE(self.cacheIndustryList,kArchiveKeyIndustryList,[self cacheIndustryListFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateIndustryList];
    }
}

//取出缓存
- (NSArray<NSDictionary*>*)getCacheIndustryList{
  
    YHSERIALIZE_UNARCHIVE(self.cacheIndustryList, kArchiveKeyIndustryList, [self cacheIndustryListFilePath]);
    return self.cacheIndustryList;
}

//清除缓存
- (void)clearCacheIndustryList{
    [self deleteFileAtPath:[self cacheIndustryListFilePath]];
}

//行业职位列表过期
- (BOOL)isIndustryListExpired{
    return [self isExpiredWithCacheKey:kcacheDateIndustryList validDuration:kIndustryListValidDuration];
}

/*******评论推送列表*********/
#pragma mark - 评论推送列表
//是否要更新
- (BOOL)needUpdateNotiCommentSingleton{
    if (!self.cacheNotiCommentSingleton || [self isNotiCommentSingletonExpired]) {
        return YES;
    }
    return NO;
}

//缓存
- (void)cacheNotiCommentSingleton:(YHIMHandler *)singleton{
    if (singleton) {
        self.cacheNotiCommentSingleton = singleton;
        YHSERIALIZE_ARCHIVE(self.cacheNotiCommentSingleton,kArchiveKeyNotiCommentSingleton,[self cacheNotiCommentSingletonFilePath]);
        [self cacheCurrentDateWithKey:kcacheDateNotiCommentSingleton];
    }
}

//取出缓存
- (YHIMHandler *)getCacheNotiCommentSingleton{
    
   YHSERIALIZE_UNARCHIVE(self.cacheNotiCommentSingleton, kArchiveKeyNotiCommentSingleton, [self cacheNotiCommentSingletonFilePath]);
    return self.cacheNotiCommentSingleton;
}

//清除缓存
- (void)clearCacheNotiCommentSingleton{
    [self deleteFileAtPath:[self cacheNotiCommentSingletonFilePath]];
    
//    [[YHIMHandler sharedInstance].dataArray removeAllObjects];
    [YHIMHandler sharedInstance].totalBadge = 0;
}

//评论推送列表过期
- (BOOL)isNotiCommentSingletonExpired{
    return [self isExpiredWithCacheKey:kcacheDateNotiCommentSingleton validDuration:kNotiCommentSingletonValidDuration];
}



//评论推送列表过期
- (BOOL)isConversationSingletonExpired{
    return [self isExpiredWithCacheKey:kcacheDateConversationSingleton validDuration:kConversationSingletonValidDuration];
}


#pragma mark - /*******第三方账号*********/
//- (void)cacheThirdPartyAccount:(YHThirdPModel *)model{
//
//    if (!model) {
//        DDLog(@"缓存的model为nil");
//        return;
//    }
//    
//    //字段的key值与友盟platform名一致！
//    NSString *platformName = @"tPAccount";
//    switch (model.platformType) {
//        case UMSocialPlatformType_QQ:
//            platformName = @"qq";
//            break;
//        default:
//            break;
//    }
//    
//    NSMutableDictionary *dictCache = [self getCacheThirdPartyAccountDict];
//    if (dictCache) {
//        [dictCache setObject:model forKey:platformName];
//    }
//    else{
//        NSMutableDictionary *dictWriteToF = [NSMutableDictionary new];
//        [dictWriteToF setObject:model forKey:platformName];
//        self.thirdPartyDict = dictWriteToF;
//        
//        YHSERIALIZE_ARCHIVE(self.thirdPartyDict,kArchiveKeyCacheThirdPartyDict,[self cacheThirdPartyAccountFilePath]);
//        [self cacheCurrentDateWithKey:kcacheDateThirdPartyDict];
//    }
//}

//- (NSMutableDictionary<NSString *,YHThirdPModel *> *)getCacheThirdPartyAccountDict{
//    YHSERIALIZE_UNARCHIVE(self.thirdPartyDict, kArchiveKeyCacheThirdPartyDict, [self cacheThirdPartyAccountFilePath]);
//    return self.thirdPartyDict;
//}

- (void)clearCacheThirdPartyAccountDict{
    [self deleteFileAtPath:[self cacheThirdPartyAccountFilePath]];
    self.thirdPartyDict = nil;
}

#pragma mark - CachePath
- (BOOL)deleteFileAtPath:(NSString *)filePath{
    if (!filePath || filePath.length == 0) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDLog(@"delete file error, %@ is not exist!", filePath);
        return NO;
    }
    NSError *removeErr = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeErr] ) {
        DDLog(@"delete file failed! %@", removeErr);
        return NO;
    }
    return NO;
}

- (NSString *)cachePath
{
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString *cachePath = [doc stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    return cachePath;
}

- (NSString *)cachePathInDocument{
    NSURL *docUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
    return [docUrl path];
}

- (NSString *)cacheMyCardFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"myCard"];
}

- (NSString *)cacheWorkGroupListFilePath{
   return  [[self cachePath ]stringByAppendingPathComponent:@"wgdynList"];
}

- (NSString *)cacheWorkGroupListFilePathWithDynamicType:(NSInteger)dynamicType{
    return  [[self cachePathInDocument ]stringByAppendingPathComponent:[NSString stringWithFormat:@"wgdynList%@",[@(dynamicType) stringValue]]];
}

- (NSString *)cacheMyDynamicListFilePath{
    return  [[self cachePathInDocument ]stringByAppendingPathComponent:@"mydynList"];
}

- (NSString *)cacheMyFriendsListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"myfriendsList"];
}

- (NSString *)cacheMyABContactListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"myABContactList"];
}

- (NSString *)cacheBigNameListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"bigNameList"];
}

- (NSString *)cacheMyVisitorsListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"myVisitorsList"];
}

- (NSString *)cacheNewFriendsListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"newFriendsList"];
}

- (NSString *)cacheIndustryListFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"industryList"];
}

- (NSString *)cacheNotiCommentSingletonFilePath{
    return  [[self cachePath ]stringByAppendingPathComponent:@"notiCommentSingleton"];
}

- (NSString *)cacheConversationSingletonFilePath{
    return  [[self cachePathInDocument ]stringByAppendingPathComponent:@"conversationSingleton"];
}

- (NSString *)cacheThirdPartyAccountFilePath{
    return [[self cachePath ]stringByAppendingPathComponent:@"thirdPartyAccount"];
}
@end
