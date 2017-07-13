//
//  CellForCard.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/3/6.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation
import HYBMasonryAutoCellHeight

public class CellForCard:UITableViewCell {
    
    open var labeLeftTitle = UILabel()//左标题
    open var labelContent  = UILabel() //标题内容

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI(){
        labeLeftTitle.text = "个人简介"
//        labeLeftTitle.backgroundColor = .red
        labeLeftTitle.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(labeLeftTitle)
        
        labelContent.preferredMaxLayoutWidth = ScreenWidth - 17 - 66 - 23 - 10
//        labelContent.backgroundColor = .green
        labelContent.textAlignment = .left
        labelContent.numberOfLines = 0
        labelContent.font = UIFont.systemFont(ofSize: 12)
        labelContent.textColor = UIColor.colorWithHexString(hex: "#606060")
        contentView.addSubview(labelContent)
        
        layoutUI()
    }
    
    fileprivate func layoutUI(){
        labeLeftTitle.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.contentView.snp.left).offset(17)
            make.width.greaterThanOrEqualTo(66)
            make.top.equalTo(self.contentView.snp.top).offset(17)
        }
        
        labelContent.setContentHuggingPriority(249, for: .horizontal)
        labelContent.setContentCompressionResistancePriority(749, for: .horizontal)
        labelContent.snp.makeConstraints  {  [unowned self](make) in
            
            make.left.equalTo(self.labeLeftTitle.snp.right).offset(23)
            make.top.equalTo(self.contentView.snp.top).offset(17)
            make.right.equalTo(self.contentView.snp.right).offset(-10)
        }
        
        self.hyb_lastViewInCell = labelContent
        self.hyb_bottomOffsetToCell = 17
    }
}
