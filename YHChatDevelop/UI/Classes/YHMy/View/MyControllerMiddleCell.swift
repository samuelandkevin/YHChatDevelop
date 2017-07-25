//
//  AccountAvatarCell.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/4/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import UIKit

class MyControllerMiddleCell: YHCellWave, Reusable  {
    
    private lazy var leftImageV: UIImageView = {
        let imageV = UIImageView()
        return imageV
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(white: 0.188, alpha: 1.0)
        return lab
    }()
    
    private lazy var rightImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(named: "rightbigarrow")
        return imageV
    }()
    
    private lazy var viewBotLine: UIView = {
        let aView = UIView()
        aView.backgroundColor = kSeparatorLineColor_Swift
        return aView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        addSubview(leftImageV)
        addSubview(titleLab)
        addSubview(rightImageV)
        addSubview(viewBotLine)
        snap()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func fillValue(with image: UIImage, and title: String){
        leftImageV.image = image
        titleLab.text = title
    }
    
    private func snap(){
        self.leftImageV.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.left.equalTo(self).offset(14)
            make.centerY.equalTo(self);
            make.width.height.equalTo(21)
        }
        
        self.titleLab.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.left.equalTo(self.leftImageV.snp.right).offset(7)
            make.centerY.equalTo(self)
            make.right.equalTo(self.rightImageV).offset(-10)
            make.height.equalTo(self.leftImageV)
        }
        
        self.rightImageV.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.right.equalTo(self).offset(-15)
            make.centerY.equalTo(self)
            make.height.width.equalTo(18)
        }
        
        self.viewBotLine.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.bottom.equalTo(self);
            make.left.right.equalTo(self);
            make.height.equalTo(0.5)
        }
    }
    
}
