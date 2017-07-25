//
//  UITextField+FontChange.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/18.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation

extension UITextField {

    static func setupGlobalFont(){
        
        //获得viewController的生命周期方法的selector
        let systemSel = #selector(willMove(toSuperview:))
        
        //自己实现的将要被交换的方法的selector
        let swizzSel  = #selector(myWillMove(toSuperview:))
        
        //两个方法的Method
        let systemMethod = class_getInstanceMethod(self.classForCoder(), systemSel)
        let swizzMethod  = class_getInstanceMethod(self.classForCoder(),swizzSel)
        
        //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
        let isAdd = class_addMethod(self.classForCoder(), systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod))
        
        if (isAdd)
        {
            //如果成功，说明类中不存在这个方法的实现
            //将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(self.classForCoder(), swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod))
        }
        else
        {
            //否则，交换两个方法的实现
            method_exchangeImplementations(systemMethod, swizzMethod)
        }

    }
    
    @objc private func myWillMove(toSuperview:UIView){
        myWillMove(toSuperview: toSuperview)
        
        if self.isKind(of: NSClassFromString("UIButtonLabel")!) == true {
            return
        }
        
        
        
        let font  = self.font
        guard let fontSize = font?.pointSize ,let addFontSizeStr = UserDefaults.standard.value(forKey: "setSystemFontSize") as? String , let addFontSize = Int(addFontSizeStr) else {
            return
        }
        
        self.font = UIFont.systemFont(ofSize: (fontSize + CGFloat(addFontSize)) )
        
    }


}
