//
//  YHCheckinModel.h
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  签到Model

#import <Foundation/Foundation.h>

@interface YHCheckinModel : NSObject

@property (nonatomic,copy) NSString *thumbPicUrl;//缩略图
@property (nonatomic,copy) NSString *oriPicUrl;  //原图
@property (nonatomic,copy) NSString *position;   //位置
@property (nonatomic,copy) NSString *msg;        //消息

@end
