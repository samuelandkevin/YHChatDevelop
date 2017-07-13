//
//  YHGroupInfo.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/6/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  群信息

#import <Foundation/Foundation.h>
#import "YHGroupMember.h"

@interface YHGroupInfo : NSObject

@property (nonatomic,copy)NSString *createdDate;//创建时间
@property (nonatomic,copy)NSString *createdID;  //群主ID
@property (nonatomic,copy)NSString *createdName;//群主名称
@property (nonatomic,copy)NSString *groupDesc;  //群描述
@property (nonatomic,copy)NSString *groupIconUrl;//群图标
@property (nonatomic,copy)NSString *groupLabel;
@property (nonatomic,copy)NSString *groupName;//群名字
@property (nonatomic,assign)int     groupState;//群状态
@property (nonatomic,copy)NSString *groupID;   //群ID
@property (nonatomic,assign)int     memberCount;//群人数
@property (nonatomic,strong)NSArray *memberHeadUrls;//群员头像url
@property (nonatomic,strong)NSArray <YHGroupMember *>*members;
@property (nonatomic,copy)NSString  *updatedDate;//更新时间

@end
