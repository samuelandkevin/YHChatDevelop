//
//  UIBarButtonItem+Extension.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/8.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation


let btnBlockKey = "btnBlockKey"
typealias BtnBlock = ((_ btn:UIButton) -> Void)?

extension UIBarButtonItem {
    
    //定义按钮闭包
    var btnBlock: BtnBlock {
        get{
            return objc_getAssociatedObject(self, btnBlockKey) as? (UIButton)->Void
        }
        set{
            objc_setAssociatedObject(self, btnBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    
    }
    
    // MARK: - Public Method

    /// 默认的左返回按钮
    ///
    /// - Parameters:
    ///   - target: 目标
    ///   - selector: 方法
    /// - Returns: UIBarButtonItem
    internal class func backItem(target:Any,selector:Selector) -> UIBarButtonItem{
    
        return _barButtonItem(frame: CGRect(x: 0, y: 0, width: 40, height: 40), imgName: "common_leftArrow", imageEdgeInsets: UIEdgeInsetsMake(0, -30, 0, 0), target: target, selector: selector)
    }
    
    /**********UIBarButtonItem为文字的设置**********/
    
    /// 左Item为纯文字
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - target: 目标
    ///   - selector: 方法
    /// - Returns: UIBarButtonItem
    internal class func leftItem(title:String,target:Any,selector:Selector) -> UIBarButtonItem{
       
        return  _barButtonItem(frame: CGRect(x: 0, y: 0, width: 40, height: 40), title: title, target: target, selector: selector, block: nil)
    }
    
    
    /// 左Item为纯文字
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - target: 目标
    ///   - selector: 方法
    ///   - block: 按钮回调
    /// - Returns: UIBarButtonItem
    internal class func leftItem(title:String,target:Any,selector:Selector,block:BtnBlock) -> UIBarButtonItem{
        
        return  _barButtonItem(frame: CGRect(x: 0, y: 0, width: 40, height: 40), title: title, target: target, selector: selector, block: block)
    }
    
    
    /// 右Item为纯文字
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - target: 目标
    ///   - selector: 方法
    /// - Returns: UIBarButtonItem
    internal class func rightItem(title:String,target:Any,selector:Selector) -> UIBarButtonItem{
        
        return  _barButtonItem(frame: CGRect(x: 0, y: 0, width: 40, height: 40), title: title, target: target, selector: selector, block: nil)
    }

    
    /// 右Item为纯文字
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - target: 目标
    ///   - selector: 方法
    ///   - block: 按钮回调
    /// - Returns: UIBarButtonItem
    internal class func rightItem(title:String,target:Any,selector:Selector,block:BtnBlock) -> UIBarButtonItem{
        
        return  _barButtonItem(frame: CGRect(x: 0, y: 0, width: 40, height: 40), title: title, target: target, selector: selector, block: block)
    }
    
    /**********UIBarButtonItem为图片的设置**********/
    
    
    /// 左Item为纯图片
    ///
    /// - Parameters:
    ///   - imgName: 图片名
    ///   - target: 目标
    ///   - selector: 方法
    /// - Returns: UIBarButtonItem
    internal class func leftItem(imgName:String,target:Any,selector:Selector) -> UIBarButtonItem{
        
        return _barButtonItem(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imgName: imgName, imageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 20), target: target, selector: selector)
    }
    
    
    /// 左Item为纯图片
    ///
    /// - Parameters:
    ///   - imgName: 图片名
    ///   - target: 目标
    ///   - selector: 方法
    ///   - block: 按钮回调
    /// - Returns: UIBarButtonItem
    internal class func leftItem(imgName:String,target:Any,selector:Selector,block:BtnBlock) -> UIBarButtonItem{
        return _barButtonItem(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imgName: imgName, imageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 20), target: target, selector: selector,block:block)
    }
    
    
    /// 右Item为纯图片
    ///
    /// - Parameters:
    ///   - imgName: 图片名
    ///   - target: 目标
    ///   - selector: 方法
    /// - Returns: UIBarButtonItem
    internal class func rightItem(imgName:String,target:Any,selector:Selector) -> UIBarButtonItem{
        
        return _barButtonItem(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imgName: imgName, imageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, -20), target: target, selector: selector)
    }
    
    
    /// 右Item为纯图片
    ///
    /// - Parameters:
    ///   - imgName: 图片名
    ///   - target: 目标
    ///   - selector: 方法
    ///   - block: 按钮回调
    /// - Returns: UIBarButtonItem
    internal class func rightItem(imgName:String,target:Any,selector:Selector,block:BtnBlock) -> UIBarButtonItem{
        
        return _barButtonItem(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imgName: imgName, imageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, -20), target: target, selector: selector,block:block)
    }
    
    
    
   // MARK: - Private Method
    
    internal class func _barButton(frame:CGRect,imgName:String,imageEdgeInsets:UIEdgeInsets,target:Any,selector:Selector) -> UIButton{
        let btn = UIButton(type: .system)
        btn.frame = frame
        btn.setImage(UIImage(named:imgName), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textColor = UIColor.white
        btn.addTarget(target, action: selector, for: .touchUpInside)
        btn.imageEdgeInsets = imageEdgeInsets
        return btn
    }
    
    internal class func _barButtonItem(frame:CGRect,imgName:String,imageEdgeInsets:UIEdgeInsets,target:Any,selector:Selector) -> UIBarButtonItem {
    
        let btn = _barButton(frame: frame, imgName: imgName, imageEdgeInsets: imageEdgeInsets, target: target, selector: selector)
        let barButtonItem = UIBarButtonItem(customView: btn)
        return barButtonItem
    }
    
    
    internal class func _barButtonItem(frame:CGRect,imgName:String,imageEdgeInsets:UIEdgeInsets,target:Any,selector:Selector,block:BtnBlock )-> UIBarButtonItem{
    
        let aBtn = _barButton(frame: frame, imgName: imgName, imageEdgeInsets: imageEdgeInsets, target: target, selector: selector)
        let item = UIBarButtonItem(customView: aBtn)
    
        if ((block) != nil) {
            item.btnBlock = block
            if let aBlock = item.btnBlock {
                aBlock(aBtn)
            }
        }
        return  item;
    }

    
    
    internal class func _barButtonItem(frame:CGRect,title:String,target:Any,selector:Selector,block:BtnBlock ) -> UIBarButtonItem{
    
        let btn = UIButton(type: .system)
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textColor = UIColor.white
        btn.addTarget(target, action: selector, for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        if ((block) != nil) {
            item.btnBlock = block
            if let aBlock = item.btnBlock {
                aBlock(btn)
            }
        }
        return  item
    }


    
}
