//
//  MyControllerHeaderCell.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by YHIOS003 on 2017/5/5.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import UIKit
import SnapKit

class MyControllerHeaderCell: YHCellWave,Reusable {

    lazy var avatar: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "common_avatar_80px")
        return iv
    }()
    
    lazy var name: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 18)
        lab.textColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        return lab
    }()

    lazy var company: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1)
        return lab
    }()
    
    lazy var position: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1)
        return lab
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        return v
    }()
    
    lazy var arrow: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rightbigarrow")
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        addSubview(avatar)
        addSubview(name)
        addSubview(company)
        addSubview(position)
        addSubview(separator)
        addSubview(arrow)
        
        separator.isHidden = true
        
        snap()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fillValue(with name: String, and company: String, and position: String){
        
        if(name.characters.count > 0){
            self.name.text = name
        }else{
            self.name.text = "姓名"
        }
        
        if(company.characters.count > 0){
            self.company.text = company
        }else{
            self.company.text = "公司"
        }
        
        if(position.characters.count > 0){
            self.position.text = position
        }else{
            self.position.text = "职位"
        }
        
        if(company.characters.count > 0 && position.characters.count > 0){
            self.separator.isHidden = false
        }else{
            self.separator.isHidden = true
        }
        
    }

    func snap(){
        avatar.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.height.width.equalTo(60)
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(16)
        }
        
        name.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.left.equalTo(self.avatar.snp.right).offset(13)
            make.bottom.equalTo(self.snp.centerY).offset(-5)
            make.right.equalTo(self.arrow.snp.left).offset(-10)
        }
        name.setContentCompressionResistancePriority(249, for: .horizontal)
        
        company.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.left.equalTo(self.name)
            make.top.equalTo(self.snp.centerY).offset(5)
        }
        
        company.setContentHuggingPriority(751, for: .horizontal)
        company.setContentCompressionResistancePriority(249, for: .horizontal)
        
        separator.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.centerY.equalTo(self.company)
            make.left.equalTo(self.company.snp.right).offset(3)
            make.width.equalTo(1)
            make.height.equalTo(12)
        }
        
        position.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.left.equalTo(self.separator.snp.right).offset(3)
            make.right.equalTo(self.arrow.snp.left).offset(-10)
            make.centerY.equalTo(self.company)
        }
        
        arrow.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.width.height.equalTo(18)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-15)
        }
        
    }
    
}
