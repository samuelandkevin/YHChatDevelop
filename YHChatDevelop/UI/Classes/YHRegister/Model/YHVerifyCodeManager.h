//
//  YHVerifyCodeManager.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/20.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  验证码管理

#import <Foundation/Foundation.h>

@interface YHVerifyCodeManager : NSObject

+ (instancetype)shareInstance;

/** 验证码管理：
 注册验证码
 */
- (BOOL)isExpiredRegisterVerifyCode;  //注册验证码过期
- (void)storageRegisterVCDate;        //保存获取注册验证码的日期
- (void)resetRegisterVCDate;          //重置注册验证码日期


/** 验证码管理：
 短信验证码登录
 */
- (BOOL)isExpiredLoginVerifyCode;     //短信验证码登录过期
- (void)storageLoginVCDate;           //保存获取短信验证码登录的日期
- (void)resetLoginVCDate;             //重置短信验证码日期


/** 验证码管理：
 重置密码登录
 */
- (BOOL)isExpiredResetPasswdLoginVerifyCode; //重置密码登录的验证码过期
- (void)storageRPLoginVCDate;         //保存重置密码登录验证码的日期
- (void)resetRPLoginVCDate;           //重置重设密码登录验证码日期


/** 验证码管理：
 第三方登录绑定手机
 */

-(BOOL)isExpiredLoginByThridPartyAcountVerifyCode;//短信验证码第三方登录绑定手机过期

- (void)storageLoginByThridPartyAcountVCDate;//保存获取第三方登录绑定手机短信验证码登录的日期
- (void)resetLoginByThridPartyAcountVCDate; //重置第三方登录绑定手机短信验证码日期

@end
