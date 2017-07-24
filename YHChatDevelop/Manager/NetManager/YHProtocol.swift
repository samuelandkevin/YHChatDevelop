//
//  YHProtocol.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation


class YHProtocol:NSObject{

    /***********BaseUrl***************************/
    //var kBaseURL = "http://192.168.1.80"    //内网测试环境
    var kBaseURL = "https://testapp.gtax.cn"  //测试
//    var kBaseURL = "https://apps.gtax.cn"       //生产环境
    
    //var kBaseURL = "http://192.168.2.251:8085"//后台家学
    //var kBaseURL = "http://192.168.2.175:8080"//后台啊亮
    
    
    // MARK: - Public Method
    static func share() -> YHProtocol {
        struct single{
            static var g_Instance = YHProtocol()
        }
        return single.g_Instance
    }
    
    // MARK: - Public Property
    //首页url
    var pathTaxHome:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathTaxHome3
    }
    //工作指引
    var pathWorkGuideHome:String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathWorkGuideHome
    }
    
    //线上培训
    var pathTrainingOnline:String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathTrainingOnline
    }
    
    //线下培训
    var pathTrainingOffline  :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathTrainingOffline
    }
    
    //执业测评首页
    var pathEvaluationHome   :String  {
        return baseUrlLoadedBy(HTTPS: true) +
        kPathEvaluationHome
    }
    
    //测评详情
    var pathEvaluationDetail :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathEvaluationDetail
    }
    
    //案例首页
    var pathCaseHome   :String  {
        return baseUrlLoadedBy(HTTPS: true) +
        kPathCaseHome
    }
    
    //搜索案例
    var pathCaseSearch :String  {
        //"https://www.gtax.cn" (第一版的baseUrl)
        return baseUrlLoadedBy(HTTPS: true) + kPathCaseSearch2
    }
    
    //法规库
    var pathLawLib     :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathLawLib
    }
    
    //微信支付详情
    var pathWechatPayDetail :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathWechatPayDetail
    }
    
    //人才首页
    var pathTalentHome :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathTalentHome
    }
    
    //悬赏首页
    var pathRewardHome :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathRewardHome
    }
    
    //悬赏列表
    var pathRewardList :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathRewardList
    }
    
    //发悬赏
    var pathSendReward :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathSendReward
    }
    
    //双人聊界面
    var pathChatDetail :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathChatDetail
    }
    
    //群列表
    var pathGroupList  :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathGroupList
    }
    
    //群设置
    var pathGroupSetting :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathGroupSetting
    }
    
    //群聊界面
    var pathGroupChat  :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathGroupChat
    }
    
    //聊天列表
    var pathChatList   :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathChatList
    }
    
    //获取群成员
    var pathGroupMembers:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGroupMembers
    }
    
    //删除会话
    var pathDeleteSession:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathDeleteSession
    }
    
    //修改群名称
    var pathModifyGroupName:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathModifyGroupName
    }
    
    //修改我在群里的名字
    var pathModifyMyNameInGroup:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathModifyMyNameInGroup
    }
    
    //群转让(原生post请求)
    var pathTransferGroupOwner:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathTransferGroupOwner
    }
    
    //消息撤回
    var pathWithDrawMsg:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathWithDrawMsg
    }
    
    //退出群聊
    var pathQuitGroup:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathQuitGroup
    }
    
    //群信息
    var pathGroupInfo:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathGroupInfo
    }
    
    
    //搜索的首页
    var pathSearchHome :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathSearchHome
    }
    
    //咨讯首页
    var pathNewsHome   :String  {
        
        var baseUrl = kBaseURL
        if baseUrl.contains("testapp.gtax.cn") == false {
            baseUrl = "https://www.gtax.cn"
        }
        return baseUrl + kPathNewsHome
    }
    
    //我的钱包
    var pathMyWallet   :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathMyWallet
    }
    
    //移除群成员
    var pathRemoveGroupMembers :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathRemoveGroupMemebers
    }
    
    //群主权限转移(调用网页实现)
    var pathTransferGroupOwnerWeb :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathTransferGroupOwnerWeb
    }
    
    //我的收藏
    var pathMyCollection   :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathMyCollection
    }
    
    //规程首页
    var pathRegulationHome :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathRegulationHome
    }
    
    //规程目录
    var pathRegulationCatalogue :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathRegulationCatalogue
    }
    
    //专家列表
    var pathExpertList:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathExpertList
    }
    
    //对专家评分
    var pathGradeExpert:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathGradeExpert
    }
    
    //获取书籍订单信息
    var pathBookOrderInfo:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathBookOrderInfo
    }
    
    
    
    // MARK: - Private Method
    //获取BaseUrl,HTTPS 传输协议HTTPS/HTTP
    func baseUrlLoadedBy(HTTPS:Bool) -> String {
        var baseUrl = kBaseURL
        if HTTPS == false {
            if baseUrl.hasPrefix("https"){
                baseUrl = baseUrl.replacingOccurrences(of: "https", with: "http")
            }
        }else{
            if baseUrl.hasPrefix("https") == false {
                baseUrl = baseUrl.replacingOccurrences(of: "http", with: "https")
            }
        }
        return baseUrl
    }
    
    // MARK: -  Property
    //MARK:/**********登录注册*************/
    let kPathVerifyPhoneExist = "/app_core_api/v1/account/verification_mobile"//验证手机号码是否已注册
    let kPathRegister         = "/app_core_api/v1/account/regist"             //注册
    let kPathValidateToken    = "/app_core_api/v1/account/check_token"        //token是否有效
    let kPathLogin            = "/app_core_api/v1/account/login"              //登录
    let kPathForgetPasswd     = "/app_core_api/v1/account/forget_password"    //忘记密码
    let kPathLogout           = "/app_core_api/v1/account/logout"             //退出登录
    let kPathWhetherPhonesAreRegistered = "/app_core_api/v1/account/verifyPhonesIsReg"//批量校验手机号是否已注册
    let kPathVerifyThridPartyAccount = "/app_core_api/v1/account/authenticate"//验证第三方账号登录有效性
    let kPathBindPhoneByThirdPartyAccountLogin = "/app_core_api/v1/account/bind_authenticate"//通过第三方登录绑定手机号
    let kPathThridPartyLoginSetPasswd = "/app_core_api/v1/account/reset_password"   //第三方绑定手机后设置密码
    let kPathLoginByWebPage = "/taxtao/chat/confirm_login"  //税道网页登录
    let kPathBootLogging = "/taxtao/api/monitor/startupLog"     //启动日志
    
    
    //MARK:/**********工作圈**********/
    let kPathSendDynamic      = "/taxtao/api/dynamics/public"   //发布动态
    let kPathWorkGroupDynamicList = "/taxtao/api/dynamics/public_timeline"    //获取工作圈动态列表
    let kPathWorkGroupDynamicListByTag = "/taxtao/api/dynamics/public_timeline_by_type"//按标签获取工作圈动态列表
    let kPathCommentDynamic   = "/taxtao/api/comments/create"  //评论动态
    let kPathLikeDynamic      = "/taxtao/api/attitude/click"   //赞某条动态
    let kPathDynamicCommentList = "/taxtao/api/comments/show"    //获取某一条动态的评论列表
    let kPathDynamicLikeList   = "/taxtao/api/attitude/show"    //获取某一条动态的点赞列表
    let kPathDynamicRepost     = "/taxtao/api/dynamics/repost"  //转发某一条动态
    let kPathDeleteDynamicComment = "/taxtao/api/comments/destroy" //删除某一条评论
    let kPathGetDynamciDetail  = "/taxtao/api/dynamics/find_dynamic"   //获取动态详情页
    let kPathSearchDynamic     = "/taxtao/api/dynamics/search"         //搜索动态
    let kPathSynthesisSearch   = "/taxtao/api/search/complex_search" //综合搜索
    let kPathReplyComment      = "/taxtao/api/comments/reply"          //回复评论
    
    
    //MARK:/**********发现************/
    let kPathGetBigNamesList   = "/taxtao/api/account/list_daka"//获取大咖列表
    let kPathBigNameDynamics   = "/taxtao/api/dynamics/daka_dynamic"//获取大咖动态
    let kPathFollowBigName     = "/taxtao/api/focus/focus_daka" //关注(取消关注）大咖
    let kPathChangeIdentify    = "/taxtao/api/account/change_user_type"//身份转变
    let kPathFindLaws          = "/taxtao/api/lawlib/search"  //找法规
    
    
    
    
    
    
    //MARK:/**********人脉************/
    let kPathNewFriends       = "/taxtao/api/friendships/new_friends"    //获取新的好友
    let kPathMyFriends        = "/taxtao/api/friendships/friends"        //我的好友
    let kPathAddFriend        = "/taxtao/api/friendships/create"         //添加好友
    let kPathDeleteFriend     = "/taxtao/api/friendships/delete"         //删除好友
    let kPathVisitCardDetail  = "/taxtao/api/account/visit"              //访问名片详情
    let kPathRelationWithMe   = "/taxtao/api/friendships/analysis_friendships"//其他用户与我的关系查询
    let kPathAcceptAddFriendReq  = "/taxtao/api/friendships/acceptFriend"//接受加好友请求
    let kPathFindFriends      = "/app_core_api/v1/account/findFriends"//查找朋友
    let kPathGetUserAccount   = "/app_core_api/v1/account/my_account" //获取用户账号信息（手机号和税道账号）
    let kPathSearchConnection = "/taxtao/api/account/search" //人脉搜索
    let kPathComplain = "/taxtao/api/complain/public"
    let kPathModifyBlackList  = "/taxtao/api/account/set_black_list"//修改用户黑名单
    
    
    //MARK:/************我***********/
    let kPathTaxAccountExist  = "/app_core_api/v1/account/verification_username"//验证税道账号是否存在
    let kPathEditMyCard       = "/taxtao/api/account/edit"           //修改我的名片
    let kPathMyCard           = "/taxtao/api/account/my_account"          //我的名片
    let kPathModifyPasswd     = "/app_core_api/v1/account/change_password"//修改密码
    let kPathGetMyDynamics    = "/taxtao/api/dynamics/my_dynamic"     //获取我的动态
    let kPathGetFriDynamics   = "/taxtao/api/dynamics/friendship_dynamic"//获取好友的动态
    let kPathGetMyVistors     = "/taxtao/api/friendships/visitors"    //获取我的访客
    let kPathUploadImage      = "/taxtao/api/images/uploads"          //上传图片
    let kPathValidateOldPasswd = "/app_core_api/v1/account/verification_pasword"                                           //验证旧密码是否正确
    let kPathChangePhone      = "/app_core_api/v1/account/change_mobile"    //更改手机号码
    let kPathChangeTaxAccount = "/app_core_api/v1/account/change_username"  //更改税道账号
    let kPathGetAppInfo       = "/app_core_api/v1/appBaseInfo"              //获取应用基本信息
    let kPathCheckUpdate      = "/app_core_api/v1/checkUpgrade"             //检查更新
    let kPathGetAbout         = "/app_core_api/v1/bootstrap"                 //获取关于内容
    let kPathIndustryList     = "/taxtao/api/industry/list"                     //获取行业职位列表
    let kPathEditJobTags      = "/taxtao/api/account/jobLable"                 //编辑职位标签
    let kPathEditWorkExp      = "/taxtao/api/account/workExp"                  //编辑工作经历
    let kPathEditEducationExp = "/taxtao/api/account/eduExp"                   //编辑教育经历
    let kPathDeleteMyDynamic  = "/taxtao/api/dynamics/destroy"//删除我的动态
    
    
    //MARK:/************App基本信息***********/
    let kPathPageCanOpened = "/app_core_api/v1/app_function"//获取页面能否打开
    
    //MARK:/**********聊天***************/
    let kPathCreatGroupChat = "/taxtao/api/im/create_chat_group"//创建群聊
    let kPathAddGroupMember = "/taxtao/api/im/add_chat_group"//添加群成员
    let kPathGetChatLog     = "/taxtao/api/im/chat_messages"//获取聊天记录
    let kPathUnReadMsg      = "/taxtao/api/im/notification"      //获取未读消息（群聊+私聊+新的好友）
    let kPathUploadRecordFile   = "/taxtao/api/im/upload_audio"//上传录音文件
    let kPathUploadOfficeFile   = "/taxtao/api/files/uploads"//上传办公文件（eg:pdf,word,excel）
    let kPathGetGroupChatList   = "/taxtao/api/im/group_list"//获取群聊列表
    let kPathSendChatMsg        = "/taxtao/api/im/send_msg"//发送聊天信息
    let kPathGetChatList        = "/taxtao/api/im/chat_history_list" //获取聊天列表
    let kPathMsgStick           = "/taxtao/api/im/chat_history_top"//消息置顶
    let kPathMsgCancelStick     = "/taxtao/api/im/chat_history_top/cancel"//取消消息置顶
    let kPathGroupMembers       = "/taxtao/api/im/group_members"//获取群成员
    let kPathDeleteSession      = "/taxtao/api/im/delete_history"//删除会话
    let kPathModifyGroupName    = "/taxtao/api/im/modify_group_name" //修改群名称
    let kPathModifyMyNameInGroup = "/taxtao/api/im/modify_member_name"//修改我在本群的名称
    let kPathTransferGroupOwner  = "/taxtao/api/im/transfer_group"//转让群
    let kPathQuitGroup           = "/taxtao/api/im/quit_chat_group"//退出群聊
    let kPathGroupInfo           = "/taxtao/api/im/group_info"//获取群信息
    let kPathWithDrawMsg         = "/taxtao/api/im/retract_msg"//消息撤回
    let kPathGradeExpert = "/taxtao/api/expert/score" //对专家评分
    
    //MARK:/**********悬赏***************/
    //修改悬赏订单状态
    let kPathUpdateRewardStatus = "/taxtao/api/reward/update_payment_status"
    
    //MARK:/**********工作指引***************/
    let kPathUpdateWorkGuideStatus = "/taxtao/api/order/update_status" //更新工作指引订单状态
    fileprivate let kPathBookOrderInfo = "/taxtao/api/order"//获取书籍订单信息
    
    //MARK:- /**********网页路径*************/
    fileprivate let kPathTaxHome  = "/taxtao/index" //税道首页
    fileprivate let kPathTaxHome2 = "/taxtao/index_new"//税道首页2
    fileprivate let kPathTaxHome3 = "/taxtao/v2"  //税道首页3
    fileprivate let kPathWorkGuideHome   = "/taxtao/v2/books"//工作指引
    fileprivate let kPathTrainingOnline  = "/taxtao/v2/train/online"//线上培训
    fileprivate let kPathTrainingOffline = "/taxtao/v2/train/line"//线下培训
    fileprivate let kPathEvaluationHome  = "/taxtao/v2/evaluation"//测评首页
    fileprivate let kPathCaseHome    = "/tax/sd/case" //案例首页
    fileprivate let kPathCaseSearch  = "/tax/sd/case/search"//案例搜索（第一版,已弃用）
    fileprivate let kPathCaseSearch2 = "/taxtao/web/case/search"//案例搜索2
    fileprivate let kPathLawLib      = "/taxtao/lawlib/search?"//法规库
    fileprivate let kPathWechatPayDetail = "/wxpay_demo/wxPay"//支付详情
    fileprivate let kPathTalentHome = "/talente/sd/hottalent/list"//人才首页
    fileprivate let kPathRewardHome = "/taxtao/building"//悬赏首页
    fileprivate let kPathRewardList = "/taxtao/reward/list_all_reward"//悬赏列表
    fileprivate let kPathSendReward = "/taxtao/reward/public_reward"//发悬赏
    fileprivate let kPathChatDetail = "/taxtao/webim/chat_mobile"//聊天详情页
    fileprivate let kPathGroupList  = "/taxtao/webim/group_list"//群列表
    fileprivate let kPathGroupSetting = "/taxtao/webim/group_info"//群设置
    fileprivate let kPathGroupChat  = "/taxtao/webim/chat_group_mobile"//群聊界面
    fileprivate let kPathChatList   = "/taxtao/webim/list"//聊天列表
    fileprivate let kPathSearchHome = "/taxtao/search"//搜索的首页
    fileprivate let kPathNewsHome   = "/tax/sd/ygz"//资讯首页
    fileprivate let kPathMyWallet   = "/taxtao/myWallet"//我的钱包
    fileprivate let kPathRemoveGroupMemebers = "/taxtao/webim/group_members/"//移除群成员
    fileprivate let kPathTransferGroupOwnerWeb  = "/taxtao/webim/group_members/"//群主权限转
    fileprivate let kPathEvaluationDetail    = "/taxtao/v2/evaluation/questions/"//评测详情页
    fileprivate let kPathMyCollection        = "/taxtao/collect/"//我的收藏
    fileprivate let kPathRegulationHome      = "/taxtao/v2/rule/"//规程首页
    fileprivate let kPathRegulationCatalogue = "/taxtao/v2/rule/catalog/34/"//规程目录
    fileprivate let kPathExpertList = "/taxtao/v2/advisory/expert/list"//专家列表
}




