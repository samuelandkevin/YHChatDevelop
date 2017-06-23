//
//  YHProtocolConfig.h
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


/***********BaseUrl***************************/
//#define kBaseURL  @"http://192.168.1.80"    //内网测试环境
#define kBaseURL  @"https://testapp.gtax.cn"  //外网测试
//#define kBaseURL  @"https://apps.gtax.cn"   //外网生产环境

//#define kBaseURL @"http://192.168.2.251:8085"//后台家学
//#define kBaseURL @"http://192.168.2.175:8080"//后台啊亮

@interface YHProtocolConfig :NSObject

@property (nonatomic,copy) NSString *pathTaxHome; //首页url
@property (nonatomic,copy) NSString *pathWorkGuideHome;//工作指引
@property (nonatomic,copy) NSString *pathTrainingOnline; //线上培训
@property (nonatomic,copy) NSString *pathTrainingOffline;//线下培训
@property (nonatomic,copy) NSString *pathEvaluationHome;//执业测评首页
@property (nonatomic,copy) NSString *pathEvaluationDetail;//测评详情
@property (nonatomic,copy) NSString *pathCaseHome;//案例首页
@property (nonatomic,copy) NSString *pathCaseSearch;//搜索案例
@property (nonatomic,copy) NSString *pathLawLib;  //法规库
@property (nonatomic,copy) NSString *pathWechatPayDetail;//微信支付详情
@property (nonatomic,copy) NSString *pathTalentHome;//人才首页
@property (nonatomic,copy) NSString *pathRewardHome;//悬赏首页
@property (nonatomic,copy) NSString *pathRewardList;//悬赏列表
@property (nonatomic,copy) NSString *pathSendReward;//发悬赏
@property (nonatomic,copy) NSString *pathChatDetail;//双人聊界面
@property (nonatomic,copy) NSString *pathGroupList;//群列表
@property (nonatomic,copy) NSString *pathGroupSetting;//群设置
@property (nonatomic,copy) NSString *pathGroupChat;//群聊界面
@property (nonatomic,copy) NSString *pathChatList;//聊天列表
@property (nonatomic,copy) NSString *pathSearchHome;//搜索的首页
@property (nonatomic,copy) NSString *pathNewsHome;//咨讯首页
@property (nonatomic,copy) NSString *pathMyWallet;//我的钱包
@property (nonatomic,copy) NSString *pathRemoveGroupMembers;//移除群成员
@property (nonatomic,copy) NSString *pathTransferGroupOwner;//群主权限转移
@property (nonatomic,copy) NSString *pathMyCollection;//我的收藏
@property (nonatomic,copy) NSString *pathRegulationHome;//规程首页
@property (nonatomic,copy) NSString *pathRegulationCatalogue;//规程目录


+ (instancetype)shareInstance;

- (NSString *)getBaseUrlLoadByHTTPS:(int)loadByHTTPS;
@end


#pragma mark - /**********登录注册*************/
extern NSString *const kPathVerifyPhoneExist;//验证手机号码是否已注册
extern NSString *const kPathRegister;        //注册
extern NSString *const kPathValidateToken;   //token是否有效
extern NSString *const kPathLogin;           //登录
extern NSString *const kPathForgetPasswd;    //忘记密码
extern NSString *const kPathLogout;          //退出登录
extern NSString *const kPathWhetherPhonesAreRegistered;//批量校验手机号是否已注册
extern NSString *const kPathVerifyThridPartyAccount;//验证第三方账号登录有效性
extern NSString *const kPathBindPhoneByThirdPartyAccountLogin; //通过第三方登录绑定手机号
extern NSString *const kPathThridPartyLoginSetPasswd;//第三方绑定手机后设置密码
extern NSString *const kPathLoginByWebPage;  //税道网页登录
extern NSString *const kPathBootLogging; //启动日志


#pragma mark - /**********工作圈**********/
extern NSString *const kPathSendDynamic;         //发布动态
extern NSString *const kPathWorkGroupDynamicList;//获取工作圈动态列表
extern NSString *const kPathWorkGroupDynamicListByTag;//按标签获取工作圈动态列表
extern NSString *const kPathCommentDynamic      ;//评论动态
extern NSString *const kPathLikeDynamic;        ;//赞某条动态
extern NSString *const kPathDynamicCommentList  ;//获取某一条动态的评论列表
extern NSString *const kPathDynamicLikeList;     //获取某一条动态的点赞列表
extern NSString *const kPathDynamicRepost;       //转发某一条动态
extern NSString *const kPathDeleteDynamicComment;//删除某一条评论
extern NSString *const kPathGetDynamciDetail;    //获取动态详情页
extern NSString *const kPathSearchDynamic;       //搜索动态
extern NSString *const kPathSynthesisSearch;     //综合搜索
extern NSString *const kPathReplyComment;        //回复评论



#pragma mark - /**********发现************/
extern NSString *const kPathGetBigNamesList;     //获取大咖列表
extern NSString *const kPathBigNameDynamics;     //获取大咖动态
extern NSString *const kPathFollowBigName;       //关注(取消关注）大咖
extern NSString *const kPathChangeIdentify;      //身份转变
extern NSString *const kPathAcceptAddFriendReq;  //接受加好友请求
extern NSString *const kPathFindLaws;            //找法规







#pragma mark - /**********人脉************/
extern NSString *const kPathNewFriends;      //新的好友
extern NSString *const kPathMyFriends;       //我的好友
extern NSString *const kPathAddFriend;       //添加好友
extern NSString *const kPathDeleteFriend;    //删除好友
extern NSString *const kPathVisitCardDetail; //访问名片详情
extern NSString *const kPathRelationWithMe;  //其他用户与我的关系查询
extern NSString *const kPathFindFriends;     //查找朋友
extern NSString *const kPathGetUserAccount ; //获取用户账号信息（手机号和税道账号）
extern NSString *const kPathSearchConnection;//搜索人脉
extern NSString *const kPathComplain;        //投诉
extern NSString *const kPathModifyBlackList; //修改用户黑名单




#pragma mark - /************我***********/
extern NSString *const kPathTaxAccountExist; //验证税道账号是否存在
extern NSString *const kPathEditMyCard;      //修改我的名片
extern NSString *const kPathMyCard;          //我的名片
extern NSString *const kPathModifyPasswd;    //修改密码（是用户登录后在个人中心修改密码）
extern NSString *const kPathGetMyDynamics;   //获取我的动态
extern NSString *const kPathGetFriDynamics;  //获取好友的动态
extern NSString *const kPathGetMyVistors;    //获取我的访客
extern NSString *const kPathUploadImage;     //上传图片
extern NSString *const kPathValidateOldPasswd;//验证旧密码是否正确
extern NSString *const kPathChangePhone;      //更改手机号
extern NSString *const kPathChangeTaxAccount; //更改税道账号
extern NSString *const kPathGetAppInfo;       //获取应用基本信息
extern NSString *const kPathCheckUpdate;      //检查更新
extern NSString *const kPathGetAbout;         //获取关于内容
extern NSString *const kPathIndustryList;     //获取行业职位列表
extern NSString *const kPathEditJobTags;      //编辑职位标签
extern NSString *const kPathEditWorkExp;      //编辑工作经历
extern NSString *const kPathEditEducationExp; //编辑教育经历
extern NSString *const kPathDeleteMyDynamic;  //删除我的动态


#pragma mark - /************App基本信息***********/
extern NSString *const kPathPageCanOpened;//获取页面能否打开

#pragma mark - /**********聊天***************/
extern NSString *const kPathCreatGroupChat;//创建群聊
extern NSString *const kPathAddGroupMember;//添加群成员
extern NSString *const kPathGetChatLog;    //获取聊天记录
extern NSString *const kPathUnReadMsg;     //获取未读消息（群聊+私聊+新的好友）
extern NSString *const kPathUploadRecordFile;//上传录音文件
extern NSString *const kPathUploadOfficeFile;//上传办公文件（eg:pdf,word,excel）
extern NSString *const kPathGetGroupChatList;//获取群聊列表
extern NSString *const kPathSendChatMsg;     //发送聊天信息
extern NSString *const kPathGetChatList;     //获取聊天列表
extern NSString *const kPathMsgStick;        //消息置顶
extern NSString *const kPathMsgCancelStick;  //取消消息置顶
extern NSString *const kPathGroupMembers;    //获取群成员
extern NSString *const kPathDeleteSession;   //删除会话
extern NSString *const kPathWithDrawMsg;     //消息撤回

#pragma mark - /**********悬赏***************/
extern NSString *const kPathUpdateRewardStatus;//修改悬赏订单状态

#pragma mark - /**********工作指引***************/
extern NSString *const kPathUpdateWorkGuideStatus;//更新工作指引订单状态

/**********网页路径*************/
extern NSString *const kPathTaxHome __deprecated_msg("请使用kPathTaxHome3");//税道首页
extern NSString *const kPathTaxHome2 __deprecated_msg("请使用kPathTaxHome3");//税道首页2
extern NSString *const kPathTaxHome3;//税道首页3
extern NSString *const kPathWorkGuideHome;//工作指引
extern NSString *const kPathTrainingOnline  ;//线上培训
extern NSString *const kPathTrainingOffline ;//线下培训
extern NSString *const kPathEvaluationHome;//测评首页
extern NSString *const kPathCaseHome;//案例首页
extern NSString *const kPathCaseSearch;//案例搜索
extern NSString *const kPathLawLib;  //法规库
extern NSString *const kPathWechatPayDetail;//支付详情
extern NSString *const kPathTalentHome;//人才首页
extern NSString *const kPathRewardHome;//悬赏首页
extern NSString *const kPathRewardList;//悬赏列表
extern NSString *const kPathSendReward;//发悬赏
extern NSString *const kPathChatDetail;//聊天详情页
extern NSString *const kPathGroupList;//群列表
extern NSString *const kPathGroupSetting;//群设置
extern NSString *const kPathGroupChat; //群聊界面
extern NSString *const kPathChatList;  //聊天列表
extern NSString *const kPathSearchHome;//搜索首页
extern NSString *const kPathNewsHome;//资讯首页
extern NSString *const kPathMyWallet;//我的钱包
extern NSString *const kPathRemoveGroupMemebers;//移除群成员
extern NSString *const kPathTransferGroupOwner;//群主权限转
extern NSString *const kPathEvaluationDetail;//评测详情页
extern NSString *const kPathMyCollection;//我的收藏
extern NSString *const kPathRegulationHome;//规程首页
extern NSString *const kPathRegulationCatalogue;//规程目录
