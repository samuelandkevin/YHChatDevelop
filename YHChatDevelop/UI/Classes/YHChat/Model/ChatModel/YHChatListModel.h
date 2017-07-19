//
//  YHChatListModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/23.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  聊天列表

#import <Foundation/Foundation.h>

@interface YHChatListModel : NSObject

@property (nonatomic,copy) NSString *chatId;
@property (nonatomic,assign)BOOL    isStickTop;//消息置顶
@property (nonatomic,assign)BOOL    isGroupChat;
@property (nonatomic,copy) NSString *lastContent;
@property (nonatomic,assign) int    msgType;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *sessionUserId;  //会话用户ID(好友或者群)
@property (nonatomic,copy) NSString *sessionUserName;
@property (nonatomic,assign) int    unReadCount;
@property (nonatomic,assign) BOOL   isRead;
@property (nonatomic,assign) int    memberCount;
@property (nonatomic,copy) NSString *groupName;
@property (nonatomic,copy) NSString *creatTime;      //服务器返回的时间
@property (nonatomic,copy) NSString *creatTimeFormat;//格式化后的时间
@property (nonatomic,copy) NSString *lastCreatTime;
@property (nonatomic,strong) NSArray < NSURL *> *sessionUserHead;
@property (nonatomic,copy) NSString *msgId;
@property (nonatomic,assign) int    status; //消息状态（撤回：1,未撤回：0）
@property (nonatomic,copy) NSString *updateTime;

@end

