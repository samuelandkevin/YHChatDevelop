//
//  YHNetManager.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  人脉请求

#import "NetManager.h"

//投诉类型
typedef NS_ENUM(int,ComplainType){
    ComplainType_User = 0 ,//投诉用户
    ComplainType_Dyn      ,//投诉动态
    ComplainType_GroupChat //投诉群
};


@interface NetManager (Connections)

/**
 *  请求添加好友
 *
 *  @param friendId 好友Id
 *  @param complete 成功失败回调
 */
- (void)postAddFriendwithFriendId:(NSString *)friendId complete:(NetManagerCallback)complete;

/**
 *  请求删除好友
 *
 *  @param friendId 好友Id
 *  @param complete 成功失败回调
 */
- (void)postDeleteFriendWithFrinedId:(NSString *)friendId complete:(NetManagerCallback)complete;

/**
 *  获取新的好友
 *
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)postNewAddFriendsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  获取我的好友
 *
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)postMyFriendsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  访问名片详情
 *
 *  @param tagretUid 目标用户Uid
 *  @param complete  成功失败回调
 */
- (void)getVisitCardDetailWithTargetUid:(NSString *)tagretUid complete:(NetManagerCallback)complete;

/**
 *  其他用户与我的关系查询
 *
 *  @param userIds  其他用户ID数组
 *  @param complete 成功返回是userStauts数组,数组元素是NSDictionary,有 status，uId两个key
 //status :0 已申请 1 已添加
 //uId    :用户Id
 */
- (void)postGetRelationAboutMeWithUserIds:(NSArray *)userIds complete:(NetManagerCallback)complete;

//接受加好友请求
- (void)postAcceptAddFriendRequest:(NSString *)applicantId complete:(NetManagerCallback)complete;

/**
 *  搜索好友
 *
 *  @param keyWord  关键字
 *  @param complete 成功返回一个YHUserInfo.
 */
- (void)postFindFriendsWithKeyWord:(NSString *)keyWord complete:(NetManagerCallback)complete;

/**
 *  获取某用户的账号信息（手机号和税道账号）
 *
 *  @param userId   用户Id
 *  @param complete dict { @"mobilePhone":mobilePhone,
 @"taxAccount":taxAccount}
 */
- (void)getUserAccountWithUserId:(NSString *)userId complete:(NetManagerCallback)complete;

/**
 *  搜索人脉
 *
 *  @param keyWord     关键词
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getSearchConnectionWithKeyWord:(NSString *)keyWord count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  投诉
 *
 *  @param content     投诉内容
 *  @param type        投诉类型
 *  @param targetID    投诉对象ID
 *  @param complete    成功失败回调
 */
- (void)postComplainContent:(NSString *)content type:(ComplainType)type targetID:(NSString*)targetID complete:(NetManagerCallback)complete;

/**
 *  修改用户黑名单
 *
 *  @param targetID    被拉黑用户ID
 *  @param add         YES:添加到黑名单 NO:从黑名单移除
 *  @param complete    成功失败回调
 */
- (void)postModifyBlacklistWithTargetID:(NSString *)targetID add:(BOOL)add complete:(NetManagerCallback)complete;


/**
 删除好友申请记录
 
 @param friID 好友ID
 @param complete 成功失败回调
 */
- (void)postDeleteRecordOfAddFriWithFriID:(NSString *)friID complete:(NetManagerCallback)complete;
@end
