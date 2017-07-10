//
//  CellGroupSetting.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/15.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation


protocol CellGroupSettingDeleteDelegate :class{
    func onDelete()
}

class CellGroupSettingDelete:UITableViewCell{
    private var _btnDelete:UIButton!
    weak var delegate:CellGroupSettingDeleteDelegate?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        _btnDelete = UIButton()
        _btnDelete.layer.cornerRadius = 5
        _btnDelete.layer.masksToBounds = true
        _btnDelete.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        _btnDelete.backgroundColor  = kRedColor_Swift
        _btnDelete.setTitleColor(.white, for: .normal)
        _btnDelete.addTarget(self, action: #selector(_onDelete(sender:)), for: .touchUpInside)
        _btnDelete.setTitle("删除并退出", for: .normal)
        contentView.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        contentView.addSubview(_btnDelete)

        
        _btnDelete.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-15)
            make.top.equalTo(self.contentView)
            make.height.equalTo(60)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    @objc private func _onDelete(sender:Any){
        delegate?.onDelete()
    }
}

class CellGroupSetting:UITableViewCell{
    
    private var _lbLeft      :UILabel!
    private var _lbRight     :UILabel!
    private var _imgvRight   :UIImageView!
    private var _viewBotLine :UIView!
    
    var model:CellGroupSettingModel? {
        willSet(newValue){
            _lbLeft.text  = newValue?.title
            _lbRight.text = newValue?.content
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupUI(){
    
        _lbLeft = UILabel()
        _lbLeft.font  = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(_lbLeft)
    
        _lbRight      = UILabel()
        _lbRight.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(_lbRight)
    
        _viewBotLine = UIView()
        _viewBotLine.backgroundColor =  UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
        contentView.addSubview(_viewBotLine)

        _layoutUI()
    }
    
    private func _layoutUI(){
        
        _lbLeft.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        _lbRight.setContentHuggingPriority(249, for: .horizontal)
        _lbRight.setContentCompressionResistancePriority(749, for: .horizontal)

        _lbRight.snp.makeConstraints {  [unowned self](make) in
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
       
        _viewBotLine.snp.makeConstraints { [unowned self](make) in
            make.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView)
            make.height.equalTo(1)
        }
        

    }

}
