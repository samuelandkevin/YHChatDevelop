//
//  CellForBase1.swift
//  PikeWay
//
//  Created by YHIOS002 on 17/3/6.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation




class  CellForBase1:UITableViewCell{
    
    private var imgvIcon = UIImageView()
    private var labelTitle = UILabel()
    private var imgvArrow = UIImageView()
    private var viewBotLine = UIView()
    open var dictData:Dictionary<String,Any> = ["":""]{
        
        didSet{
            if let image = dictData["icon"] as? String {
                imgvIcon.image = UIImage(named: image)
            }
            if let title = dictData["title"] as? String{
                labelTitle.text = title
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI(){
    
        //
        contentView.addSubview(imgvIcon)
        
        //
        labelTitle.font = UIFont.systemFont(ofSize: 16.0)
        labelTitle.textColor = UIColor.black
        contentView.addSubview(labelTitle)
        
        //箭头
        imgvArrow.image = UIImage(named: "rightbigarrow")
        contentView.addSubview(imgvArrow)
        
        //底线
        viewBotLine.backgroundColor = kSeparatorLineColor_Swift
        contentView.addSubview(viewBotLine)
        
        layoutUI()

        
    }
    
    fileprivate func layoutUI(){
        
        imgvIcon.snp.makeConstraints { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 21, height: 21))
            make.left.equalTo(self.contentView.snp.left).offset(10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
       
        labelTitle.snp.makeConstraints {  [unowned self] (make) in
            make.left.equalTo(self.imgvIcon.snp.right).offset(10)
            make.centerY.equalTo(self.imgvIcon.snp.centerY)
            make.width.greaterThanOrEqualTo(60)
            
        }
        
        imgvArrow.snp.makeConstraints( {[unowned self] (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.right.equalTo(self.contentView.snp.right).offset(-10)
        })
        
        
        viewBotLine.snp.makeConstraints { [unowned self] (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.left.right.bottom.equalTo(self.contentView)
        }

    }
    
    
    
}

