
//  NetManager+Profile.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "NetManager+Profile.h"
#import "DataParser.h"
#import "YHAboutModel.h"
#import "SqliteManager.h"


@implementation NetManager (Profile)

#pragma mark - Private


#pragma mark - Public

- (void)postVerifyTaxAccountExist:(NSString *)taxAccount complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathTaxAccountExist;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    if (!taxAccount) {
        complete(NO,@"税道账号为空");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"username":taxAccount,
                           kRequiedKeyAndValue
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        complete(success,obj);
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
}

//编辑我的名片
- (void)postEditMyCardWithUserInfo:(YHUserInfo *)userInfo complete:(NetManagerCallback)complete{
    
    //1.url
    NSString *requestUrl = [YHProtocol share].pathEditMyCard;
    
    //2.参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    //2-1.必要参数
    NSDictionary *requiredDict = @{
                                   @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                                   @"userId":[YHUserInfoManager sharedInstance].userInfo.uid
                                   };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:requiredDict];
    
    //3.设置可选参数
    if (userInfo.userName) {
        [params setValue:userInfo.userName forKey:@"username"];
    }
    
    
    if (userInfo.sex == Gender_Man) {
        [params setValue:@(1) forKey:@"gender"];
    }else if (userInfo.sex == Gender_Women){
        [params setValue:@(0) forKey:@"gender"];
    }
    
    
    if (userInfo.workCity) {
        [params setValue:userInfo.workCity forKey:@"workCity"];
    }
    if (userInfo.workLocation) {
        [params setValue:userInfo.workLocation forKey:@"workLocation"];
    }
    
    if(userInfo.industry){
        [params setValue:userInfo.industry forKey:@"workAt"];
    }
    if (userInfo.company) {
        [params setValue:userInfo.company forKey:@"company"];
    }
    if (userInfo.job) {
        [params setValue:userInfo.job forKey:@"job"];
    }
    if (userInfo.jobTags) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:userInfo.jobTags options:0 error:&error];
        
        if (!error) {
            NSString *jobTags = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [params setValue:jobTags forKey:@"workMark"];
        }
        else{
            complete (NO,[NSString stringWithFormat:@"%@",error.localizedDescription]);
            return ;
        }
        
    }
    
    if (userInfo.avatarUrl) {
        NSString *urlstring = [userInfo.avatarUrl absoluteString];
        if (urlstring && urlstring.length) {
            [params setObject:urlstring forKey:@"profileImage"];
        }
        else{
            complete(NO,@"头像url为nil");
            return;
        }
        
    }
    
    if (userInfo.intro) {
        [params setValue:userInfo.intro forKey:@"description"];
    }
    
    if(userInfo.department){
        [params setValue:userInfo.department forKey:@"deptName"];
    }
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
        if (success) {
            
            [[SqliteManager sharedInstance] updateUserInfoWithItems:nil complete:^(BOOL success, id obj) {
                
            }];
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//获取我的名片信息
- (void)getMyCardDetailComplete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathMyCard;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid
                             };
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success) {
            
            NSDictionary *jsonObj = obj;
            //1.条件判断
            id dictData     = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSDictionary *userInfoDict = dictData[@"account"];
            
            if (!userInfoDict) {
                complete(NO,@"用户信息为nil!");
                return ;
            }
            //2.数据解析
            YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:userInfoDict curReqPage:0 isSelf:YES];
            userInfo.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
            //3.回调
            complete(YES,userInfo);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//登录后的修改密码
- (void)postModifyPasswd:(NSString *)newPasswd oldPasswd:(NSString *)oldPasswd complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathModifyPasswd;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    if(!newPasswd){
        complete(NO,@"新密码为nil");
        return;
    }
    if (!oldPasswd) {
        complete(NO,@"旧密码为nil");
        return;
    }
    
    
    NSString *newPasswdMD5 = [HHUtils md5HexDigest:newPasswd];
    NSString *oldPasswdMD5 = [HHUtils md5HexDigest:oldPasswd];
    
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"password":newPasswdMD5,
                             @"old_pwd":oldPasswdMD5,
                             kRequiedKeyAndValue
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//验证旧密码是否正确
- (void)postValidateOldPasswd:(NSString *)oldPasswd complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathValidateOldPasswd;
    
    //密码MD5加密
    NSString *passwdMD5 = [HHUtils md5HexDigest:oldPasswd];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"password":passwdMD5,
                             kRequiedKeyAndValue
                             };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//修改手机号
- (void)postChangePhoneNum:(NSString *)newPhoneNum verifyCode:(NSString *)verifyCode complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathChangePhone;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token为nil");
        return;
    }
    if (!newPhoneNum || !newPhoneNum.length) {
        complete(NO,@"新手机号为空!");
        return;
    }
    if(!verifyCode || !verifyCode.length){
        complete(NO,@"验证码为空!");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"mobile":newPhoneNum,
                             @"verificationCode":verifyCode,
                             @"platform":iOSPlatform,
                             kRequiedKeyAndValue
                             };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//获取我的动态
- (void)getUserDynamicListWithUseId:(NSString *)userId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathGetMyDynamics;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token不能为空");
        return;
    }
    if (!userId) {
        complete(NO,@"userId为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":userId,
                             @"page":@(currentPage),
                             @"count":@(count)
                             };
    
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success)
        {
            
            id dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *myDynList = [NSArray array];
            if (dictData) {
                NSArray *dynArray =  dictData[@"dynamics"];
                myDynList = [[DataParser shareInstance] parseWorkGroupListWithData:dynArray curReqPage:currentPage];
            }
            
            NSNumber *total = dictData[@"total"];
            
            if (!total) {
                total = @(0);
            }
            
            complete(YES,@{
                           @"total":total,
                           @"dynamics":myDynList
                           });
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
    
}

//获取好友的动态列表
- (void)getFriDynmaicListWithfriId:(NSString *)friId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathGetFriDynamics;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户Id不能为nil");
        return;
    }
    if (!friId) {
        complete(NO,@"friId为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"friendId":friId,
                             @"page":@(currentPage),
                             @"count":@(count)
                             };
    
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success)
        {
            
            id dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *myDynList = [NSArray array];
            if (dictData) {
                NSArray *dynArray =  dictData[@"dynamics"];
                myDynList = [[DataParser shareInstance] parseWorkGroupListWithData:dynArray curReqPage:currentPage];
            }
            
            NSNumber *total = dictData[@"total"];
            
            if (!total) {
                total = @(0);
            }
            
            complete(YES,@{
                           @"total":total,
                           @"dynamics":myDynList
                           });
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//获取我的访客
- (void)getMyVistorsCount:(int)count currentPage:(int)currentPage Complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathGetMyVistors;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                           @"count":@(count),
                           @"page":@(currentPage)
                           
                           };
    
    
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            
            id dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *visitors      = dictData[@"visitors"];
            NSNumber *total        = dictData[@"total"];
            if (!total) {
                total = @(0);
            }
            NSMutableArray *visitorsRet  = [NSMutableArray array];
            if ([visitors isKindOfClass:[NSArray class]] && visitors) {
                for (NSDictionary *dict in visitors) {
                    YHUserInfo *visitor = [YHUserInfo new];
                    visitor = [[DataParser shareInstance] parseUserInfo:dict curReqPage:currentPage isSelf:NO];
                    [visitorsRet addObject:visitor];
                }
            }
            NSDictionary *dictRet = @{
                                      @"visitors":visitorsRet,
                                      @"total":total
                                      };
            
            complete(YES,dictRet);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//删除动态
- (void)postDeleteDynamcicWithDynamicId:(NSString *)dynamicId complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathDeleteMyDynamic;
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户Id 或 token 为nil");
        return;
    }
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                           @"id":dynamicId
                           };
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    }progress:^(NSProgress *uploadProgress) {
        
    }];
}

- (void)postUploadImage:(UIImage *)image complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress{
    
    if (!image) {
        complete(NO,@"上传图片为nil");
        return;
    }
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"用户token为nil");
        return;
    }
    
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@?accessToken=%@",[YHProtocol share].pathUploadImage,[YHUserInfoManager sharedInstance].userInfo.accessToken];
    
    
    [self uploadWithRequestUrl:requestUrl parameters:nil imageArray:@[image] fileNames:@[@"myAvatar"] name:@"files" mimeType:@"image/png" progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        progress(bytesWritten,totalBytesWritten);
    }
                      complete:^(BOOL success, id obj) {
                          if(success)
                          {
                              id dictData  = obj[@"data"];
                              if(![dictData isKindOfClass:[NSDictionary class]]){
                                  complete(NO,kServerReturnEmptyData);
                                  return ;
                              }
                              NSArray *arrayPics  = dictData[@"pics"];
                              NSURL *avtarUrl     = [NSURL new];
                              if ([arrayPics isKindOfClass:[NSArray class]] && arrayPics.count) {
                                  NSDictionary *dict2 =  arrayPics[0];
                                  NSString *urlString =  dict2[@"picUrl"];
                                  avtarUrl            = [NSURL URLWithString:urlString];
                              }
                              
                              complete(YES,avtarUrl);
                          }
                          else{
                              complete(NO,obj);
                          }
                          
                      }];
    
}

//更改税道账号
- (void)postChangeTaxAccount:(NSString *)taxAccount passwd:(NSString *)passwd complete:(NetManagerCallback)complete{
    
    if(!taxAccount){
        complete(NO,@"税道账号为nil!");
        return;
        
    }
    
    if (!passwd) {
        complete(NO,@"密码为nil!");
        return;
    }
    
    NSString *passwdMD5 = [HHUtils md5HexDigest:passwd];
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token不能为空");
        return;
    }
    
    NSString *requestUrl = [YHProtocol share].pathChangeTaxAccount;
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"username":taxAccount,
                           @"pwd":passwdMD5,
                           kRequiedKeyAndValue
                           };
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//获取应用的基本信息
- (void)getAppInfoComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathGetAppInfo;
    
    
    NSDictionary *dict = @{
                           kRequiedKeyAndValue
                           };
    
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//检查App更新
- (void)postCheckUpdateComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathCheckUpdate;
    
    NSDictionary *params = @{
                             @"platform":iOSPlatform,
                             @"client_version":[HHUtils appStoreNumber],
                             kRequiedKeyAndValue
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if(success){
            id dictData = obj[@"data"];
            if (!isNSDictionaryClass(dictData)) {
                complete(YES,@"当前版本为最新版本");
                return ;
            }
            else{
                //需要更新
                complete(YES,dictData);
            }
            
        }else{
            //请求失败
            complete(NO,obj);
        }
        
    }progress:^(NSProgress *uploadProgress) {
        
    }];
}

//获取关于
- (void)getAboutComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathGetAbout;
    
    
    NSDictionary *dict = @{
                           @"client_version":[HHUtils appStoreNumber],
                           @"platform":iOSPlatform,
                           kRequiedKeyAndValue
                           };
    
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success)
        {
            id dictData = obj[@"data"];
            if (![dictData isKindOfClass:[NSDictionary class]]) {
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSMutableDictionary *dictRet = [NSMutableDictionary new];
            
            //应用基本信息
            NSDictionary *baseInfoDict = dictData[@"base_info"];
            if ([baseInfoDict isKindOfClass:[NSDictionary class]] && baseInfoDict.count && baseInfoDict)
            {
                [dictRet setObject:baseInfoDict forKey:@"base_info"];
            }
            
            //获取关于内容
            NSMutableArray *retArray = [NSMutableArray new];
            
            //评分
            YHAboutModel *grade = [YHAboutModel new];
            NSDictionary *dictScore = dictData[@"score_url"];
            NSURL *scoreUrl = [NSURL URLWithString:@""];
            if ([dictScore isKindOfClass:[NSDictionary class]]) {
                NSString *scoreUrlStr   = dictScore[@"ios_score_url"];
                scoreUrl = [NSURL URLWithString:scoreUrlStr];
            }
            grade.url = scoreUrl;
            [retArray addObject:grade];
            
            //帮助中心
            NSDictionary *dictFAQ = dictData[@"faq"];
            YHAboutModel *faq = [[DataParser shareInstance ] parseAboutModelWithDict:dictFAQ];
            [retArray addObject:faq];
            
            //用户协议
            NSDictionary  *dictAgreeMent =  dictData[@"user_agreement"];
            YHAboutModel *agreeMent =  [[DataParser shareInstance ] parseAboutModelWithDict:dictAgreeMent];
            [retArray addObject:agreeMent];
            
            [dictRet setObject:retArray forKey:@"features"];
            
            complete(YES,dictRet);
            
        }
        else
        {
            complete(NO,obj);
        }
        
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//获取行业职位列表
- (void)getIndustryListComplete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathIndustryList;
    
    [self getWithRequestUrl:requestUrl parameters:nil complete:^(BOOL success, id obj) {
        
        if(success)
        {
            
            //回调数组
            NSMutableArray *retArray = [NSMutableArray array];
            
            //数据解析
            NSDictionary *dict     = obj;
            id dictData = dict[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray *arrayModel    = dictData[@"children"];
            
            if ([arrayModel isKindOfClass:[NSArray class]] && arrayModel)
            {
                
                
                for (NSDictionary *dictIndustry in arrayModel)
                {
                    //字典保存
                    NSDictionary *dictSave = [NSDictionary new];
                    //职业
                    NSMutableArray  *jobsArray = [NSMutableArray array];
                    //取出行业名字
                    NSString *industry     =  dictIndustry[@"name"];
                    if(!industry){
                        industry = @"";
                    }
                    
                    //取出某行业包含的全部职业
                    NSArray *jobsArrayModel =  dictIndustry[@"children"];
                    
                    if([jobsArrayModel isKindOfClass:[NSArray class]] && jobsArrayModel)
                    {
                        for (NSDictionary *dictJobs in jobsArrayModel)
                        {
                            //取出某行业对应的某职业
                            NSString *job = dictJobs[@"name"];
                            if (job)
                            {
                                [jobsArray addObject:job];
                                
                            }
                        }
                    }
                    
                    dictSave = @{
                                 @"industry":industry,
                                 @"jobs"    :jobsArray
                                 };
                    [retArray addObject:dictSave];
                    
                }
                
                complete(YES,retArray);
            }
            
        }
        else
        {
            complete(NO,obj);
        }
        
        
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//添加加职位标签
- (void)postEditJobTags:(NSArray *)jobTags complete:(NetManagerCallback)complete{
    
    if (!jobTags) {
        complete(NO,@"标签数组为nil");
        return;
    }
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSString *jobTagsString = [jobTags componentsJoinedByString:@","];
    if (!jobTagsString) {
        jobTagsString = @"";
    }
    DDLog(@"要增加的职位字符串为:%@",jobTagsString);
    
    NSString *requestUrl = [YHProtocol share].pathEditJobTags;
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"labelName":jobTagsString
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//删除职位标签
- (void)deleteJobTags:(NSArray *)jobTags complete:(NetManagerCallback)complete{
    
    if (!jobTags) {
        complete(NO,@"标签数组为nil");
        return;
    }
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSString *jobTagsString = [jobTags componentsJoinedByString:@","];
    if (!jobTagsString) {
        jobTagsString = @"";
    }
    DDLog(@"删除职位字符串为:%@",jobTagsString);
    
    NSString *requestUrl = [YHProtocol share].pathEditJobTags;
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"labelName":jobTagsString
                             };
    
    [self deleteWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

//添加工作经历
- (void)postAddWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete{
    
    //1.参数判断
    if (!workExperience.company) {
        complete(NO,@"公司为nil!");
        return;
    }
    if (!workExperience.position) {
        complete(NO,@"职位为nil!");
        return;
    }
    if(!workExperience.beginTime){
        complete(NO,@"开始时间为nil!");
        return;
    }
    if(!workExperience.endTime){
        complete(NO,@"结束时间为nil!");
        return;
    }
    if(!workExperience.moreDescription){
        workExperience.moreDescription = @"";
    }
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSString *requestUrl = [YHProtocol share].pathEditWorkExp;
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"company":workExperience.company,
                             @"position":workExperience.position,
                             @"description":workExperience.moreDescription,
                             @"startDate":workExperience.beginTime,
                             @"endDate":workExperience.endTime
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if(success){
            NSDictionary *dictData = obj[@"data"];
            NSString    *workExpId = dictData[@"id"];
            if (!workExpId) {
                workExpId = @"";
            }
            complete(YES,workExpId);
        }
        else{
            complete(NO,obj);
        }
        
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//删除工作经历
- (void)deleteWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete{
    
    if (!workExperience.workExpId) {
        complete(NO,@"工作经历id为nil");
        return;
    }
    NSString *requestUrl = [YHProtocol share].pathEditWorkExp;
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"id":workExperience.workExpId
                             };
    [self deleteWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
}

//更新工作经历
- (void)putUpdateWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete{
    
    //1.参数判断
    if (!workExperience.workExpId) {
        complete(NO,@"工作经历id为nil");
        return;
    }
    if (!workExperience.company) {
        complete(NO,@"公司为nil!");
        return;
    }
    if (!workExperience.position) {
        complete(NO,@"职位为nil!");
        return;
    }
    if(!workExperience.beginTime){
        complete(NO,@"开始时间为nil!");
        return;
    }
    if(!workExperience.endTime){
        complete(NO,@"结束时间为nil!");
        return;
    }
    if(!workExperience.moreDescription){
        workExperience.moreDescription = @"";
    }
    
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSString *requestUrl = [YHProtocol share].pathEditWorkExp;
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"id":workExperience.workExpId,
                             @"company":workExperience.company,
                             @"position":workExperience.position,
                             @"description":workExperience.moreDescription,
                             @"startDate":workExperience.beginTime,
                             @"endDate":workExperience.endTime
                             };
    
    [self putWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

//添加教育经历
- (void)postAddEducationExperience:(YHEducationExperienceModel *)educationExperience complete:(NetManagerCallback)complete{
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if(!educationExperience.school){
        complete(NO,@"学校为nil");
        return;
    }
    if (!educationExperience.educationBackground) {
        complete(NO,@"学历为nil");
        return;
    }
    if(!educationExperience.major){
        complete(NO,@"专业为nil");
        return;
    }
    if (!educationExperience.beginTime) {
        complete(NO,@"开始时间为nil");
        return;
    }
    if(!educationExperience.endTime){
        complete(NO,@"结束时间为nil");
        return;
    }
    if(!educationExperience.moreDescription){
        educationExperience.moreDescription = @"";
    }
    
    NSString *requestUrl = [YHProtocol share].pathEditEducationExp;
    
    NSDictionary *params = @{
                             
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"schoolName":educationExperience.school,
                             @"degree":educationExperience.educationBackground,
                             @"major":educationExperience.major,
                             @"description":educationExperience.moreDescription,
                             @"startDate":educationExperience.beginTime,
                             @"endDate":educationExperience.endTime
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success) {
            id dictData = obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSString    *eduExpId  = dictData[@"id"];
            if (!eduExpId) {
                eduExpId = @"";
            }
            complete(YES,eduExpId);
        }
        else{
            complete(NO,obj);
        }
        
        
    }progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//删除教育经历
- (void)deleteEducationExperience:(YHEducationExperienceModel*)educationExperience complete:(NetManagerCallback)complete{
    
    if (!educationExperience.eduExpId) {
        complete(NO,@"工作经历id为nil");
        return;
    }
    NSString *requestUrl = [YHProtocol share].pathEditEducationExp;
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"id":educationExperience.eduExpId
                             };
    [self deleteWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

//更新教育经历
- (void)putUpdateEducationExperience:(YHEducationExperienceModel*)educationExperience complete:(NetManagerCallback)complete{
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if (!educationExperience.eduExpId) {
        complete(NO,@"建议经历id为nil");
        return;
    }
    if(!educationExperience.school){
        complete(NO,@"学校为nil");
        return;
    }
    if (!educationExperience.educationBackground) {
        complete(NO,@"学历为nil");
        return;
    }
    if(!educationExperience.major){
        complete(NO,@"专业为nil");
        return;
    }
    if (!educationExperience.beginTime) {
        complete(NO,@"开始时间为nil");
        return;
    }
    if(!educationExperience.endTime){
        complete(NO,@"结束时间为nil");
        return;
    }
    if(!educationExperience.moreDescription){
        educationExperience.moreDescription = @"";
    }
    
    NSString *requestUrl = [YHProtocol share].pathEditEducationExp;
    
    NSDictionary *params = @{
                             
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"id":educationExperience.eduExpId,
                             @"schoolName":educationExperience.school,
                             @"degree":educationExperience.educationBackground,
                             @"major":educationExperience.major,
                             @"description":educationExperience.moreDescription,
                             @"startDate":educationExperience.beginTime,
                             @"endDate":educationExperience.endTime
                             };
    
    [self putWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    }];
    
}

@end
