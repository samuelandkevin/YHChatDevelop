//
//  YHUnReadMsg.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/6.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHUnReadMsg : NSObject

@property (nonatomic,assign) int groupChat;  //群聊未读记录数
@property (nonatomic,assign) int privateChat;//私聊未读记录数
@property (nonatomic,assign) int newFri;     //未处理新好友数

@end
