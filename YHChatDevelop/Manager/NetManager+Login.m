//
//  NetManager+Login.m
//  YHChat
//
//  Created by YHIOS002 on 2017/6/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "NetManager+Login.h"
#import "DataParser.h"
#import <CommonCrypto/CommonCrypto.h>
#import "HHUtils.h"
#import "OpenUDID.h"

#define TaxTaoAppId @"6f76a5fbf03a412ebc7ddb785d1a8b10"//税道APPId
#define kRequiedKeyAndValue @("app_id"):(TaxTaoAppId)
@implementation NetManager (Login)
//登录
- (void)postLoginWithPhoneNum:(NSString *)phoneNum passwd:(NSString *)passwd complete:(NetManagerCallback)complete{
    
    //密码MD5加密
    NSString *passwdMD5 = [HHUtils md5HexDigest:passwd];
    
    NSDictionary *dict = @{
                           @"loginUser":phoneNum,
                           @"password" :passwdMD5,
                           @"phoneimei":        [OpenUDID value],
                           @"phonetype":        [HHUtils phoneType],
                           @"phonesys":         [HHUtils phoneSystem],
                           @"version":          [HHUtils appStoreNumber],
                           @"build":            [HHUtils appBulidNumber],
                           @"platform": iOSPlatform,
                           kRequiedKeyAndValue
                           };
    [self _loginWithRequestDict:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

#pragma mark - Private

- (void)_loginWithRequestDict:(NSDictionary *)requestDict complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/app_core_api/v1/account/login",kBaseURL];
    
    [self postWithRequestUrl:requestUrl parameters:requestDict complete:^(BOOL success, id obj) {
        
        if (success)
        {
            NSDictionary *jsonObj = obj;
            //1.条件判断
            id dictData  = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSDictionary *userInfoDict = dictData[@"account"];
            NSString    *accessToken   = dictData[@"accessToken"];
            NSDictionary *companyInfoDict  = dictData[@"companyInfo"];
            if (!userInfoDict) {
                complete(NO,@"用户信息为nil!");
                return ;
            }
            if (!accessToken) {
                complete(NO,@"accessToken 为nil!");
                return;
            }
            
            //2.数据解析
            YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:userInfoDict curReqPage:0 isSelf:YES];
            userInfo.accessToken = accessToken;
            
            //3.回调
            complete(YES,userInfo);
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//退出登录
- (void)postLogoutComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathLogout];
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"用户token 为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             kRequiedKeyAndValue
                             };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
    
}

- (NSString *)md5HexDigest:(NSString*)input{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)input.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
    
}
@end
