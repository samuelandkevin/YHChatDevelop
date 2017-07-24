//
//  YHError.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/17.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation




class YHError :NSObject {
 
    /// 单例
    static let shareInstance = YHError()
    private override init(){}
    
     var  verifyCodeErrorCount:UInt = 0 //验证码输入错误的次数
     var  resetCodeErrorCount:UInt  = 0 //重置密码输错次数
    
    /**
     *  服务器返回的错误代码
     */
    let kErrorSystem           = "10001"      //系统错误
    let kErrorParameters       = "10002"      //参数错误
    let kErrorMissingParameter = "10003"      //缺少必要参数
    let kErrorUserAccontUnavailable = "20001" //用账号无效
    let kErrorUserNameOrPasswd = "20002"      //用户名或密码错误
    let kErrorVerifyCode       = "20003"      //验证码错误
    let kErrorRegisterFail     = "20004"      //注册失败
    let kErrorPhoneNumExist    = "20005"      //手机号已经存在
    let kErrorUserNameExist    = "20006"      //用户名已经存在
    let kErrorOldPasswd        = "20007"      //旧密码错误
    let kErrorAppisNotExist    = "20008"      //应用不存在
    let kErrorDataDictisNotExist = "20009"    //数据字典不存在
    let kErrorRequest          = "40000"      //错误的请求
    let kErrorTokenUnavailable = "40001"      //token失效
    let kErrorApiIsNotExist    = "40004"      //接口不存在
    let kErrorRequestMethod    = "40005"      //请求方式错误（get/post）
    let kErrorMediaTypeUnsupport = "40015"    //不支持当前媒体类型
    let kErrorServerInteral    = "50001"      //服务器内部错误
}



