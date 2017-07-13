//
//  NetManager+Login.h
//  YHChat
//
//  Created by samuelandkevin on 2017/6/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "NetManager.h"

@interface NetManager (Login)
//退出登录
- (void)postLogoutComplete:(NetManagerCallback)complete;
- (void)postLoginWithPhoneNum:(NSString *)phoneNum passwd:(NSString *)passwd complete:(NetManagerCallback)complete;
@end
