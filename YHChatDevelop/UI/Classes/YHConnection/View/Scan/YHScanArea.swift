//
//  YHScanArea.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/18.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation

class YHScanArea:UIView{
    
    /**
     *  记录当前线条绘制的位置
     */
    private var _position = CGPoint.zero
    
    /**
     *  定时器
     */
    private var _timer:Timer?
    
    /**
     *  开始动画
     */
    open func startAnimaion(){
        if _timer == nil {
            _timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(_needsDisplay), userInfo: nil, repeats: true)
            _timer?.fire()
        }
    }

    
    /**
     *  暂停动画
     */
    open func stopAnimaion(){
        _timer?.fireDate = Date.distantFuture
    }

    
    /**
     *  关闭定时器
     */
    open func closeTimer(){
        _timer?.invalidate()
        _timer = nil
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        //扫描区域背景图
        let scanView = UIImageView(image: UIImage(named: "connections_img_scanFrame"))
        var aframe = scanView.frame
        aframe.size.width  = bounds.size.width
        aframe.size.height = bounds.size.height
        scanView.frame     = aframe
        addSubview(scanView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Private
    @objc fileprivate func _needsDisplay(){
        setNeedsDisplay()
    }
    
    
    // MARK: - Life
    
    override func draw(_ rect: CGRect) {
        
        var newPosition = _position
        newPosition.y += 1
        
        //判断y到达底部，从新开始下降
        if (newPosition.y > rect.size.height) {
            newPosition.y = 0
        }
        
        //重新赋值position
        _position = newPosition
        
        // 绘制图片
        let image = UIImage(named: "connections_img_scanLine")
        image?.draw(at: _position)

    }
    
    
    deinit {
        closeTimer()
        YHPrint("\(#file) is deinit")
    }
}
