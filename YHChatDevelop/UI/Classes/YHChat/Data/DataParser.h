//
//  DataParser.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/4/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  数据解析器

#import <Foundation/Foundation.h>
#import "YHChatModel.h"
#import "YHUserInfo.h"
#import "YHGroupMember.h"
#import "YHChatGroupModel.h"
#import "YHChatListModel.h"
#import "YHCompanyInfo.h"
#import "YHAboutModel.h"
#import "YHWorkGroup.h"
#import "YHCommentData.h"
#import "YHExpressionHelper.h"
#import "YHGroupInfo.h"

@interface DataParser : NSObject

+ (DataParser *)shareInstance;


//解析工作圈模型列表
- (NSArray<YHWorkGroup*> *)parseWorkGroupListWithData:(NSArray<NSDictionary *> *)listData curReqPage:(int)curReqPage;

//解析工作圈模型
- (YHWorkGroup *)parseWorkGroupWithDict:(NSDictionary *)dict curReqPage:(int)curReqPage;

//解析评论列表
- (NSArray<YHCommentData*> *)parseCommentListWithListData:(NSArray<NSDictionary *>*)listData;

//解析评论model
- (YHCommentData *)parseCommentDataWithDict:(NSDictionary *)dict;
/**
 *  解析关于Model
 *
 */
- (YHAboutModel *)parseAboutModelWithDict:(NSDictionary *)dict;

/**
 *  解析工作圈模型列表
 */
- (NSArray<YHWorkGroup*> *)parseWorkGroupListWithData:(NSArray<NSDictionary *> *)listData curReqPage:(int)curReqPage;

/**
 *  解析用户列表
 */
- (NSArray <YHUserInfo*>*)parseUserListWithListData:(NSArray<NSDictionary*> *)listData curReqPage:(int)curReqPage;

/**
 *  解析用户信息
 */
- (YHUserInfo*)parseUserInfo:(NSDictionary *)dict curReqPage:(int)curReqPage isSelf:(BOOL)isSelf;


//解析企业信息
- (YHCompanyInfo *)parseCompanyInfo:(NSDictionary *)dict;

/**
 *  解析聊天记录Model
 *
 */
- (NSArray<YHChatModel *>*)parseChatLogWithListData:(NSArray<NSDictionary *>*)listData;

// 解析从某个日期到指定日期的聊天记录
- (NSArray<YHChatModel *>*)parseChatLogWithListData:(NSArray<NSDictionary *>*)listData fromOldChatLog:(YHChatModel *)oldChatLog toNewChatLog:(YHChatModel *)newChatLog;


/**
 解析一条聊天记录
 
 @param dict <#dict description#>
 @return <#return value description#>
 */
- (YHChatModel *)parseOneChatLogWithDict:(NSDictionary *)dict;

/**
 解析群成员列表
 
 @param listData 列表Dict
 @return 数组(YHGroupMember*)
 */
- (NSArray<YHGroupMember*>*)parseGroupMembersWithList:(NSArray <NSDictionary*>*)listData;


/**
 解析一个群成员
 
 @param dict dict
 @return YHGroupMember
 */
- (YHGroupMember *)parseGroupMemberWithDict:(NSDictionary *)dict;

/**
 解析一个群信息
 
 @param dict dict
 @return YHGroupInfo
 */
- (YHGroupInfo *)parseGroupInfoWithDict:(NSDictionary *)dict;

/**
 解析群列表
 
 @param listData 列表Dict
 @return 数组(YHChatGroupModel*)
 */
- (NSArray<YHChatGroupModel *>*)parseGroupListWithListData:(NSArray<NSDictionary *>*)listData;


/**
 解析一个群Model
 
 @param dict
 @return 群Model
 */
- (YHChatGroupModel *)parseGroupModelWithDict:(NSDictionary *)dict;


/**
 解析聊天列表
 
 @param listData 列表Dict
 @return 数组(YHChatListModel*)
 */
- (NSArray<YHChatListModel *>*)parseChatListWithListData:(NSArray<NSDictionary *>*)listData;
/**
 解析一个YHChatListModel
 
 @param dict dict
 @return YHChatListModel
 */
- (YHChatListModel *)parseChatListModelWithDict:(NSDictionary *)dict;
@end
