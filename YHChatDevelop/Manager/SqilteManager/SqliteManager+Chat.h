//
//  SqliteManager+Chat.h
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "SqliteManager.h"
#import "YHChatListModel.h"
#import "YHGIFModel.h"
@interface SqliteManager (Chat)

#pragma mark - 聊天记录

/*
 *  更新ChatLog表多条信息
 */
- (void)updateChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID chatLogList:(NSArray <YHChatModel *>*)chatLogList complete:(void (^)(BOOL success,id obj))complete;

/*
 *  更新某条聊天信息
 */
- (void)updateOneChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID aChatLog:(YHChatModel*)aChatLog updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete;

/*
 *  查询ChatLog表
 *  @param userInfo       条件查询Dict
 *  @param fuzzyUserInfo  模糊查询Dict
 *  @param complete       成功失败回调
 *  备注:userInfo = nil && fuzzyUserInfo = nil 为全文搜索
 */
- (void)queryChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;


//查询ChatLog表   按长度length获取聊天记录
- (void)queryChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID  lastChatLog:(YHChatModel *)lastChatLog length:(int)length complete:(void (^)(BOOL success,id obj))complete;

//删除某条消息记录
- (void)deleteOneChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID msgID:(NSString *)msgID complete:(void(^)(BOOL success,id obj))complete;


/*
 *  删除ChatLog表
 */
- (void)deleteChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID complete:(void(^)(BOOL success,id obj))complete;


#pragma mark - 聊天列表

/*
 *  更新ChatList表多条信息
 */
- (void)updateChatListModelArr:(NSArray <YHChatListModel *>*)chatListModelArr uid:(NSString *)uid complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除ChatList表某条信息
 */
- (void)deleteOneChatListModel:(YHChatListModel *)clModel uid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete;

/*
 *  查询ChatList表
 */
- (void)queryChatListTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;

/*
 *  删除ChatLog表
 */
- (void)deleteChatListTableWithUid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete;


#pragma mark - 聊天文件
//更新聊天文件
//更新某一个办公文件
- (void)updateOfficeFile:(YHFileModel *)officeFile complete:(void (^)(BOOL success,id obj))complete;
//查询办公文件
- (void)queryOfficeFilesUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete;
//查询某个文件
- (void)queryOneOfficeFileWithFileNameInserver:(NSString *)fileNameInserver complete:(void (^)(BOOL success,id obj))complete;
//删除办公文件表
- (void)deleteOfficeFileTableComplete:(void(^)(BOOL success,id obj))complete;
//删除某一个办公文件
- (void)deleteOneOfficeFile:(YHFileModel *)officeFile userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete;

@end
