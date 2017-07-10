//
//  YHDebug.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/7.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#ifndef YHDebug_h
#define YHDebug_h

#import "YHChatDevelop-Swift.h"
#import "YHUICommon.h"

#define isNSDictionaryClass(obj) [obj isKindOfClass:[NSDictionary class]]
//token失效
#define Event_Token_Unavailable @"event.token.unavailable"


#define kSetSystemFontSize @"setSystemFontSize"
//所有公共服务的接口都必须传递 “app_id”:
#define TaxTaoAppId @"6f76a5fbf03a412ebc7ddb785d1a8b10"//税道APPId
#define kRequiedKeyAndValue @("app_id"):(TaxTaoAppId)
//令牌登录时间点
#define kAccessTokenDate        @"accessTokenDate"
//令牌
#define kAccessToken            @"accessToken"
//已经浏览过欢迎页
#define HasReadWelcomePage @"HasReadWelcomePage"
//用户手机号
#define kMobilePhone            @"mobilePhone"
//账号
#define kTaxAccount             @"taxAccount"
//是否已经登录过
#define kLoginOAuth             @"isOAuth"
//自有平台的uid
#define kUserUid                @"userUid"
//企业用户ID
#define kEnterpriseId           @"enterpriseId"

#endif /* YHDebug_h */




