//
//  YHCommon.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation

let kBlackColor_Swift = UIColor(red: 54/255.0, green: 54/255.0, blue: 59/255.0, alpha: 1.0)
//let kBlueColor_Swift = UIColor.colorWithHexString(hex: "0e92dd")
let kBlueColor_Swift = UIColor(red: 9/255.0, green: 187/255.0, blue: 7/255.0, alpha: 1.0)
let kRedColor_Swift  = UIColor(red: 221/255.0, green: 82/255.0, blue: 77/255.0, alpha: 1.0)
let kSeparatorLineColor_Swift = UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)  //分隔线颜色
let kTbvBGColor_Swift =  UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)         //控制器view的背景色
//通知
let kNotif_Evaluation_BeginTest_Refresh_Swift = "kNotif_Evaluation_BeginTest_Refresh"               //刷新开始测评页
let kNotif_Login_Success_Swift = "event.login.success"  //登录成功
let kNotif_Logout_Swift = "event.logout" //退出登录
let kNotif_ChangeSystemFontSize_Swift = "event.SystemFontSize_Change" //改变系统字体大小
let kNotif_notRegister_showLoginVC_Swift = "event.notRegister.showLoginVC" //未登录弹出提示
let kNotif_HomePage_Refresh_Swift = "event.homepage.refresh" //刷新首页
let kNotif_MyFriendsPage_Refresh_Swift = "event.myFriendsPage_Refresh"//刷新我的好友页
let kNotif_CardDetailPage_Refresh_Swift = "event.cardDetailPage_refresh"//刷新名片详情页
let kNotif_GroupSettingPage_Refresh_Swift = "event.groupSettingPage.refresh"//刷新群设置页

//已经浏览过欢迎页
let kHasReadWelcomePage = "HasReadWelcomePage"

//frame
let KeyWindow = UIApplication.shared.keyWindow
let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

//企业用户ID
let kEnterpriseId_Swift = "enterpriseId"

func isDictionaryClass(_ obj:Any)->Bool{
    if obj is Dictionary<String,Any> {
        return true
    }
    return false
}

let kRetCode_Swift  = "code"  //服务器返回的代码 key
let kRetMsg_Swift   = "msg"   //服务器返回的描述 key


//友盟统计事件
let statistics_sy               = "首页"
let statistics_sy_gzzy          = "首页_工作指引页"
let statistics_sy_al            = "首页_案例页"
let statistics_sy_px            = "首页_培训页"
let statistics_sy_zxpx          = "首页_在线培训页"
let	statistics_sy_zycp          = "首页_执业测评"
let statistics_zycp_swzj_kscp   = "执业测评_税务总监_开始测评"
let	statistics_zycp_swjl_kscp   = "执业测评_税务经理_开始测评"
let statistics_zycp_swzg_kscp   = "执业测评_税务主管_开始测评"
let	statistics_zycp_swzy_kscp   = "执业测评_税务专员_开始测评"
let	statistics_zycp_cbzj_kscp   = "执业测评_成本总监_开始测评"
let	statistics_zycp_cbzg_kscp   = "执业测评_成本主管_开始测评"
let	statistics_zycp_cbjl_kscp   = "执业测评_成本经理_开始测评"
let	statistics_zycp_cbzy_kscp   = "执业测评_成本专员_开始测评"
let	statistics_zycp_fkzj_kscp   = "执业测评_风控总监_开始测评"
let	statistics_zycp_fkjl_kscp   = "执业测评_风控经理_开始测评"
let	statistics_zycp_fkzg_kscp   = "执业测评_风控主管_开始测评"
let	statistics_zycp_fkzy_kscp   = "执业测评_风控专员_开始测评"
let	statistics_zycp_cwzj_kscp   = "执业测评_财务总监_开始测评"
let	statistics_zycp_cwjl_kscp   = "执业测评_财务经理_开始测评"
let	statistics_zycp_cwzg_kscp   = "执业测评_财务主管_开始测评"
let	statistics_zycp_cwzy_kscp   = "执业测评_财务专员_开始测评"
let	statistics_sy_fgk           = "首页_法规库"
let	statistics_sy_zcjd          = "首页_政策解读"
let	statistics_sy_bszy          = "首页_办事指引"
let	statistics_sy_rmal_gd       = "首页_热门案例_更多"
let	statistics_sy_zxal_gd       = "首页_最新案例_更多"
let	statistics_sy_dkal_gd       = "首页_大咖分享_更多"
let	statistics_sy_zxzxzj        = "首页_在线咨询专家"
let statistics_sy_xx            = "首页_消息"
let statistics_sy_txl           = "首页_通讯录"
let statistics_sy_w             = "首页_我"

