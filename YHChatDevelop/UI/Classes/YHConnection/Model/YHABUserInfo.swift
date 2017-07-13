//
//  YHABUserInfo.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation

open class YHABUserInfo :NSObject {

    open var userName:String?
    open var uid:String?
    open var mobilephone:String?
    open var isRegister:Bool = false     //已注册
    open var relation:String?            //好友关系
    open var addFriStatus:String?        //加好友的状态
    open var avatarImage:UIImage?
    open var isSelected:Bool = false     //记录按钮是否选中
    
}
