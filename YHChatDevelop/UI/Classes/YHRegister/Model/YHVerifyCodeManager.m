//
//  YHVerifyCodeManager.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/20.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHVerifyCodeManager.h"

#import "YHConfig.h"

#define kRegisterVCDate @"registerVCDate"                 //保存注册验证码日期
#define kLoginVCDate    @"loginVCDate"                    //短信验证码登录的验证码日期
#define kResetPasswdLoginVCDate @"resetPasswdLoginVCDate" //重置密码登录验证码日期
#define kBindPhoneByThirdPartyAccountVCDate @"BPbyTPacountVCDate" //第三方账号登录绑定手机验证码日期

@interface YHVerifyCodeManager()

@end

@implementation YHVerifyCodeManager

+ (instancetype)shareInstance{
    static YHVerifyCodeManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHVerifyCodeManager alloc] init];
    });
    return g_instance;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}


#pragma mark - Public
#pragma mark - /***********注册验证码****************/
//注册验证码过期
- (BOOL)isExpiredRegisterVerifyCode
{
    
    //取出
    NSDate *oDate  = [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterVCDate];
    //时间间隔
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:oDate];
    
    if (distance > kVerifyCodeValidDuration) {
        return YES;
    }
    return NO;
}

//保存获取注册验证码的日期
- (void)storageRegisterVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kRegisterVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//重置注册验证码日期
- (void)resetRegisterVCDate{

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRegisterVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -  /***********通过短信登录的验证码****************/
//短信验证码登录过期
- (BOOL)isExpiredLoginVerifyCode{

    //取出
    NSDate *oDate  = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginVCDate];
    //时间间隔
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:oDate];
    
    if (distance > kVerifyCodeValidDuration) {
        return YES;
    }
    return NO;
}

//保存获取短信验证码登录的日期
- (void)storageLoginVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLoginVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//重置短信验证码日期
- (void)resetLoginVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kLoginVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - /************短信重置密码登录的验证码***************/
//重置密码登录的验证码过期
- (BOOL)isExpiredResetPasswdLoginVerifyCode{
    //取出
    NSDate *oDate  = [[NSUserDefaults standardUserDefaults] objectForKey:kResetPasswdLoginVCDate];
    //时间间隔
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:oDate];
    
    if (distance > kVerifyCodeValidDuration) {
        return YES;
    }
    return NO;
}

//保存重置密码登录验证码的日期
- (void)storageRPLoginVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kResetPasswdLoginVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//重置重设密码登录验证码日期
- (void)resetRPLoginVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kResetPasswdLoginVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - /************第三方登录绑定手机的验证码***************/
//短信验证码第三方登录绑定手机过期
-(BOOL)isExpiredLoginByThridPartyAcountVerifyCode{
    //取出
    NSDate *oDate  = [[NSUserDefaults standardUserDefaults] objectForKey:kBindPhoneByThirdPartyAccountVCDate];
    //时间间隔
    NSTimeInterval distance = [[NSDate date] timeIntervalSinceDate:oDate];
    
    if (distance > kVerifyCodeValidDuration) {
        return YES;
    }
    return NO;
}

//保存获取第三方登录绑定手机短信验证码登录的日期
- (void)storageLoginByThridPartyAcountVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kBindPhoneByThirdPartyAccountVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//重置第三方登录绑定手机短信验证码日期
- (void)resetLoginByThridPartyAcountVCDate{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kBindPhoneByThirdPartyAccountVCDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Life
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}
@end
