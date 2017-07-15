//
//  CellForAB.swift
//  PikeWay
//
//  Created by YHIOS002 on 17/3/6.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation


@objc protocol CellForABDelegate :class {
    func onBtnInvitedInCell(_ with:CellForAB)
}

extension CellForABDelegate {
    public func onBtnInvitedInCell(_ with:CellForAB){
    
    }
}

public class CellForAB: UITableViewCell {
    

    open var userInfo:YHABUserInfo = YHABUserInfo() {
        willSet(newValue){
            setModel(with: newValue)
        }
    }

    weak var delegate:CellForABDelegate?
    open var indexPath:IndexPath? = nil
    private var labelName = UILabel()
    private var labelPhoneNum = UILabel()
    private var btnInvited = UIButton()
    private var imgvAvatar = UIImageView()
    private var viewBotLine = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI(){
        
        //头像
//        imgvAvatar.layer.cornerRadius = 22.5;
//        imgvAvatar.layer.masksToBounds = true;
        imgvAvatar.image = UIImage(named: "common_avatar_80px")
        contentView.addSubview(imgvAvatar)
        
        //昵称
        labelName.text = "匿名用户"
        labelName.font = UIFont.systemFont(ofSize: 16.0)
        labelName.textColor = UIColor.black
        contentView.addSubview(labelName)
        
        //手机
        labelPhoneNum.textColor = UIColor(red: 96/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        labelPhoneNum.font = UIFont.systemFont(ofSize: 14.0)
        contentView.addSubview(labelPhoneNum)
        
        //邀请按钮
        btnInvited.setTitleColor(.white, for: .normal)
        btnInvited.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnInvited.backgroundColor = kBlueColor_Swift
        btnInvited.addTarget(self, action: #selector(onBtnInvited(sender:)), for: .touchUpInside)
        contentView.addSubview(btnInvited)
        
        //底线
        viewBotLine.backgroundColor = kSeparatorLineColor_Swift
        contentView.addSubview(viewBotLine)
        
        layoutUI()
        
    }
    
    fileprivate func layoutUI(){
        
//        imgvAvatar.layer.cornerRadius = 45/2;
//        imgvAvatar.layer.masksToBounds = true;
        
        imgvAvatar.snp.makeConstraints { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 45, height: 45))
            make.left.equalTo(self.contentView.snp.left).offset(10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        labelName.setContentHuggingPriority(249, for: .horizontal)
        labelName.setContentCompressionResistancePriority(749, for: .horizontal)
        labelName.snp.makeConstraints {  [unowned self] (make) in
            make.left.equalTo(self.imgvAvatar.snp.right).offset(10)
            make.centerY.equalTo(self.imgvAvatar.snp.centerY)
            make.width.greaterThanOrEqualTo(60)
            
        }
        
        labelPhoneNum.snp.makeConstraints( {[unowned self] (make) in
            make.left.equalTo(self.labelName.snp.right).offset(10)
            make.centerY.equalTo(self.labelName.snp.centerY)
            make.right.equalTo(self.btnInvited.snp.left).offset(-5)
        })
        
        
        btnInvited.layer.cornerRadius = 3;
        btnInvited.layer.masksToBounds = true;
        btnInvited.snp.makeConstraints({[unowned self] (make) in
            make.size.equalTo(CGSize(width: 50, height: 30))
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.right.equalTo(self.contentView.snp.right).offset(-5)
        })
        
        viewBotLine.snp.makeConstraints { [unowned self] (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.left.right.bottom.equalTo(self.contentView)
        }
    }
    
    
    fileprivate func setModel(with newValue:YHABUserInfo){
        labelName.text     = newValue.userName;
        labelPhoneNum.text = newValue.mobilephone;
        if  YHUserInfoManager.sharedInstance().userInfo.mobilephone == newValue.mobilephone {
            btnInvited.isHidden = true
        }else{
            btnInvited.isHidden = false
        }
        
        if newValue.isRegister == true{
            //已注册
            
            if newValue.relation == nil {
                //至今没有申请过加好友
                btnInvited.setTitle("添加", for: .normal)
                btnInvited.isEnabled = true
                btnInvited.backgroundColor = kBlueColor_Swift
                
            }else{
                
                guard let aRelation = newValue.relation,let relation = Int(aRelation) else{return}
                
                switch (relation)
                {
                case 0:
                    
                    //不是好友关系
                    
                    //判断加好友状态
                    if newValue.addFriStatus == nil{
                        
                        btnInvited.setTitle("添加", for: .normal)
                        btnInvited.isEnabled = true
                        btnInvited.backgroundColor = kBlueColor_Swift
                    }
                    else{
                        guard let aStatus = newValue.addFriStatus ,let addStatus = Int(aStatus) else {return}
                        switch (addStatus)
                        {
                        case 0:
                            
                            //对方添加我为好友
                            btnInvited.setTitle("待验证", for: .normal)
                            btnInvited.isEnabled = true
                            btnInvited.backgroundColor = kBlueColor_Swift
                            
                            
                            break
                        case 1:
                            
                            //已申请加好友,等待对方通过验证
                            
                            btnInvited.setTitle("已申请", for: .normal)
                            btnInvited.isEnabled = false
                            btnInvited.backgroundColor = UIColor.clear
                            btnInvited.setTitleColor(UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0), for: .normal)
                            
                            break
                        default:
                            break
                        }
                    }
                    
                    break
                case 1:
                    
                    //已经是好友关系
                    btnInvited.setTitle("已添加", for: .normal)
                    btnInvited.isEnabled = false
                    btnInvited.backgroundColor = UIColor.clear
                    btnInvited.setTitleColor(UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0), for: .normal)
                    
                    break
                default:
                    break;
                }
            }
        }else{
            
            //未注册
            btnInvited.setTitle("邀请", for: .normal)
            btnInvited.isEnabled = true
            btnInvited.backgroundColor = kBlueColor_Swift
            
        }
        

    }

    func onBtnInvited(sender:UIButton){

        delegate?.onBtnInvitedInCell(self)
        
    }
    

    open func resetCell(){
        btnInvited.setTitleColor(.white, for: .normal)
        btnInvited.isEnabled = true;
        btnInvited.backgroundColor = kBlueColor_Swift;
    }

}


