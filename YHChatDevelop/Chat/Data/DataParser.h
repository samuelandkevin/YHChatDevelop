//
//  DataParser.h
//  MyProject
//
//  Created by YHIOS002 on 16/4/10.
//  Copyright © 2016年 kun. All rights reserved.
//  数据解析器

#import <Foundation/Foundation.h>
#import "YHChatModel.h"
#import "YHUserInfo.h"
#import "YHGroupMember.h"
#import "YHChatGroupModel.h"
#import "YHChatListModel.h"

@interface DataParser : NSObject

+ (DataParser *)shareInstance;
/**
 *  解析用户列表
 */
- (NSArray <YHUserInfo*>*)parseUserListWithListData:(NSArray<NSDictionary*> *)listData curReqPage:(int)curReqPage;

/**
 *  解析用户信息
 */
- (YHUserInfo*)parseUserInfo:(NSDictionary *)dict curReqPage:(int)curReqPage isSelf:(BOOL)isSelf;

/**
 *  解析聊天记录Model
 *
 */
- (NSArray<YHChatModel *>*)parseChatLogWithListData:(NSArray<NSDictionary *>*)listData;


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
