//
//  YHChatGroupModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  群Model

#import <Foundation/Foundation.h>


@interface YHChatGroupModel : NSObject

@property(nonatomic,copy) NSString *groupName;
@property(nonatomic,copy) NSString *groupDesc;
@property(nonatomic,copy) NSArray <NSURL *>*groupIconUrl;
@property(nonatomic,copy) NSString *groupLabel;
@property(nonatomic,copy) NSString *groupState;
@property(nonatomic,copy) NSString *groupID;
@property(nonatomic,assign) int    memberCount;
@property(nonatomic,strong)NSArray<NSURL *> *memberHeadUrls;
@property(nonatomic,strong)NSArray *members;
@property(nonatomic,copy) NSString *updatedDate;
@property(nonatomic,copy) NSString *createdDate;
@property(nonatomic,copy) NSString *createdID;
@property(nonatomic,copy) NSString *createdName;

/******以下非服务器返回字段****/
@property(nonatomic,assign) BOOL isSelected;
@end
