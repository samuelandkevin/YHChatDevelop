//
//  YHNetManager.h
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  个人页请求

#import "NetManager.h"
#import "YHUserInfo.h"
#import "YHWorkExperienceModel.h"
#import "YHEducationExperienceModel.h"


@interface NetManager (Profile)

/**
 *  验证税道账号是否存在
 *
 *  @param taxAccount 税道账号
 *  @param complete   成功失败回调
 */
- (void)postVerifyTaxAccountExist:(NSString *)taxAccount complete:(NetManagerCallback)complete;

/**
 *  编辑我的名片
 *
 *  @param userInfo 用户信息Model
 *  @param complete 成功失败回调
 */
- (void)postEditMyCardWithUserInfo:(YHUserInfo *)userInfo complete:(NetManagerCallback)complete;

/**
 *  获取我的名片详情
 *
 *  @param complete 成功失败回调
 */
- (void)getMyCardDetailComplete:(NetManagerCallback)complete;

/**
 *  修改密码
 *
 *  @param newPasswd 新密码
 *  @param oldPasswd 旧密码
 *  @param complete  成功失败回调
 */
- (void)postModifyPasswd:(NSString *)newPasswd oldPasswd:(NSString *)oldPasswd complete:(NetManagerCallback)complete;

/**
 *  获取用户的动态列表
 *
 *  @param complete 成功失败回调
 */
- (void)getUserDynamicListWithUseId:(NSString *)userId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  获取好友的动态列表
 *
 *  @param friId       好友Id
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getFriDynmaicListWithfriId:(NSString *)friId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  获取我的访客
 *
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getMyVistorsCount:(int)count currentPage:(int)currentPage Complete:(NetManagerCallback)complete;

//删除动态
- (void)postDeleteDynamcicWithDynamicId:(NSString *)dynamicId complete:(NetManagerCallback)complete;

/**
 *  上传头像
 *
 *  @param image    头像Image
 *  @param complete 成功失败回调
 *  @param progress 上传进度回调
 */
- (void)postUploadImage:(UIImage *)image complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress;


/**
 *  验证旧密码是否正确
 *
 *  @param oldPasswd 旧密码
 *  @param complete  成功失败回调
 */
- (void)postValidateOldPasswd:(NSString *)oldPasswd complete:(NetManagerCallback)complete;

/**
 *  更改手机号
 *
 *  @param newPhoneNum 新手机号
 *  @param verifyCode  验证码
 *  @param complete    成功失败回调
 */
- (void)postChangePhoneNum:(NSString *)newPhoneNum verifyCode:(NSString *)verifyCode complete:(NetManagerCallback)complete;

/**
 *  更改税道账号
 *
 *  @param taxAccount 税道账号
 *  @param passwd     密码
 *  @param complete   成功失败回调
 */
- (void)postChangeTaxAccount:(NSString *)taxAccount passwd:(NSString *)passwd complete:(NetManagerCallback)complete;

/**
 *  获取应用的基本信息
 *
 *  @param complete 成功失败回调
 */
- (void)getAppInfoComplete:(NetManagerCallback)complete;

/**
 *  检查更新
 *
 *  @param complete 成功失败回调
 */
- (void)postCheckUpdateComplete:(NetManagerCallback)complete;

/**
 *  获取关于内容
 *
 *  @param complete 成功失败回调
 */
- (void)getAboutComplete:(NetManagerCallback)complete;

/**
 *  获取行业职位列表
 *
 *  @param complete 成功失败回调
 */
- (void)getIndustryListComplete:(NetManagerCallback)complete;

/**
 *  添加职位标签
 *
 *  @param jobTags  职位标签数组
 *  @param complete 成功失败回调
 */
- (void)postEditJobTags:(NSArray *)jobTags complete:(NetManagerCallback)complete;

/**
 *  删除职位标签
 *
 *  @param jobTags  职位标签数组
 *  @param complete 成功失败回调
 */
- (void)deleteJobTags:(NSArray *)jobTags complete:(NetManagerCallback)complete;

/**
 *  添加工作经历
 *
 *  @param workExperience 工作经历
 *  @param complete       成功回调（workId）
 */
- (void)postAddWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete;

/**
 *  删除工作经历
 *
 *  @param workExperience 工作经历模型
 *  @param complete       成功失败回调
 */
- (void)deleteWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete;

/**
 *  更新工作经历
 *
 *  @param workExperience 工作经历模型
 *  @param complete       成功失败回调
 */
- (void)putUpdateWorkExperience:(YHWorkExperienceModel*)workExperience complete:(NetManagerCallback)complete;

/**
 *  添加教育经历
 *
 *  @param educationExperience 教育经历模型
 *  @param complete            成功失败回调
 */
- (void)postAddEducationExperience:(YHEducationExperienceModel*)educationExperience complete:(NetManagerCallback)complete;


/**
 *  删除教育经历
 *
 *  @param educationExperience 教育经历模型
 *  @param complete            成功失败回调
 */
- (void)deleteEducationExperience:(YHEducationExperienceModel*)educationExperience complete:(NetManagerCallback)complete;

/**
 *  更新教育经历
 *
 *  @param educationExperience 教育经历模型
 *  @param complete            成功失败回调
 */
- (void)putUpdateEducationExperience:(YHEducationExperienceModel*)educationExperience complete:(NetManagerCallback)complete;
@end
