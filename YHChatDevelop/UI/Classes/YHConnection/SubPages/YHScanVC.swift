//
//  YHScanVC.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/16.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation
import AVFoundation


class YHScanVC:UIViewController,AVCaptureMetadataOutputObjectsDelegate{

    //控件
    private var _scanView   = YHScanArea()
    
    private var _viewScanBg = UIView()
    
    //数据
    private var _session  = AVCaptureSession()
    //扫描区域的宽高
    private let kScanW:CGFloat = 218
    private let kScanH:CGFloat = 218
   
    
    // MARK: - Life
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _scanView.closeTimer()
    }
    
    deinit {
        YHPrint("YHScanVC is deinit")
        _scanView.closeTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(resumeScan), name: NSNotification.Name(rawValue:"event.scanResume"), object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(closePage), name: NSNotification.Name(rawValue: "event.closeScanPage"), object: nil)
  
        self.title = "扫一扫"
        

        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        
        let aRect        = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64)
        _viewScanBg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        _viewScanBg.frame = aRect
        view.addSubview(_viewScanBg)
        
        //半透明背景
        let bgRect = CGRect(x: 0, y: 0, width: aRect.width, height: aRect.height)
        
        
        //扫描区域
        let scanRect = CGRect(x: (bgRect.size.width - kScanW)/2, y: (bgRect.size.height - kScanH)/2, width: kScanW, height: kScanH)
        
        _scanView = YHScanArea(frame: scanRect)
        _viewScanBg.addSubview(_scanView)
        
        let bgView = YHScanBG(frame: bgRect, scanW: kScanW, scanH: kScanH)
        _viewScanBg.addSubview(bgView)
        
        
        //二维码放入框内,即可自动扫描
        let label = UILabel(frame: CGRect(x: 0, y: _scanView.frame.maxY+20, width: ScreenWidth, height: 20))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = "二维码放入框内,即可自动扫描"
        _viewScanBg.addSubview(label)
        
        //开始扫描
        _scanView.startAnimaion()
        _ = _startReading()
        
        
    }
    
    // MARK: - Notification
    func resumeScan(){
        _scanView.startAnimaion()
        _session.startRunning()
    }
    
    func closePage(){
        if let count = navigationController?.viewControllers.count ,count > 2 , let vc = navigationController?.viewControllers[1]  {
            navigationController?.popToViewController(vc, animated: true)
        }else{
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Action
    func onBack(sender:Any){
        if let count = navigationController?.viewControllers.count ,count > 2 , let vc = navigationController?.viewControllers[1]  {
            navigationController?.popToViewController(vc, animated: true)
        }else if let count = navigationController?.viewControllers.count ,count == 2{
            navigationController?.popToRootViewController(animated: true)
        }else{
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Private Method
    func _startReading() -> Bool{
        if checkVideoGranted() == false{
            return false
        }
        
        
     
        //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input:AVCaptureDeviceInput
        //2.用captureDevice创建输入流
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }catch{
            debugPrint(error.localizedDescription)
            return false
        }
     
        
        //创建输出流
        let output = AVCaptureMetadataOutput()
        
        //设置代理 在主线程里刷新
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //设置识别区域
        //深坑，这个值是按比例0~1设置，而且X、Y要调换位置，width、height调换位置
        let bgW = _viewScanBg.bounds.size.width
        let bgH = _viewScanBg.bounds.size.height
        
        let a =  _scanView.frame.origin.y/bgH
        let b =  _scanView.frame.origin.x/bgW
        let c =  _scanView.bounds.size.height/bgH
        let d =  _scanView.bounds.size.width/bgW
        
        output.rectOfInterest = CGRect(x: a, y: b, width: c, height: d)
        
        //初始化链接对象
        _session = AVCaptureSession()
        
        //高质量采集率
        _session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        
        _session.addInput(input)
        _session.addOutput(output)

        
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]

        
        guard let layer = AVCaptureVideoPreviewLayer(session: _session)     else{
            return false
        }
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = _viewScanBg.frame
        view.layer.insertSublayer(layer, at: 0)
       
        
        //开始捕获
        _session.startRunning()
        
        return true
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        
        
        if metadataObjects.count > 0 {
            
            _session.stopRunning()   //停止扫描
            _scanView.stopAnimaion() //暂停动画
            //AVMetadataMachineReadableCodeObject
            guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else{
                return
            }
            
            //输出扫描字符串(扫描的结果格式： taxtao_userId=？？？ )（？？？是代表uid）
            debugPrint("输出扫描字符串:\(metadataObject.stringValue)")
            guard var scanResult = metadataObject.stringValue else{
                return
            }
            
            //扫名片
            if scanResult.isEmpty == false && scanResult.hasPrefix("taxtao_userId=") == true {
                
                let fromIndex  = scanResult.index(scanResult.startIndex, offsetBy: 14)
                
                let targertUid = scanResult.substring(from: fromIndex)
               
                
                NetManager.sharedInstance().getVisitCardDetail(withTargetUid: targertUid, complete: { [unowned(unsafe) self](success:Bool, obj:Any) in
                    if success {
                        debugPrint("访问陌生人/好友名片详情成功\(obj)")
                        guard let aUserInfo = obj as? YHUserInfo,let vc = CardDetailViewController(userInfo: aUserInfo) else {
                            return
                        }
                        vc.isFromScanVC = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                    
                        if let errorDict = obj as? Dictionary<String,Any> {
                            
                            //服务器返回的错误描述
                            let msg  = errorDict[kRetMsg_Swift]
                            
                            postTips(msg, "获取名片详情失败")
                          
                        }else{
                            //AFN请求失败的错误描述
                            postTips(obj, "获取名片详情失败")
                        }
                    }
                })
                
        
            }
            //微信网页登录
            else if  scanResult.isEmpty == false &&
                scanResult.hasPrefix("sd://chat/") == true {
           
                debugPrint(scanResult)
                let preStr = "sd://chat/"
                let QRCodeId = scanResult.replacingOccurrences(of: preStr, with: "")

                let vc = YHLoginByWebVC()
                vc.QRCodeId = QRCodeId
                self.present(vc, animated: true, completion: nil)
                
            }
            else
            {
                //其他结果
                if scanResult.isEmpty == true {
                    scanResult = ""
                }
                
                let vc = YHScanResultVC(reusltData: [scanResult])
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
    
}
