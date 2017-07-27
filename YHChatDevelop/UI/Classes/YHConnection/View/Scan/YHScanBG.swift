//
//  YHScanBG.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation



class YHScanBG:UIView {
    
    /**
     *  扫描区域
     */
    private var _scanFrame:CGRect
    private let _scanW:CGFloat
    private let _scanH:CGFloat
    
    // MARK: - init
    convenience init(frame:CGRect,scanW:CGFloat,scanH:CGFloat){
        self.init(scanFrame: frame, scanW: scanW, scanH: scanH)
        backgroundColor = UIColor.clear
    }
    
    private init(scanFrame:CGRect,scanW:CGFloat,scanH:CGFloat){
        _scanFrame = scanFrame
        _scanW     = scanW
        _scanH     = scanH
        super.init(frame: scanFrame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
       
        _scanFrame = CGRect(x: (bounds.size.width - _scanW)/2, y: (bounds.size.height - _scanH)/2, width: _scanW, height: _scanH)
        let context = UIGraphicsGetCurrentContext()
        
            
        //填充区域颜色
        UIColor.black.withAlphaComponent(0.65).set()
        
            
        //扫码区域上面填充
        let notScanRect = CGRect(x: 0, y: 0, width: frame.size.width, height: _scanFrame.origin.y)
        context?.fill(notScanRect)
       
            
        //扫码区域左边填充
        var rect = CGRect(x: 0, y: _scanFrame.origin.y, width: _scanFrame.origin.x, height: _scanFrame.size.height)
        context?.fill(rect)
        
            
        //扫码区域右边填充
        rect = CGRect(x: _scanFrame.maxX, y: _scanFrame.origin.y, width: _scanFrame.origin.x, height: _scanFrame.size.height)
        context?.fill(rect)
        
        //扫码区域下面填充
        rect = CGRect(x: 0, y: _scanFrame.maxY, width: frame.size.width, height: (frame.size.height - _scanFrame.maxY))
        context?.fill(rect)
        
        
    }
    
    // MARK: - Life
    deinit {
        YHPrint("\(#function) is deinit")
    }
   
}
