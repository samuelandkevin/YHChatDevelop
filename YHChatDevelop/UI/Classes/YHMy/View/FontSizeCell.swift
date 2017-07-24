//
//  FontSizeCell.swift
//  PikeWay
//
//  Created by YHIOS003 on 16/8/9.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit


class FontSizeCell: UITableViewCell {
    
    let title = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.title)
        
        self.title.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
        }
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.871, alpha: 1)
//        self.selectedBackgroundView = view
        
        
        self.layer.borderColor = UIColor(white: 0.871, alpha: 1).cgColor
        self.layer.borderWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        YHPrint(NSStringFromClass(self.classForCoder),"is deinitialized")
    }
    
}
