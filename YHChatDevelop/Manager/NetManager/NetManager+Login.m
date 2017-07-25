//
//  NetManager+Login.m
//  YHChat
//
//  Created by samuelandkevin on 2017/6/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "NetManager+Login.h"
#import "DataParser.h"
#import <CommonCrypto/CommonCrypto.h>
#import "HHUtils.h"
#import "OpenUDID.h"
#import "YHCompanyInfo.h"

#define TaxTaoAppId @"6f76a5fbf03a412ebc7ddb785d1a8b10"//税道APPId
#define kRequiedKeyAndValue @("app_id"):(TaxTaoAppId)
@implementation NetManager (Login)
#pragma mark - Private

- (void)_loginWithRequestDict:(NSDictionary *)requestDict complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathLogin;
    
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
            
//            [JPUSHService setTags:nil alias:accessToken fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//                DDLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags, iAlias);
//                if (iResCode == 1) {
//                    DDLog(@"修改别名失败");
//                    
//                }
//            }];
            
            //2.数据解析
            YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:userInfoDict curReqPage:0 isSelf:YES];
            YHCompanyInfo *companyInfo = [[DataParser shareInstance] parseCompanyInfo:companyInfoDict];
            userInfo.accessToken = accessToken;
            userInfo.companyInfo = companyInfo;
            
            //3.回调
            complete(YES,userInfo);
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

#pragma mark - Public
//验证手机号是否可以进行注册
- (void)getVerifyphoneNum:(NSString *)phoneNum complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathVerifyPhoneExist;
    
    NSDictionary *dict = @{
                           @"mobile":phoneNum,
                           kRequiedKeyAndValue
                           };
    
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success)
        {
            complete(YES,obj);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//注册
- (void)postRegisterWithPhoneNum:(NSString *)phoneNum veriCode:(NSString *)veriCode passwd:(NSString *)passwd complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathRegister;
    
    NSDictionary *dict = @{
                           @"mobile":   phoneNum,
                           @"password":  passwd,
                           @"phoneimei":[OpenUDID value],
                           @"phonetype":[HHUtils phoneType],
                           @"phonesys": [HHUtils phoneSystem],
                           @"version":  [HHUtils appStoreNumber],
                           @"build":    [HHUtils appBulidNumber],
                           @"platform": iOSPlatform,
                           @"verificationCode":veriCode,
                           kRequiedKeyAndValue
                           };
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if(success)
        {
            //1.返回参数判断
            NSDictionary *jsonObj = obj;
            id dictData  = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSDictionary *userInfoDict = dictData[@"account"];
            NSString    *accessToken   = dictData[@"accessToken"];
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
            complete(YES,userInfo);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//验证token是否有效(直接登录用到)
- (void)postValidateTokenWithUserInfo:(YHUserInfo *)userInfo complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathValidateToken;
    
    
    NSString *uid   = [[NSUserDefaults standardUserDefaults] objectForKey:kUserUid];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    
    if(!uid || !token){
        DDLog(@"用户id 或 accessToken为nil!");
        complete(NO,@"用户id 或 accessToken为nil!");
        return;
    }
    
    NSDictionary *dict = @{
                           @"userId":uid,
                           @"accessToken" :token,
                           kRequiedKeyAndValue
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

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

//短信验证码登录
- (void)postLoginWithPhoneNum:(NSString *)phoneNum verifyCode:(NSString *)verifyCode complete:(NetManagerCallback)complete{
    
    NSDictionary *dict = @{
                           @"loginUser"        :phoneNum,
                           @"verificationCode" :verifyCode,
                           @"phoneimei":        [OpenUDID value],
                           @"phonetype":        [HHUtils phoneType],
                           @"phonesys":         [HHUtils phoneSystem],
                           @"version":          [HHUtils appStoreNumber],
                           @"build":            [HHUtils appBulidNumber],
                           @"platform":         iOSPlatform,
                           kRequiedKeyAndValue
                           };
    
    [self _loginWithRequestDict:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

//重置密码后登录
- (void)postLoginWithPhoneNum:(NSString*)phoneNum verifyCode:(NSString *)verifyCode newPasswd:(NSString*)newPasswd complete:(NetManagerCallback)complete{
    //密码MD5加密
    
    NSString *requestUrl = [YHProtocol share].pathForgetPasswd;
    
    NSString *passwdMD5 = [HHUtils md5HexDigest:newPasswd];
    
    NSDictionary *dictForget = @{
                                 @"mobile"        :phoneNum,
                                 @"verificationCode" :verifyCode,
                                 @"password"         :passwdMD5,
                                 @"platform":iOSPlatform,
                                 kRequiedKeyAndValue
                                 };
    
    
    [self postWithRequestUrl:requestUrl parameters:dictForget complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
    
}

//退出登录
- (void)postLogoutComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathLogout;
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

//批量校验手机号是否已注册
- (void)postVerifyPhonesAreRegistered:(NSArray *)phoneNums complete:(NetManagerCallback)complete
{
    
    NSString *requestUrl = [YHProtocol share].pathWhetherPhonesAreRegistered;
    
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken)
    {
        complete(NO,@"用户token 为nil");
        return;
    }
    
    if (!phoneNums || !phoneNums.count) {
        complete(NO,@"手机号 为nil");
        return;
    }
    
    NSString *phones =  [phoneNums componentsJoinedByString:@","];
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"phones":phones,
                             kRequiedKeyAndValue
                             };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success) {
            id dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *accounts  =  dictData[@"account"];
            
            NSDictionary *dictRet = [NSDictionary new];
            NSMutableArray *registerUserIds = [NSMutableArray new];
            NSMutableArray *registerUserPhoneNums = [NSMutableArray new];
            if (accounts && accounts.count)
            {
                for (NSDictionary *dict in accounts) {
                    
                    NSString *userId    = dict[@"id"];
                    NSString *userPhone = dict[@"mobile"];
                    if (userId && userId.length)
                    {
                        
                        [registerUserIds addObject:userId];
                        if (userPhone) {
                            [registerUserPhoneNums addObject:userPhone];
                        }
                        
                    }
                }
            }
            dictRet = @{
                        @"id":registerUserIds,
                        @"mobile":registerUserPhoneNums
                        };
            complete(YES,dictRet);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//验证第三方账号登录是否有效
- (void)postVerifyThirdPartyWithUid:(NSString *)uid platform:(PlatformType)platform complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathVerifyThridPartyAccount;
    
    if (!uid.length) {
        complete(NO,@"第三方uid为nil");
        return;
    }
    
    //appId + uid 然后md5加密
    NSString *composeStr = [NSString stringWithFormat:@"%@%@",TaxTaoAppId,uid];
    NSString *passwdMD5 = [HHUtils md5HexDigest:composeStr];
    NSDictionary *params = @{
                             @"identifier":uid,
                             @"identityType":@(platform),
                             @"checkCode":passwdMD5,
                             @"platform":iOSPlatform,
                             kRequiedKeyAndValue
                             };
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
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
            if (!userInfoDict) {
                complete(NO,@"用户信息为nil!");
                return ;
            }
            if (!accessToken) {
                complete(NO,@"accessToken 为nil!");
                return;
            }
            
//            [JPUSHService setTags:nil alias:accessToken fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//                DDLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags, iAlias);
//                if (iResCode == 1) {
//                    DDLog(@"修改别名失败");
//                    
//                }
//            }];
            
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

//第三方账号登录绑定手机号
- (void)postBindPhone:(NSString *)phone platform:(PlatformType)platform thridPartyUid:(NSString *)thridPartyUid verifyCode:(NSString *)verifyCode complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathBindPhoneByThirdPartyAccountLogin;
    
    if(!phone.length){
        complete(NO,@"手机号为nil!");
        return;
    }
    if (!verifyCode.length) {
        complete(NO,@"验证码为nil");
        return;
    }
    if (!thridPartyUid.length) {
        complete(NO,@"第三方账号为nil");
        return;
    }
    
    //appId + uid 然后md5加密
    NSString *composeStr = [NSString stringWithFormat:@"%@%@",TaxTaoAppId,thridPartyUid];
    NSString *passwdMD5 = [HHUtils md5HexDigest:composeStr];
    NSDictionary *params = @{
                             @"mobile":phone,
                             @"verificationCode":verifyCode,
                             @"identifier":thridPartyUid,
                             @"identityType":@(platform),
                             @"platform":iOSPlatform,
                             @"checkCode":passwdMD5,
                             @"app_id":TaxTaoAppId
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if(success)
        {
            //1.返回参数判断
            NSDictionary *jsonObj = obj;
            id dictData  = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSDictionary *userInfoDict = dictData[@"account"];
            NSString    *accessToken   = dictData[@"accessToken"];
            if (!userInfoDict) {
                complete(NO,@"用户信息为nil!");
                return ;
            }
            if (!accessToken) {
                complete(NO,@"accessToken 为nil!");
                return;
            }
            
//            [JPUSHService setTags:nil alias:accessToken fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//                DDLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags, iAlias);
//                if (iResCode == 1) {
//                    DDLog(@"修改别名失败");
//                    
//                }
//            }];
            
            //2.数据解析
            YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:userInfoDict curReqPage:0 isSelf:YES];
            userInfo.accessToken = accessToken;
            complete(YES,userInfo);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//第三方绑定手机后设置密码
- (void)postThridPartyLoginAndSetPasswd:(NSString *)passwd complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathThridPartyLoginSetPasswd;
    
    if(!passwd.length){
        complete(NO,@"密码为nil!");
        return;
    }
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"用户token 为nil");
        return;
    }
    NSString *passwdMD5 = [HHUtils md5HexDigest:passwd];
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"password":passwdMD5
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}


/**
 提交启动日志
 
 @param complete 成功失败回调
 */
- (void)postCommitBootLoggingComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathBootLogging;
    
    //未登录为空
    NSString *uid = [YHUserInfoManager sharedInstance].userInfo.uid;
    if (![YHUserInfoManager sharedInstance].userInfo.uid) {
        uid = @"";
    }
    
    //0-2G，1-3G，2-4G，3-WIFI
    int networkType = 2;//默认4G网络
    if (self.currentNetWorkStatus == YHNetworkStatus_ReachableViaWiFi) {
        networkType = 3;
    }
    
    //0-移动，1-联通，2-电信
    int carrierType = 0;
    NSString *carrierName = [HHUtils carrierName];
    if ([carrierName rangeOfString:@"移动"].location != NSNotFound) {
        carrierType = 0;
    }else if([carrierName rangeOfString:@"联通"].location != NSNotFound){
        carrierType = 1;
    }else if ([carrierName rangeOfString:@"电信"].location != NSNotFound){
        carrierType = 2;
    }
    
    
    NSDictionary *params = @{
                             @"appId":TaxTaoAppId,
                             @"userId":uid,
                             @"phoneImei":[OpenUDID value],
                             @"phoneSys":[HHUtils phoneSystem],
                             @"phoneType":[HHUtils phoneType],
                             @"clientVersion":[HHUtils appStoreNumber],
                             @"platform":iOSPlatform,
                             @"networkType":@(networkType),
                             @"carrierType":@(carrierType)
                             };
    
    
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestUrl]];
    //设置请求超时
    request.timeoutInterval = 8;
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPBody = data;
    
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //创建session配置对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //创建session对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    //添加网络任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            complete(NO,error);
        }else{
            
            NSDictionary *jsonObj = nil;
            if([self canParseResponseObject:data jsonObj:&jsonObj requestUrl:requestUrl]){
                
                if([self isRequestSuccessWithJsonObj:jsonObj])
                {
                    complete(YES,jsonObj[@"data"]);
                }
                else
                {
                    complete(NO,jsonObj);
                }
            }
            else{
                complete(NO,kParseError);
            }
            
        }
    }];
    
    [task resume];
}

//税道网页登录
- (void)postLoginByWebPage:(NSString *)QRCodeId complete:(NetManagerCallback)complete{
    
    
    NSString *requestUrl = [YHProtocol share].pathLoginByWebPage;
    if(!QRCodeId.length){
        complete(NO,@"QRCodeId is nil");
        return;
    }
    
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"用户token 为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"uuid":QRCodeId,
                             @"token":[YHUserInfoManager sharedInstance].userInfo.accessToken
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}


@end
