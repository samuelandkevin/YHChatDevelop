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
    //验证手机号码是否已注册
    var pathVerifyPhoneExist:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathVerifyPhoneExist
    }
    //注册
    var pathRegister:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathRegister
    }
    //token是否有效
    var pathValidateToken:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathValidateToken
    }
    //登录
    var pathLogin:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathLogin
    }
    //忘记密码
    var pathForgetPasswd:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathForgetPasswd
    }
    //退出登录
    var pathLogout :String{
        return baseUrlLoadedBy(HTTPS: true) + kPathLogout
    }
    //批量校验手机号是否已注册
    var pathWhetherPhonesAreRegistered :String{
        return baseUrlLoadedBy(HTTPS: true) + kPathWhetherPhonesAreRegistered
    }
    //验证第三方账号登录有效性
    var pathVerifyThridPartyAccount :String{
        return baseUrlLoadedBy(HTTPS: true) + kPathVerifyThridPartyAccount
    }
    //通过第三方登录绑定手机号
    var pathBindPhoneByThirdPartyAccountLogin :String{
        return baseUrlLoadedBy(HTTPS: true) + kPathBindPhoneByThirdPartyAccountLogin
    }
    //第三方绑定手机后设置密码
    var pathThridPartyLoginSetPasswd:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathThridPartyLoginSetPasswd
    }
    //税道网页登录
    var pathLoginByWebPage:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathLoginByWebPage
    }
    //启动日志
    var pathBootLogging:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathBootLogging
    }
    
    
    fileprivate let kPathVerifyPhoneExist = "/app_core_api/v1/account/verification_mobile"//验证手机号码是否已注册
    fileprivate let kPathRegister         = "/app_core_api/v1/account/regist"             //注册
    fileprivate let kPathValidateToken    = "/app_core_api/v1/account/check_token"        //token是否有效
    fileprivate let kPathLogin            = "/app_core_api/v1/account/login"              //登录
    fileprivate let kPathForgetPasswd     = "/app_core_api/v1/account/forget_password"    //忘记密码
    fileprivate let kPathLogout           = "/app_core_api/v1/account/logout"             //退出登录
    fileprivate let kPathWhetherPhonesAreRegistered = "/app_core_api/v1/account/verifyPhonesIsReg"//批量校验手机号是否已注册
    fileprivate let kPathVerifyThridPartyAccount = "/app_core_api/v1/account/authenticate"//验证第三方账号登录有效性
    fileprivate let kPathBindPhoneByThirdPartyAccountLogin = "/app_core_api/v1/account/bind_authenticate"//通过第三方登录绑定手机号
    fileprivate let kPathThridPartyLoginSetPasswd = "/app_core_api/v1/account/reset_password"   //第三方绑定手机后设置密码
    fileprivate let kPathLoginByWebPage = "/taxtao/chat/confirm_login"  //税道网页登录
    fileprivate let kPathBootLogging = "/taxtao/api/monitor/startupLog"     //启动日志
    
    
    //MARK:/**********工作圈**********/
    //发布动态
    var pathSendDynamic      :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathSendDynamic
    }
    
    //获取工作圈动态列表
    var pathWorkGroupDynamicList :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathWorkGroupDynamicList
    }
    
    //按标签获取工作圈动态列表
    var pathWorkGroupDynamicListByTag :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathWorkGroupDynamicListByTag
    }
    
    //评论动态
    var pathCommentDynamic   :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathCommentDynamic
    }
    
    //赞某条动态
    var pathLikeDynamic      :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathLikeDynamic
    }
    
    //获取某一条动态的评论列表
    var pathDynamicCommentList :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathDynamicCommentList
    }
    
    //获取某一条动态的点赞列表
    var pathDynamicLikeList   :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathDynamicLikeList
    }
    
    //转发某一条动态
    var pathDynamicRepost     :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathDynamicRepost
    }
    
    //删除某一条评论
    var pathDeleteDynamicComment :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathDeleteDynamicComment
    }
    
    //获取动态详情页
    var pathGetDynamciDetail  :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetDynamciDetail
    }
    
    //搜索动态
    var pathSearchDynamic     :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathSearchDynamic
    }
    
    //综合搜索
    var pathSynthesisSearch   :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathSynthesisSearch
    }
    
    //回复评论
    var pathReplyComment      :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathReplyComment
    }
    
    
    fileprivate let kPathSendDynamic      = "/taxtao/api/dynamics/public"   //发布动态
    fileprivate let kPathWorkGroupDynamicList = "/taxtao/api/dynamics/public_timeline"    //获取工作圈动态列表
    fileprivate let kPathWorkGroupDynamicListByTag = "/taxtao/api/dynamics/public_timeline_by_type"//按标签获取工作圈动态列表
    fileprivate let kPathCommentDynamic   = "/taxtao/api/comments/create"  //评论动态
    fileprivate let kPathLikeDynamic      = "/taxtao/api/attitude/click"   //赞某条动态
    fileprivate let kPathDynamicCommentList = "/taxtao/api/comments/show"    //获取某一条动态的评论列表
    fileprivate let kPathDynamicLikeList   = "/taxtao/api/attitude/show"    //获取某一条动态的点赞列表
    fileprivate let kPathDynamicRepost     = "/taxtao/api/dynamics/repost"  //转发某一条动态
    fileprivate let kPathDeleteDynamicComment = "/taxtao/api/comments/destroy" //删除某一条评论
    fileprivate let kPathGetDynamciDetail  = "/taxtao/api/dynamics/find_dynamic"   //获取动态详情页
    fileprivate let kPathSearchDynamic     = "/taxtao/api/dynamics/search"         //搜索动态
    fileprivate let kPathSynthesisSearch   = "/taxtao/api/search/complex_search" //综合搜索
    fileprivate let kPathReplyComment      = "/taxtao/api/comments/reply"          //回复评论
    
    
    //MARK:/**********发现************/
    
    var pathGetBigNamesList   :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetBigNamesList
    }//获取大咖列表
    var pathBigNameDynamics   :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathBigNameDynamics
    }//获取大咖动态
    var pathFollowBigName     :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathFollowBigName
    } //关注(取消关注）大咖
    var pathChangeIdentify    :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathChangeIdentify
    }//身份转变
    var pathFindLaws          :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathFindLaws
    }  //找法规
    
    
    fileprivate let kPathGetBigNamesList   = "/taxtao/api/account/list_daka"//获取大咖列表
    fileprivate let kPathBigNameDynamics   = "/taxtao/api/dynamics/daka_dynamic"//获取大咖动态
    fileprivate let kPathFollowBigName     = "/taxtao/api/focus/focus_daka" //关注(取消关注）大咖
    fileprivate let kPathChangeIdentify    = "/taxtao/api/account/change_user_type"//身份转变
    fileprivate let kPathFindLaws          = "/taxtao/api/lawlib/search"  //找法规
    
    
    
    //MARK:/**********人脉************/
    
    //获取新的好友
    var pathNewFriends:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathNewFriends
    }
    
    //我的好友
    var pathMyFriends:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathMyFriends
    }
    
    //添加好友
    var pathAddFriend:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathAddFriend
    }
    
    //删除好友
    var pathDeleteFriend:String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathDeleteFriend
    }
    
    //访问名片详情
    var pathVisitCardDetail:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathVisitCardDetail
    }
    
    //其他用户与我的关系查询
    var pathRelationWithMe:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathRelationWithMe
    }
    
    //接受加好友请求
    var pathAcceptAddFriendReq:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathAcceptAddFriendReq
    }
    
    //查找朋友
    var pathFindFriends:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathFindFriends
    }
    
    //获取用户账号信息（手机号和税道账号）
    var pathGetUserAccount:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetUserAccount
    }
    
    //人脉搜索
    var pathSearchConnection:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathSearchConnection
    }
    
    //投诉
    var pathComplain:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathComplain
    }
    
    //修改用户黑名单
    var pathModifyBlackList:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathModifyBlackList
    }
    
    //删除好友申请记录
    var pathDeleteRecordOfAddFri:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathDeleteRecordOfAddFri
    }
    
    
    fileprivate let kPathNewFriends       = "/taxtao/api/friendships/new_friends"    //获取新的好友
    fileprivate let kPathMyFriends        = "/taxtao/api/friendships/friends"        //我的好友
    fileprivate let kPathAddFriend        = "/taxtao/api/friendships/create"         //添加好友
    fileprivate let kPathDeleteFriend     = "/taxtao/api/friendships/delete"         //删除好友
    fileprivate let kPathVisitCardDetail  = "/taxtao/api/account/visit"              //访问名片详情
    fileprivate let kPathRelationWithMe   = "/taxtao/api/friendships/analysis_friendships"//其他用户与我的关系查询
    fileprivate let kPathAcceptAddFriendReq  = "/taxtao/api/friendships/acceptFriend"//接受加好友请求
    fileprivate let kPathFindFriends      = "/app_core_api/v1/account/findFriends"//查找朋友
    fileprivate let kPathGetUserAccount   = "/app_core_api/v1/account/my_account" //获取用户账号信息（手机号和税道账号）
    fileprivate let kPathSearchConnection = "/taxtao/api/account/search" //人脉搜索
    fileprivate let kPathComplain = "/taxtao/api/complain/public"
    fileprivate let kPathModifyBlackList  = "/taxtao/api/account/set_black_list"//修改用户黑名单
    fileprivate let kPathDeleteRecordOfAddFri = "/taxtao/api/friendships/delete_record"//删除好友申请记录
    
    //MARK:/************我***********/
    //验证税道账号是否存在
    var pathTaxAccountExist:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathTaxAccountExist
    }
    
    //修改我的名片
    var pathEditMyCard:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathEditMyCard
    }
    
    //我的名片
    var pathMyCard :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathMyCard
    }
    
    //修改密码
    var pathModifyPasswd:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathModifyPasswd
    }
    
    //获取我的动态
    var pathGetMyDynamics:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetMyDynamics
    }
    
    //获取好友的动态
    var pathGetFriDynamics:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetFriDynamics
    }
    
    //获取我的访客
    var pathGetMyVistors:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetMyVistors
    }
    
    //上传图片
    var pathUploadImage:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathUploadImage
    }
    
    //验证旧密码是否正确
    var pathValidateOldPasswd:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathValidateOldPasswd
    }
    
    //更改手机号码
    var pathChangePhone :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathChangePhone
    }
    
    //更改税道账号
    var pathChangeTaxAccount:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathChangeTaxAccount
    }
    
    //获取应用基本信息
    var pathGetAppInfo:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetAppInfo
    }
    
    //检查更新
    var pathCheckUpdate :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathCheckUpdate
    }
    
    //获取关于内容
    var pathGetAbout:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathGetAbout
    }
    
    //获取行业职位列表
    var pathIndustryList:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathIndustryList
    }
    
    //编辑职位标签
    var pathEditJobTags:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathEditJobTags
    }
    
    //编辑工作经历
    var pathEditWorkExp:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathEditWorkExp
    }
    
    //编辑教育经历
    var pathEditEducationExp:String {
        return baseUrlLoadedBy(HTTPS: true) + kPathEditEducationExp
    }
    
    //删除我的动态
    var pathDeleteMyDynamic :String {
        return baseUrlLoadedBy(HTTPS: true) + kPathDeleteMyDynamic
    }
    
    
    fileprivate let kPathTaxAccountExist  = "/app_core_api/v1/account/verification_username"//验证税道账号是否存在
    fileprivate let kPathEditMyCard       = "/taxtao/api/account/edit"           //修改我的名片
    fileprivate let kPathMyCard           = "/taxtao/api/account/my_account"          //我的名片
    fileprivate let kPathModifyPasswd     = "/app_core_api/v1/account/change_password"//修改密码
    fileprivate let kPathGetMyDynamics    = "/taxtao/api/dynamics/my_dynamic"     //获取我的动态
    fileprivate let kPathGetFriDynamics   = "/taxtao/api/dynamics/friendship_dynamic"//获取好友的动态
    fileprivate let kPathGetMyVistors     = "/taxtao/api/friendships/visitors"    //获取我的访客
    fileprivate let kPathUploadImage      = "/taxtao/api/images/uploads"          //上传图片
    fileprivate let kPathValidateOldPasswd = "/app_core_api/v1/account/verification_pasword"                                           //验证旧密码是否正确
    fileprivate let kPathChangePhone      = "/app_core_api/v1/account/change_mobile"    //更改手机号码
    fileprivate let kPathChangeTaxAccount = "/app_core_api/v1/account/change_username"  //更改税道账号
    fileprivate let kPathGetAppInfo       = "/app_core_api/v1/appBaseInfo"              //获取应用基本信息
    fileprivate let kPathCheckUpdate      = "/app_core_api/v1/checkUpgrade"             //检查更新
    fileprivate let kPathGetAbout         = "/app_core_api/v1/bootstrap"                 //获取关于内容
    fileprivate let kPathIndustryList     = "/taxtao/api/industry/list"                     //获取行业职位列表
    fileprivate let kPathEditJobTags      = "/taxtao/api/account/jobLable"                 //编辑职位标签
    fileprivate let kPathEditWorkExp      = "/taxtao/api/account/workExp"                  //编辑工作经历
    fileprivate let kPathEditEducationExp = "/taxtao/api/account/eduExp"                   //编辑教育经历
    fileprivate let kPathDeleteMyDynamic  = "/taxtao/api/dynamics/destroy"//删除我的动态
    
    
    //MARK:/************App基本信息***********/
    let kPathPageCanOpened = "/app_core_api/v1/app_function"//获取页面能否打开
    
    //MARK:/**********聊天***************/
    
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
    var pathUpdateRewardStatus:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathUpdateRewardStatus
    }
    
    //修改悬赏订单状态
    fileprivate let kPathUpdateRewardStatus = "/taxtao/api/reward/update_payment_status"
    
    //MARK:/**********工作指引***************/
    //更新工作指引订单状态
    var pathUpdateWorkGuideStatus :String{
        return baseUrlLoadedBy(HTTPS: true) + kPathUpdateWorkGuideStatus
    }
    //获取书籍订单信息
    var pathBookOrderInfo:String{
        return baseUrlLoadedBy(HTTPS: true) + kPathBookOrderInfo
    }
    
    fileprivate let kPathUpdateWorkGuideStatus = "/taxtao/api/order/update_status" //更新工作指引订单状态
    fileprivate let kPathBookOrderInfo = "/taxtao/api/order"//获取书籍订单信息
    
    
    
    
    //MARK:- /**********网页路径*************/
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
    
    //微信支付详情
    var pathWechatPayDetail :String  {
        return baseUrlLoadedBy(HTTPS: true) + kPathWechatPayDetail
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





