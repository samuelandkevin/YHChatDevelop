//
//  YHGroupMember.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/6/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHGroupMember : NSObject

@property (nonatomic,copy) NSString *sessionID; //会话ID
@property (nonatomic,copy) NSString *groupID;   //群组ID
@property (nonatomic,copy) NSString *userID;    //用户ID
@property (nonatomic,copy) NSString *userName;  //用户名
@property (nonatomic,copy) NSString *createdDate;
@property (nonatomic,copy) NSString *updatedDate;
@property (nonatomic,copy) NSString *avtarUrl;   //头像URL
@property (nonatomic,assign)BOOL    isGroupOwner;//是群主

@end
