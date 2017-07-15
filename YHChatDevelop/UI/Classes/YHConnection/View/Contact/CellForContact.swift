//
//  CellForContact.swift
//  PikeWay
//
//  Created by YHIOS002 on 17/3/6.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation

public class CellForContact:YHCellWave {
   
    open var viewBotLine = UIView()
    open var dict:[String:String] = ["":""]{
        didSet{
            let title =  dict["title"]
            labelTitle.text = title
            if let icon  =  dict["icon"]{
                imgvIcon.image = UIImage(named: icon)
            }
            
        }
    }
    open var imgvIcon = UIImageView()
    open var labelTitle = UILabel()
    open var labelCount = UILabel()
    private let imgvRightArrow = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI(){
        //icon
        imgvIcon.image = UIImage(named: "common_avatar_80px")
        contentView.addSubview(imgvIcon)
        
        //标题
        labelTitle.textColor = .black
        labelTitle.font = UIFont.systemFont(ofSize: 16.0)
        contentView.addSubview(labelTitle)
        
        //数量
        labelCount.layer.cornerRadius = 9
        labelCount.layer.masksToBounds = true
        labelCount.textColor = .white
        labelCount.textAlignment = .center
        labelCount.font = UIFont.systemFont(ofSize: 12.0)
        labelCount.isHidden = true
        labelCount.backgroundColor = .red
        contentView.addSubview(labelCount)
        
        //箭头
        imgvRightArrow.image = UIImage(named: "rightbigarrow")
        contentView.addSubview(imgvRightArrow)
        
        //底线
        viewBotLine.backgroundColor = kSeparatorLineColor_Swift
        contentView.addSubview(viewBotLine)
        
        layoutUI()
    }
    
    fileprivate func layoutUI(){
        imgvIcon.snp.makeConstraints {  [unowned self](make) in
            make.left.equalTo(self.contentView.snp.left).offset(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        labelTitle.setContentHuggingPriority(249, for: .horizontal)
        labelTitle.setContentCompressionResistancePriority(749, for: .horizontal)
        
        labelTitle.snp.makeConstraints{ [unowned self](make) in
            make.left.equalTo(self.imgvIcon.snp.right).offset(10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
       
        labelCount.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.labelTitle.snp.right).offset(10)
            make.size.greaterThanOrEqualTo(CGSize(width: 18, height: 18))
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.right.greaterThanOrEqualTo(self.imgvIcon.snp.left)
        }
        
        imgvRightArrow.snp.makeConstraints { [unowned self](make) in
            make.right.equalTo(self.contentView.snp.right).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        viewBotLine.snp.makeConstraints { [unowned self] (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.left.right.bottom.equalTo(self.contentView)
        }
        
    }
    
    //设置未读数量
    public func setBadge(with count:Int){
        labelCount.text = String(count)
        labelCount.isHidden = count > 0 ? false:true
    }
    
    
}
