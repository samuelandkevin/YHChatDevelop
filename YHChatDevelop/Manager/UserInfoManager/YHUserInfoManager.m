//
//  YHUserInfoManager.m
//  PikeWay
//
//  Created by kun on 16/4/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  用户信息管理

#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "YHSqliteManager.h"
#import "STMURLCache.h"
#import "YHAppInfoManager.h"


//检查数据库操作是否失败
#define YHDBCheckIfErr(x)													\
	do {																	\
		BOOL __err = x;														\
		if (!__err)															\
		{																	\
			DDLog(@"数据库 err %d, %@", [db lastErrorCode], [db lastError]);	\
		}																	\
	} while (0)

@interface YHUserInfoManager ()



@end

@implementation YHUserInfoManager

- (instancetype)init
{
	self = [super init];

	if (!self)
	{
		return nil;
	}

	return self;
}

+ (instancetype)sharedInstance
{
	static YHUserInfoManager *g_ins = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		g_ins = [YHUserInfoManager new];
	});
	return g_ins;
}

#pragma mark - Getter
- (YHUserInfo *)userInfo
{
	if (!_userInfo)
	{
		_userInfo = [YHUserInfo new];
	}
	_userInfo.isSelfModel = YES;
	return _userInfo;
}

- (BOOL)bindQQSuccess{
   return  [[NSUserDefaults standardUserDefaults] boolForKey:@"bindQQSuccess"];
}

- (BOOL)bindSinaSuccess{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"bindSinaSuccess"];
}

- (BOOL)bindWechatSuccess{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"bindWechatSuccess"];
}

#pragma mark - Setter
- (void)setBindQQSuccess:(BOOL)bindQQSuccess{
    [[NSUserDefaults standardUserDefaults] setBool:bindQQSuccess forKey:@"bindQQSuccess"];
}

- (void)setBindSinaSuccess:(BOOL)bindSinaSuccess{
    [[NSUserDefaults standardUserDefaults] setBool:bindSinaSuccess forKey:@"bindSinaSuccess"];
}

- (void)setBindWechatSuccess:(BOOL)bindWechatSuccess{
    [[NSUserDefaults standardUserDefaults] setBool:bindWechatSuccess forKey:@"bindWechatSuccess"];
}

#pragma mark - Private

//请求我的名片信息(备注：因为登录成功就返回uid,token,mobliePhone三个关键字段.请求名片详情从这里开始开始)


//登录成功
- (void)loginSuccessWithUserInfo:(YHUserInfo *)userInfo
{
	//1.更新当前用户单例信息
	self.userInfo = userInfo;
	self.isHandleringTokenExpried = NO;
  
	//2.更新用户的偏好设置
	[self updateUserPreference:userInfo];

    //3.请求我的名片信息
    [self _requestMyCardDetail];
}


//处理Token失效
- (void)handleTokenUnavailable{
    //1.清除“已登录”标志
    [self _clearLoginInfoFromUserDefaults];
    
    //3.清除用户单例信息
    _userInfo = nil;
}

//退出账号
- (void)logout
{
	
    [self _clearLoginInfoFromUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
     [[SqliteManager sharedInstance] clearCacheWhenLogout];
    //4.清除用户单例信息
    _userInfo = nil;
    
    //5.清除网页缓存
    //清网页URLCache缓存
    if([[NSURLCache sharedURLCache] isKindOfClass:[STMURLCache class]]){
        STMURLCache *sCache =  (STMURLCache *)[NSURLCache sharedURLCache];
        [sCache clearCache];
    }
    
    //清网页协议缓存
    if([YHAppInfoManager shareInstanced].webCacheUseURLProtocol){
        STMURLCacheModel *sModel = [STMURLCacheModel shareInstance];
        [sModel deleteCacheFolder];
    }
}

//从UserDefaults中清除登录信息
- (void)_clearLoginInfoFromUserDefaults{
    //1.清除“已登录”标志
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoginOAuth];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kTaxAccount];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kAccessTokenDate];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserUid];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kEnterpriseId];

}

//验证令牌是否有效
- (void)valideUserTokenComplete:(void (^)(BOOL isOK, id Obj))callback
{
	
}

//是否完善个人信息
- (BOOL)hasCompleteUserInfo
{
	if (!self.userInfo.company.length || !self.userInfo.userName.length || !self.userInfo.job.length || !self.userInfo.industry.length)
	{
		return NO;
	}
	return YES;
}

- (void)checkUpdate
{
	
}






//提交启动日志
- (void)commitBootLoggingComplete:(void(^)(BOOL success,id obj))complete{
    
   
   
}


//直接登录
- (void)loginDirectly
{
    //1.取出本地的uid,token
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUserUid];
    NSString *enterpriseId = [[NSUserDefaults standardUserDefaults] stringForKey:kEnterpriseId];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken];
    NSString *mobilePhone = [[NSUserDefaults standardUserDefaults] stringForKey:kMobilePhone];
    DDLog(@"*******直接登录时**********\n uid=%@;\n accessToken=%@;\n mobilePhone=%@;",uid,accessToken,mobilePhone);
    
    //2.赋值用户信息单例
    self.userInfo.uid = uid;
    self.userInfo.accessToken = accessToken;
    self.userInfo.mobilephone = mobilePhone;
    self.userInfo.isRegister  = YES;
    self.userInfo.companyID   = enterpriseId;
    
    //3.获取我的名片
    [self _requestMyCardDetail];
}




- (void)isTokenValideComplete:(void (^)(BOOL))complete
{
	
}

#pragma mark - Private

//请求我的名片信息(备注：因为登录成功就返回uid,token,mobliePhone三个关键字段.请求名片详情从这里开始开始)
- (void)_requestMyCardDetail
{
    __weak typeof(self) weakSelf = self;
    
    [[NetManager sharedInstance] getMyCardDetailComplete:^(BOOL success, id obj) {
        if (success){
            
            DDLog(@"获取我的名片成功:%@", obj);
            
            //1.更新当前用户单例信息
            YHUserInfo *retObj = obj;
            weakSelf.userInfo  = retObj;
            weakSelf.userInfo.updateStatus = updateFinish;

        }
        else
        {
            if (isNSDictionaryClass(obj)){
                //服务器返回的错误描述
                NSString *msg = obj[kRetMsg];
                
                postTips(msg, @"获取我的名片失败");
            }
            else{
                //AFN请求失败的错误描述
                postTips(obj, @"获取我的名片失败");
            }
            
            weakSelf.userInfo.updateStatus = updateFailure;
            
        }
    }];
    
}

/**
 *  更新用户的偏好设置
 *
 *  @param userInfo 用户Model
 */
- (void)updateUserPreference:(YHUserInfo *)userInfo
{
	//1.条件判断
	if (!userInfo.uid)
	{
		userInfo.uid = @"0";
	}

	if (!userInfo.accessToken)
	{
		userInfo.accessToken = @"";
	}

	if (!userInfo.mobilephone)
	{
		userInfo.mobilephone = @"";
	}

	//2.进行保存操作
	//保存“手机”
	[[NSUserDefaults standardUserDefaults] setObject:userInfo.mobilephone forKey:kMobilePhone];
	//保存"已登录标记"
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoginOAuth];
	//保存“用户Id”
	[[NSUserDefaults standardUserDefaults] setObject:userInfo.uid forKey:kUserUid];
    //保存"企业用户ID"
    [[NSUserDefaults standardUserDefaults] setObject:userInfo.companyID forKey:kEnterpriseId];
	//保存“令牌”
	[[NSUserDefaults standardUserDefaults] setObject:userInfo.accessToken forKey:kAccessToken];
	//保存“token登录时间点”
	NSInteger ts = [[NSDate date] timeIntervalSince1970];
	[[NSUserDefaults standardUserDefaults] setObject:@(ts) forKey:kAccessTokenDate];
	[[NSUserDefaults standardUserDefaults] synchronize];
}




@end
