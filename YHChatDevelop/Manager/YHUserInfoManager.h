//
//  YHUserInfoManager.h
//  PikeWay
//
//  Created by kun on 16/4/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHUserInfo.h"
//#import "YHAboutModel.h"


@interface YHUserInfoManager : NSObject

/**
 *  当前登录的用户信息(单例)
 */
@property (nonatomic, strong)YHUserInfo *userInfo;
@property (nonatomic, assign)BOOL isHandleringTokenExpried;//正在处理token失效
@property (nonatomic, copy)NSString  *companyWeb;//公司网页(通知用户跳转下载App)
//@property (nonatomic, strong)NSArray <YHAboutModel*>*aboutArray;
@property (nonatomic, assign) BOOL bindQQSuccess;//成功绑定QQ
@property (nonatomic, assign) BOOL bindWechatSuccess;
@property (nonatomic, assign) BOOL bindSinaSuccess;

+ (instancetype)sharedInstance;

/**
    是否已有用户登录过
 */
- (BOOL)hasLoggedin;

/**
 *  登录成功(进行操作有：赋值用户信息给单例,更新用户偏好设置)
 *
 *  @param userInfo 用户Model
 */
- (void)loginSuccessWithUserInfo:(YHUserInfo *)userInfo;

/**
 处理Token失效
 */
- (void)handleTokenUnavailable;

/**
    退出账号(清除登录过的痕迹)
 */
- (void)logout;

/**
 *  token是否有效,是否过期
 *
 *  @param complete 回调YES：有效 ,NO：无效
 */
- (void)isTokenValideComplete:(void(^)(BOOL tokenValid))complete;

/**
 *  直接登录（不用输入账号密码）
 */
- (void)loginDirectly;


/**
    验证令牌是否有效
 */
- (void)valideUserTokenComplete:(void(^)(BOOL success, id obj))callback;


/**
 *  是否完善个人信息
 *
 *  @return YES:完善 NO:没完善
 */
- (BOOL)hasCompleteUserInfo;

/**
 *  检查更新
 */
- (void)checkUpdate;

/**
 *  获取App基本信息
 */
- (void)getAppBaseInfoComplete:(void(^)(BOOL isOK,id obj))complete;

//提交启动日志
- (void)commitBootLoggingComplete:(void(^)(BOOL success,id obj))complete;

@end
