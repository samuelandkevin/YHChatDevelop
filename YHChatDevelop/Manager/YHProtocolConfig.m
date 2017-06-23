//
//  YHProtocolConfig.m
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHProtocolConfig.h"

@interface YHProtocolConfig()
@end

@implementation YHProtocolConfig

+ (instancetype)shareInstance{
    static YHProtocolConfig *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHProtocolConfig alloc] init];
    });
    return g_instance;
}

#pragma mark - Private

/*
 *  获取BaseUrl
 *
 *  @param loadByHTTPS 传输协议HTTPS/HTTP
 *
 *  @return BaseUrl
 */
- (NSString *)getBaseUrlLoadByHTTPS:(int)loadByHTTPS{
    NSString *baserUrl = kBaseURL;
    if(!loadByHTTPS){
        if ([baserUrl hasPrefix:@"https"]) {
            baserUrl = [baserUrl stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
        }
    }else{
        if (![baserUrl hasPrefix:@"https"]) {
             baserUrl = [baserUrl stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
        }
    }
    return baserUrl;
}

#pragma mark - getter
//首页url
- (NSString *)pathTaxHome{
    if (!_pathTaxHome) {
        _pathTaxHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathTaxHome3];
    }
    return _pathTaxHome;
}

//工作指引
- (NSString *)pathWorkGuideHome{
    if (!_pathWorkGuideHome) {
        _pathWorkGuideHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathWorkGuideHome];
    }
    return _pathWorkGuideHome;
}

//线上培训
- (NSString *)pathTrainingOnline{
    if (!_pathTrainingOnline) {
        _pathTrainingOnline = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathTrainingOnline];
    }
    return _pathTrainingOnline;
}

//线下培训
- (NSString *)pathTrainingOffline{
    if (!_pathTrainingOffline) {
        _pathTrainingOffline = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathTrainingOffline];
    }
    return _pathTrainingOffline;
}

//执业测评首页
- (NSString *)pathEvaluationHome{
    if (!_pathEvaluationHome) {
        _pathEvaluationHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathEvaluationHome];
    }
    return _pathEvaluationHome;

}

//测评详情
- (NSString *)pathEvaluationDetail{
    if (!_pathEvaluationDetail) {
        _pathEvaluationDetail = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathEvaluationDetail];
    }
    return _pathEvaluationDetail;
}


//案例首页
- (NSString *)pathCaseHome{
    if (!_pathCaseHome) {
        
        _pathCaseHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathCaseHome];
    }
    return _pathCaseHome;
}

//案例搜索
- (NSString *)pathCaseSearch{
    if (!_pathCaseSearch) {
        
        NSString *baseUrl = @"https://www.gtax.cn";
        _pathCaseSearch = [NSString stringWithFormat:@"%@%@",baseUrl,kPathCaseSearch];
    }
    return _pathCaseSearch;
}

//法规库
- (NSString *)pathLawLib{
    if (!_pathLawLib) {
        _pathLawLib = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathLawLib];
    }
    return _pathLawLib;
}

//微信支付详情
- (NSString *)pathWechatPayDetail{
    if (!_pathWechatPayDetail) {
        _pathWechatPayDetail = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathWechatPayDetail];
    }
    return _pathWechatPayDetail;
}

//人才首页
- (NSString *)pathTalentHome{
    if (!_pathTalentHome) {
        _pathTalentHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathTalentHome];
    }
    return _pathTalentHome;
}

//悬赏首页
- (NSString *)pathRewardHome{
    if(!_pathRewardHome){
        _pathRewardHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRewardHome];
    }
    return _pathRewardHome;
}

//悬赏列表
- (NSString *)pathRewardList{
    if(!_pathRewardList){
        _pathRewardList = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRewardList];
    }
    return _pathRewardList;
}

//发悬赏
- (NSString *)pathSendReward{
    if(!_pathSendReward){
        _pathSendReward = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathSendReward];
    }
    return _pathSendReward;
}

//聊天详情页
- (NSString *)pathChatDetail{
    if (!_pathChatDetail) {
         _pathChatDetail = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathChatDetail];
    }
    return _pathChatDetail;
}

//群列表
- (NSString *)pathGroupList{
    if(!_pathGroupList){
        _pathGroupList = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathGroupList];
    }
    return _pathGroupList;
}

//群设置
- (NSString *)pathGroupSetting{
    if (!_pathGroupSetting) {
        _pathGroupSetting = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathGroupSetting];
    }
    return _pathGroupSetting;
}

//群聊界面
- (NSString *)pathGroupChat{
    if (!_pathGroupChat) {
        _pathGroupChat = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathGroupChat];
    }
    return _pathGroupChat;
}

//聊天列表
- (NSString *)pathChatList{
    if (!_pathChatList) {
        _pathChatList = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathChatList];
    }
    return _pathChatList;
}

//搜索的首页
- (NSString *)pathSearchHome{
    if (!_pathSearchHome) {
        _pathSearchHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathSearchHome];
    }
    return _pathSearchHome;
}

//咨讯首页
-(NSString *)pathNewsHome{
    if (!_pathNewsHome) {
        
        NSString *baseUrl = kBaseURL;
        if ([kBaseURL rangeOfString:@"testapp.gtax.cn"].location == NSNotFound ){
            baseUrl = @"https://www.gtax.cn";
        }
        _pathNewsHome = [NSString stringWithFormat:@"%@%@",baseUrl,kPathNewsHome];
    
    }
    return _pathNewsHome;
}

//我的钱包
- (NSString *)pathMyWallet{
    if (!_pathMyWallet) {
        _pathMyWallet = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathMyWallet];
    }
    return _pathMyWallet;
}

//移除群成员
- (NSString *)pathRemoveGroupMembers{
    if(!_pathRemoveGroupMembers){
        _pathRemoveGroupMembers = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRemoveGroupMemebers];
    }
    return _pathRemoveGroupMembers;
}

//群主权限转
- (NSString *)pathTransferGroupOwner{
    if(!_pathTransferGroupOwner){
        _pathTransferGroupOwner = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRemoveGroupMemebers];
    }
    return _pathTransferGroupOwner;
}

//我的收藏
- (NSString *)pathMyCollection{
    if(!_pathMyCollection){
        _pathMyCollection = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathMyCollection];
    }
    return _pathMyCollection;
}

//规程首页
-(NSString *)pathRegulationHome{
    if(!_pathRegulationHome){
        _pathRegulationHome = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRegulationHome];
    }
    return _pathRegulationHome;
}

//规程目录
- (NSString *)pathRegulationCatalogue{
    if(!_pathRegulationCatalogue){
        _pathRegulationCatalogue = [NSString stringWithFormat:@"%@%@",[self getBaseUrlLoadByHTTPS:YES],kPathRegulationCatalogue];
    }
    return _pathRegulationCatalogue;
}

@end


#pragma mark - /**********登录注册*************/
NSString *const kPathVerifyPhoneExist = @"/app_core_api/v1/account/verification_mobile";//验证手机号码是否已注册
NSString *const kPathRegister         = @"/app_core_api/v1/account/regist";             //注册
NSString *const kPathValidateToken    = @"/app_core_api/v1/account/check_token";        //token是否有效
NSString *const kPathLogin            = @"/app_core_api/v1/account/login";              //登录
NSString *const kPathForgetPasswd     = @"/app_core_api/v1/account/forget_password";    //忘记密码
NSString *const kPathLogout           = @"/app_core_api/v1/account/logout";             //退出登录
NSString *const kPathWhetherPhonesAreRegistered = @"/app_core_api/v1/account/verifyPhonesIsReg";//批量校验手机号是否已注册
NSString *const kPathVerifyThridPartyAccount = @"/app_core_api/v1/account/authenticate";//验证第三方账号登录有效性
NSString *const kPathBindPhoneByThirdPartyAccountLogin = @"/app_core_api/v1/account/bind_authenticate";//通过第三方登录绑定手机号
NSString *const kPathThridPartyLoginSetPasswd = @"/app_core_api/v1/account/reset_password";   //第三方绑定手机后设置密码
NSString *const kPathLoginByWebPage = @"/taxtao/chat/confirm_login";  //税道网页登录
NSString *const kPathBootLogging = @"/taxtao/api/monitor/startupLog";     //启动日志  

#pragma mark - /**********工作圈**********/
NSString *const kPathSendDynamic      = @"/taxtao/api/dynamics/public";   //发布动态
NSString *const kPathWorkGroupDynamicList = @"/taxtao/api/dynamics/public_timeline";    //获取工作圈动态列表
NSString *const kPathWorkGroupDynamicListByTag = @"/taxtao/api/dynamics/public_timeline_by_type";//按标签获取工作圈动态列表
NSString *const kPathCommentDynamic   = @"/taxtao/api/comments/create";  //评论动态
NSString *const kPathLikeDynamic      = @"/taxtao/api/attitude/click" ;  //赞某条动态
NSString *const kPathDynamicCommentList = @"/taxtao/api/comments/show";    //获取某一条动态的评论列表
NSString *const kPathDynamicLikeList   = @"/taxtao/api/attitude/show";    //获取某一条动态的点赞列表
NSString *const kPathDynamicRepost     = @"/taxtao/api/dynamics/repost";  //转发某一条动态
NSString *const kPathDeleteDynamicComment = @"/taxtao/api/comments/destroy"; //删除某一条评论
NSString *const kPathGetDynamciDetail  = @"/taxtao/api/dynamics/find_dynamic";   //获取动态详情页
NSString *const kPathSearchDynamic     = @"/taxtao/api/dynamics/search";         //搜索动态
NSString *const kPathSynthesisSearch   = @"/taxtao/api/search/complex_search"; //综合搜索
NSString *const kPathReplyComment      = @"/taxtao/api/comments/reply";          //回复评论




#pragma mark - /**********发现************/
NSString *const kPathGetBigNamesList   = @"/taxtao/api/account/list_daka";//获取大咖列表
NSString *const kPathBigNameDynamics   = @"/taxtao/api/dynamics/daka_dynamic";//获取大咖动态
NSString *const kPathFollowBigName     = @"/taxtao/api/focus/focus_daka"; //关注(取消关注）大咖
NSString *const kPathChangeIdentify    = @"/taxtao/api/account/change_user_type";//身份转变
NSString *const kPathFindLaws          = @"/taxtao/api/lawlib/search";  //找法规






#pragma mark - /**********人脉************/
NSString *const kPathNewFriends       = @"/taxtao/api/friendships/new_friends";    //获取新的好友
NSString *const kPathMyFriends        = @"/taxtao/api/friendships/friends";        //我的好友
NSString *const kPathAddFriend        = @"/taxtao/api/friendships/create";         //添加好友
NSString *const kPathDeleteFriend     = @"/taxtao/api/friendships/delete";         //删除好友
NSString *const kPathVisitCardDetail  = @"/taxtao/api/account/visit";              //访问名片详情
NSString *const kPathRelationWithMe   = @"/taxtao/api/friendships/analysis_friendships";//其他用户与我的关系查询
NSString *const kPathAcceptAddFriendReq  = @"/taxtao/api/friendships/acceptFriend";//接受加好友请求
NSString *const kPathFindFriends      = @"/app_core_api/v1/account/findFriends";//查找朋友
NSString *const kPathGetUserAccount   = @"/app_core_api/v1/account/my_account"; //获取用户账号信息（手机号和税道账号）
NSString *const kPathSearchConnection = @"/taxtao/api/account/search"; //人脉搜索
NSString *const kPathComplain = @"/taxtao/api/complain/public";
NSString *const kPathModifyBlackList = @"/taxtao/api/account/set_black_list";//修改用户黑名单






#pragma mark - /************我***********/

NSString *const kPathTaxAccountExist  = @"/app_core_api/v1/account/verification_username";//验证税道账号是否存在
NSString *const kPathEditMyCard       = @"/taxtao/api/account/edit";           //修改我的名片
NSString *const kPathMyCard           = @"/taxtao/api/account/my_account";          //我的名片
NSString *const kPathModifyPasswd     = @"/app_core_api/v1/account/change_password";//修改密码
NSString *const kPathGetMyDynamics    = @"/taxtao/api/dynamics/my_dynamic";     //获取我的动态
NSString *const kPathGetFriDynamics   = @"/taxtao/api/dynamics/friendship_dynamic";//获取好友的动态
NSString *const kPathGetMyVistors     = @"/taxtao/api/friendships/visitors";    //获取我的访客
NSString *const kPathUploadImage      = @"/taxtao/api/images/uploads";          //上传图片
NSString *const kPathValidateOldPasswd= @"/app_core_api/v1/account/verification_pasword";                                           //验证旧密码是否正确
NSString *const kPathChangePhone      = @"/app_core_api/v1/account/change_mobile";    //更改手机号码
NSString *const kPathChangeTaxAccount = @"/app_core_api/v1/account/change_username";  //更改税道账号
NSString *const kPathGetAppInfo       = @"/app_core_api/v1/appBaseInfo";              //获取应用基本信息
NSString *const kPathCheckUpdate      = @"/app_core_api/v1/checkUpgrade";             //检查更新
NSString *const kPathGetAbout         = @"/app_core_api/v1/bootstrap";                 //获取关于内容
NSString *const kPathIndustryList     = @"/taxtao/api/industry/list";                     //获取行业职位列表
NSString *const kPathEditJobTags      = @"/taxtao/api/account/jobLable";                 //编辑职位标签
NSString *const kPathEditWorkExp      = @"/taxtao/api/account/workExp";                  //编辑工作经历
NSString *const kPathEditEducationExp = @"/taxtao/api/account/eduExp";                   //编辑教育经历
NSString *const kPathDeleteMyDynamic  = @"/taxtao/api/dynamics/destroy";//删除我的动态


#pragma mark - /************App基本信息***********/
NSString *const kPathPageCanOpened = @"/app_core_api/v1/app_function";//获取页面能否打开



#pragma mark - /**********聊天***************/
NSString *const kPathCreatGroupChat = @"/taxtao/api/im/create_chat_group";//创建群聊
NSString *const kPathAddGroupMember = @"/taxtao/api/im/add_chat_group";//添加群成员
NSString *const kPathGetChatLog     = @"/taxtao/api/im/chat_messages";//获取聊天记录
NSString *const kPathUnReadMsg      = @"/taxtao/api/im/notification" ;     //获取未读消息（群聊+私聊+新的好友）
NSString *const kPathUploadRecordFile   = @"/taxtao/api/im/upload_audio";//上传录音文件
NSString *const kPathUploadOfficeFile   = @"/taxtao/api/files/uploads";//上传办公文件（eg:pdf,word,excel）
NSString *const kPathGetGroupChatList   = @"/taxtao/api/im/group_list";//获取群聊列表
NSString *const kPathSendChatMsg        = @"/taxtao/api/im/send_msg";//发送聊天信息
NSString *const kPathGetChatList        = @"/taxtao/api/im/chat_history_list"; //获取聊天列表
NSString *const kPathMsgStick           = @"/taxtao/api/im/chat_history_top";//消息置顶
NSString *const kPathMsgCancelStick     = @"/taxtao/api/im/chat_history_top/cancel";//取消消息置顶
NSString *const kPathGroupMembers       = @"/taxtao/api/im/group_members";//获取群成员
NSString *const kPathDeleteSession      = @"/taxtao/api/im/delete_history";//删除会话
NSString *const kPathWithDrawMsg        = @"/taxtao/api/im/retract_msg";//消息撤回

#pragma mark - /**********悬赏***************/
NSString *const kPathUpdateRewardStatus = @"/taxtao/api/reward/update_payment_status";

#pragma mark - /**********工作指引***************/
NSString *const kPathUpdateWorkGuideStatus = @"/taxtao/api/order/update_status"; //更新工作指引订单状态


#pragma mark - /**********网页路径*************/
NSString *const kPathTaxHome  = @"/taxtao/index"; //税道首页
NSString *const kPathTaxHome2 = @"/taxtao/index_new";//税道首页2
NSString *const kPathTaxHome3 = @"/taxtao/v2";  //税道首页3
NSString *const kPathWorkGuideHome = @"/taxtao/v2/books";//工作指引
NSString *const kPathTrainingOnline = @"/taxtao/v2/train/online";//线上培训
NSString *const kPathTrainingOffline = @"/taxtao/v2/train/line";//线下培训
NSString *const kPathEvaluationHome = @"/taxtao/v2/evaluation";//测评首页
NSString *const kPathCaseHome = @"/tax/sd/case"; //案例首页
NSString *const kPathCaseSearch = @"/tax/sd/case/search";//案例搜索
NSString *const kPathLawLib   = @"/taxtao/lawlib/search?";//法规库
NSString *const kPathWechatPayDetail = @"/wxpay_demo/wxPay";//支付详情
NSString *const kPathTalentHome = @"/talente/sd/hottalent/list";//人才首页
NSString *const kPathRewardHome = @"/taxtao/building";//悬赏首页
NSString *const kPathRewardList = @"/taxtao/reward/list_all_reward";//悬赏列表
NSString *const kPathSendReward = @"/taxtao/reward/public_reward";//发悬赏
NSString *const kPathChatDetail = @"/taxtao/webim/chat_mobile";//聊天详情页
NSString *const kPathGroupList = @"/taxtao/webim/group_list";//群列表
NSString *const kPathGroupSetting = @"/taxtao/webim/group_info";//群设置
NSString *const kPathGroupChat = @"/taxtao/webim/chat_group_mobile";//群聊界面
NSString *const kPathChatList = @"/taxtao/webim/list";//聊天列表
NSString *const kPathSearchHome = @"/taxtao/search";//搜索的首页
NSString *const kPathNewsHome = @"/tax/sd/ygz";//资讯首页
NSString *const kPathMyWallet = @"/taxtao/myWallet";//我的钱包
NSString *const kPathRemoveGroupMemebers = @"/taxtao/webim/group_members/";//移除群成员
NSString *const kPathTransferGroupOwner = @"/taxtao/webim/group_members/";//群主权限转
NSString *const kPathEvaluationDetail = @"/taxtao/v2/evaluation/questions/";//评测详情页
NSString *const kPathMyCollection = @"/taxtao/collect/";//我的收藏
NSString *const kPathRegulationHome = @"/taxtao/v2/rule/";//规程首页
NSString *const kPathRegulationCatalogue = @"/taxtao/v2/rule/catalog/34/";//规程目录




