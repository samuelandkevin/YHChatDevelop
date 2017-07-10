//
//  YHQRCodeCardVC.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/16.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation
import Kingfisher

class YHQRCodeCardVC:UIViewController,YHPhotoBrowserViewDelegate{

    private var _userInfo:YHUserInfo?
    private var _widthQRCode = CGFloat(250)    //二维码名宽度
    //控件
    private var _viewHeader = UIView()         //顶部层
    private var _viewAvatarContainer = UIView()//头像容器
    private var _imgvAvatar = UIImageView()    //头像
    private var _labelNick  = UILabel()        //昵称
    private var _labelCompany = UILabel()      //公司
    private var _labelJob  = UILabel()         //职位
    private var _imgVQRCode = UIImageView()    //二维码
    private var _viewVerticalLine = UIView()
    private var _viewBotLine  = UIView()       //分隔线

    public convenience init(userInfo:YHUserInfo) {
        self.init()
        _userInfo   = userInfo
    }
    

    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "二维码名片"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        navigationController?.navigationBar.isTranslucent = false
        
        _setupUI()
        _setupQRCode()


    }
    
    
    deinit {
        debugPrint("YHQRCodeCardVC is deinit")
    }
    
    // MARK: - Action
    func onBack(sender:Any){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Gesture
    func onAvatar(aGes:UIGestureRecognizer){
        let browser = YHPhotoBrowserView()
        browser.currentImageView = _imgvAvatar
        browser.delegate = self;
        browser.show()
    }
    
    // MARK: - Private
    private func _setupUI(){
        
        _labelNick.font = UIFont.systemFont(ofSize: 18)
        _labelCompany.font = UIFont.systemFont(ofSize: 12)
        _labelCompany.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        _labelJob.font = UIFont.systemFont(ofSize: 12)
        _labelJob.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        _viewVerticalLine.backgroundColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        _viewBotLine.backgroundColor = UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
        
        view.backgroundColor = UIColor.white
        view.addSubview(_viewHeader)
        _viewHeader.addSubview(_viewAvatarContainer)
        _viewAvatarContainer.addSubview(_imgvAvatar)
        _viewHeader.addSubview(_labelNick)
        _viewHeader.addSubview(_labelCompany)
        _viewHeader.addSubview(_labelJob)
        _viewHeader.addSubview(_viewVerticalLine)
        _viewHeader.addSubview(_viewBotLine)
        view.addSubview(_imgVQRCode)
        _layoutUI()
        
        
        let gesture  = UITapGestureRecognizer(target: self, action: #selector(onAvatar(aGes:)))
        _imgvAvatar.addGestureRecognizer(gesture)
        _imgvAvatar.isUserInteractionEnabled = true;
        
        //头像
        _imgvAvatar.image = UIImage(named: "common_avatar_80px")
        _imgvAvatar.kf.setImage(with: _userInfo?.avatarUrl, placeholder: UIImage(named: "common_avatar_80px"), options: [.transition(ImageTransition.fade(1))] , progressBlock: { (_, _) in
            
        }) {[unowned self] (image, error, cacheType, imageURL) in
            if error == nil {
                self._userInfo?.avatarImage = image
                self._setupQRCode()
            }
        }
        
        if _userInfo?.userName.isEmpty == false {
            _labelNick.text = _userInfo?.userName
        }
        else{
            _labelNick.text = "匿名用户"
        }
        
        if _userInfo?.company.isEmpty == false{
            _labelCompany.text = _userInfo?.company
        }
        else{
            _labelCompany.text = "公司"
        }
        
        if _userInfo?.job.isEmpty == false{
            _labelJob.text = _userInfo?.job
        }
        else{
            _labelJob.text = "职位"
        }
        
        
        if (_userInfo?.company.isEmpty == true || _userInfo?.job.isEmpty == true){
            _viewVerticalLine.isHidden = true
        }
        else{
            _viewVerticalLine.isHidden = false
        }

    }
    
    private func _layoutUI(){
        
        
        _viewHeader.snp.makeConstraints { [unowned self] (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(89)
        }
        
       _viewAvatarContainer.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self._viewHeader).offset(10)
            make.top.equalTo(self._viewHeader).offset(14)
            make.size.equalTo(CGSize(width: 60, height: 60))
       }
        
        _imgvAvatar.snp.makeConstraints { [unowned self](make) in
            make.edges.equalTo(self._viewAvatarContainer)
        }
        
        _labelNick.snp.makeConstraints { [unowned self](make)  in
            make.right.lessThanOrEqualTo(self._viewHeader.snp.right)
            make.left.equalTo(self._viewAvatarContainer.snp.right).offset(10)
            make.bottom.equalTo(self._labelCompany.snp.top).offset(-12)
        }
        
        _labelCompany.snp.makeConstraints { [unowned self](make)  in
            make.left.equalTo(self._labelNick.snp.left)
            make.bottom.equalTo(self._viewHeader).offset(-23)
        }
        
        _viewVerticalLine.snp.makeConstraints { [unowned self](make)  in
            make.left.equalTo(self._labelCompany.snp.right).offset(5)
            make.size.equalTo(CGSize(width: 1, height: 10))
            make.centerY.equalTo(self._labelCompany.snp.centerY)
        }
        
        _labelJob.snp.makeConstraints { [unowned self](make)  in
            make.left.equalTo(self._viewVerticalLine.snp.right).offset(5)
            make.centerY.equalTo(self._viewVerticalLine.snp.centerY)
            make.right.lessThanOrEqualTo(self._viewHeader)
        }
    
        _viewBotLine.snp.makeConstraints { [unowned self](make)  in
            make.left.bottom.right.equalTo(self._viewHeader)
            make.height.equalTo(0.5)
        }
        
        _imgVQRCode.snp.makeConstraints { [unowned self](make)  in
            make.centerX.equalTo(self.view.centerX)
            make.top.equalTo(self._viewHeader.snp.bottom).offset(40)
            make.size.equalTo(CGSize(width: self._widthQRCode, height: self._widthQRCode))
        }
    }
    
    private func _setupQRCode(){
        //用于生成二维码的字符串source
        guard let aUserInfo = _userInfo,let uid = aUserInfo.uid else {
            return
        }
        let source = "taxtao_userId=" + uid
        
        //使用iOS 7后的CIFilter对象操作，生成二维码图片imgQRCode（会拉伸图片，比较模糊，效果不佳）
        guard let imgQRCode = QRCode.createQRCodeImage(source:source) else{
            return
        }
        //使用核心绘图框架CG（Core Graphics）对象操作，进一步针对大小生成二维码图片imgAdaptiveQRCode（图片大小适合，清晰，效果好）
        guard var imgAdaptiveQRCode = QRCode.resizeQRCodeImage(image: imgQRCode, size: _widthQRCode) else{
            return
        }

        //默认产生的黑白色的二维码图片；我们可以让它产生其它颜色的二维码图片，例如：蓝白色的二维码图片
        
        guard let imgSepCreated = OCtoSwiftUtil.specialColorImage(imgAdaptiveQRCode, withRed: 0, green: 0, blue: 0) else{
            return
        }
        imgAdaptiveQRCode = imgSepCreated

        //使用核心绘图框架CG（Core Graphics）对象操作，创建带圆角效果的图片
        guard let imgIcon = UIImage.createRoundedRectImage(_userInfo?.avatarImage, with: CGSize(width: 50, height: 50), withRadius: 10) else{
            return
        }
   
        //使用核心绘图框架CG（Core Graphics）对象操作，合并二维码图片和用于中间显示的图标图片
        guard let imgCombine = QRCode.addIconToQRCodeImage(image: imgAdaptiveQRCode, icon: imgIcon, iconSize: imgIcon.size)else{
            return
        }
        imgAdaptiveQRCode = imgCombine
       
        

        //    imgAdaptiveQRCode = [KMQRCode addIconToQRCodeImage:imgAdaptiveQRCode
        //                                              withIcon:imgIcon
        //                                             withScale:3];

        _imgVQRCode.image             = imgAdaptiveQRCode
        _imgVQRCode.layer.borderColor = UIColor.init(colorLiteralRed: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0).cgColor
        _imgVQRCode.layer.borderWidth = 1
    }
    
    // MARK: - YHPhotoBrowserViewDelegate
    func photoBrowser(_ browser: YHPhotoBrowserView!, highQualityImageURLFor index: Int) -> URL! {
        
        let thumbUrlStr = _userInfo?.avatarUrl.absoluteString
        guard let oriUrlStr = thumbUrlStr?.replacingOccurrences(of: "!m90x90.png", with: "")else{
            return URL(string: "")
        }
        let oriUrl = URL(string: oriUrlStr)
        return oriUrl
    }
    
    func photoBrowser(_ browser: YHPhotoBrowserView!, placeholderImageFor index: Int) -> UIImage! {
        return _userInfo?.avatarImage
    }
    
    

}
