//
//  YHDPContentContainer.swift
//  PikeWay
//
//  Created by YHIOS003 on 16/8/22.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import UIKit


let MAX_LIMIT_NUMS = 500

class YHDynamicPublishController: UIViewController ,UITextViewDelegate{
    let textView = IQTextView(frame: CGRect.zero)
    let scrollView = UIScrollView(frame: CGRect.zero)
        
    let leftBtn = UIButton(type: UIButtonType.system)
    let rightBtn = UIButton(type: UIButtonType.system)
    lazy var labelArray:Array<AnyObject> = {
        return Array<AnyObject>()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.translucent = false

        self.initUI()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YHPrint(self.scrollView.frame,self.textView.frame)
    }
    
    func initNaviBtn() {
        self.leftBtn.layer.masksToBounds = true
        self.leftBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.leftBtn.setTitle("取消", for: UIControlState())
        self.leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.leftBtn.titleLabel?.textColor = UIColor.white
        self.leftBtn.addTarget(self, action: #selector(YHDynamicPublishController.publishCancel), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBtn)
        
        self.rightBtn.layer.masksToBounds = true
        self.rightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.rightBtn.setTitle("发布", for: UIControlState())
        self.rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.rightBtn.titleLabel?.textColor = UIColor.white
        self.rightBtn.addTarget(self, action: #selector(YHDynamicPublishController.dynamicPublish), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightBtn)
    }
    
    func dynamicPublish() {
        
    }
    
    func publishCancel() {
        self.dismiss(animated: true) {
            
        }
    }
    
    func initUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { [unowned self] (make) in
            make.edges.equalTo(self.view);
        }
        self.scrollView.backgroundColor = UIColor.white
        self.scrollView.addSubview(self.textView)
        self.textView.snp.makeConstraints { [unowned self] (make) in
            make.top.equalTo(self.scrollView)
            make.leading.equalTo(self.scrollView)
            make.trailing.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(36)
        }
        self.textView.delegate = self
        self.textView.placeholder = "随便说的什么吧"
        self.textView.font = UIFont.systemFont(ofSize: 18)
//        self.textView.placeholderFont = UIFont.systemFont(ofSize: 18)
        
        self.initNaviBtn()

    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        YHPrint("viewWillLayoutSubviews",self.textView.frame)
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        YHPrint("viewDidLayoutSubviews",self.textView.frame)
//    }
//    
//    override func updateViewConstraints() {
//        super.updateViewConstraints()
//        YHPrint("updateViewConstraints",self.textView.frame)
//
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        YHPrint("viewWillAppear",self.textView.frame)
//
//    }
    
    deinit {
        YHPrint("YHDynamicPublishController is deinitialzed")
    }
    
    func addImage() {
        
    }
    
}

extension UIView {
    func addDashedBorder() {
        let color = UIColor.gray.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height-1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 0.5
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = [4,2]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
}



