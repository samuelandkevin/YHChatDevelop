//
//  YHGroupMember.h
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/13.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHGroupMember : NSObject

@property (nonatomic,copy) NSString *sessionID; //会话ID
@property (nonatomic,copy) NSString *groupID;   //群组ID
@property (nonatomic,copy) NSString *userID;    //用户ID
@property (nonatomic,copy) NSString *userName;  //用户名
@property (nonatomic,copy) NSString *createdDate;
@property (nonatomic,copy) NSString *updatedDate;
@property (nonatomic,copy) NSString *avtarUrl;

@end
