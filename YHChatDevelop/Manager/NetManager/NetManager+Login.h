//
//  NetManager+Login.h
//  YHChat
//
//  Created by samuelandkevin on 2017/6/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "NetManager.h"

@interface NetManager (Login)
- (void)getVerifyphoneNum:(NSString *)phoneNum complete:(NetManagerCallback)complete;
//退出登录
- (void)postLogoutComplete:(NetManagerCallback)complete;
- (void)postLoginWithPhoneNum:(NSString *)phoneNum passwd:(NSString *)passwd complete:(NetManagerCallback)complete;
/**
 *  网页登录
 *
 *  @param QRCodeId 二维码的Id
 *  @param complete 成功失败回调
 */
- (void)postLoginByWebPage:(NSString *)QRCodeId complete:(NetManagerCallback)complete;

- (void)getVerifyphoneNum:(NSString *)phoneNum complete:(NetManagerCallback)complete;
@end
