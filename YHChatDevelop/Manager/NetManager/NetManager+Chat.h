//
//  YHNetManager.h
//  PikeWay
//
//  Created by YHIOS002 on 16/10/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NetManager.h"
#import "YHChatModel.h"

@interface NetManager (Chat)

typedef NS_ENUM(int,QChatType){
    QChatType_Private = 0 ,//单聊
    QChatType_Group,       //群聊
    QChatType_All          //所有的聊天列表
};

//未读消息类型
typedef NS_ENUM(int,UnReadMsgType){
    UnReadMsgType_PriChat = 101 ,//私聊未读消息
    UnReadMsgType_GroupChat,     //群聊未读消息
    UnReadMsgType_DiposeNewFri   //未处理好友消息
};
//发起群聊
- (void)postCreatGroupChatWithUserArray:(NSArray<YHUserInfo *>*)userArray complete:(NetManagerCallback)complete;

//添加群成员
- (void)postAddGroupMemberWithGroupId:(NSString *)groupId userArray:(NSArray<YHUserInfo *>*)userArray complete:(NetManagerCallback)complete;


/**
 *  获取聊天历史记录
 *  @param sessionID  单聊用户id / 群聊群id
 *  @param chatType   0-单聊，1-群聊
 *  @param timestamp  时间戳  不传或空取小于当前时间数据
 */
- (void)postFetchChatLogWithType:(QChatType)chatType sessionID:(NSString *)sessionID timestamp:(NSString *)timestamp complete:(NetManagerCallback)complete;


/**
 获取从某个日期到指定日期的聊天记录

 @param chatType 0-单聊，1-群聊
 @param sessionID 单聊用户id / 群聊群id
 @param oldChatLog 旧的聊天记录
 @param newChatLog 新的聊天记录 传nil等于 现在时刻
 @param complete 成功失败回调
 */
- (void)postFetchChatLogWithType:(QChatType)chatType sessionID:(NSString *)sessionID fromOldChatLog:(YHChatModel *)oldChatLog  toNewChatLog:(YHChatModel *)newChatLog complete:(NetManagerCallback)complete;

/**
 *  获取未读消息
 */
- (void)postFetchUnReadMsgComplete:(NetManagerCallback)complete;


/**
 获取群聊列表
 
 @param complete 成功失败回调
 */
- (void)getGroupChatListComplete:(NetManagerCallback)complete;


//群发消息
- (void)postSendChatMsgWithArray:(NSArray<YHChatModel*>*)array complete:(NetManagerCallback)complete;

//单发消息
- (void)postSendChatMsgToReceiverID:(NSString *)rID msgType:(int)msgType msg:(NSString *)msg chatType:(QChatType)chatType complete:(NetManagerCallback)complete;

//获取聊天列表
- (void)postFetchChatListWithTimestamp:(NSString *)timestamp type:(QChatType)type complete:(NetManagerCallback)complete;

//消息置顶/取消置顶
- (void)postMsgStick:(BOOL)msgStick msgID:(NSString *)msgID complete:(NetManagerCallback)complete;

//获取群成员
- (void)getGroupMemebersWithGroupID:(NSString *)groupID complete:(NetManagerCallback)complete;

//删除会话
- (void)postDeleteSessionWithID:(NSString *)sessionID sessionUserID:(NSString *)sessionUserID complete:(NetManagerCallback)complete;

//修改群名称
- (void)postModifyGroupNameWithGroupID:(NSString *)groupID newGroupName:(NSString *)newGroupName complete:(NetManagerCallback)complete;

//修改我在群里的名称
- (void)postModiftyMyNameInGroupWithGroupID:(NSString *)groupID newName:(NSString *)newName complete:(NetManagerCallback)complete;

//转让群
- (void)postTransferGroupOwnerWithGroupID:(NSString *)groupID complete:(NetManagerCallback)complete;

//退出并且删除群
- (void)postQuitGroupWithGroupID:(NSString *)groupID complete:(NetManagerCallback)complete;

//获取群信息
- (void)postFetchGroupInfoWithGroupID:(NSString *)groupID complete:(NetManagerCallback)complete;

//消息撤回
- (void)putWithDrawMsgWithMsgID:(NSString *)msgID complete:(NetManagerCallback)complete;

//对专家评分
- (void)postGradeExpertWithExpertID:(NSString *)expertID score:(int)score sessionUserID:(NSString *)sessionUserID complete:(NetManagerCallback)complete;

@end
