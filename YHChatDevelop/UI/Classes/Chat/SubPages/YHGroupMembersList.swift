//
//  YHGroupMembersList.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/16.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  群成员列表

import Foundation
import Kingfisher
class CellGroupMemList:UITableViewCell{
    
    fileprivate var _imgvAvatar:UIImageView!
    fileprivate var _lbName:UILabel!
    fileprivate var _viewBotLine:UIView!
    
    var model:YHGroupMember? {
        willSet(newValue){
            _imgvAvatar.kf.setImage(with: URL(string:(newValue?.avtarUrl)!), placeholder: UIImage(named: "common_avatar_80px"), options: nil, progressBlock: nil, completionHandler: nil)
            _lbName.text = newValue?.userName
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        _initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _initUI(){
        
        _imgvAvatar = UIImageView()
        contentView.addSubview(_imgvAvatar)
        
        _lbName = UILabel()
        _lbName.textColor = .black
        _lbName.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(_lbName)
        
        _viewBotLine = UIView()
        _viewBotLine.backgroundColor = kSeparatorLineColor_Swift
        contentView.addSubview(_viewBotLine)
        
        _layoutUI()
    }
    
    private func _layoutUI(){
        
        _imgvAvatar.snp.makeConstraints { [unowned self](make) in
            make.width.height.equalTo(45)
            make.left.equalTo(self.contentView).offset(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        _lbName.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self._imgvAvatar.snp.right).offset(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.right.lessThanOrEqualTo(self.contentView).offset(-15)
        }
        
        _viewBotLine.snp.makeConstraints { [unowned self](make) in
            make.height.equalTo(1)
            make.right.bottom.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(15)
        }
    }
}

class YHGroupMembersList:UIViewController{
    
    //控件
    fileprivate var _tableView:YHRefreshTableView!
    var dataArray:[YHGroupMember] = []
    var groupID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _initUI()
        
    }
    
    private func _initUI(){
        title = "全部组成员"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        
        //导航栏
        navigationController?.navigationBar.isTranslucent = false
        
        //tableView
        _tableView = YHRefreshTableView(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), style: .plain)
        _tableView.delegate   = self
        _tableView.dataSource = self
        
    
        _tableView.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        _tableView.separatorStyle  = .none
        _tableView.register(CellGroupMemList.classForCoder(), forCellReuseIdentifier: CellGroupMemList.className())
        view.addSubview(_tableView)
        

    }
    
    // MARK: - Private
    @objc func onBack(sender:Any){
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - 网络请求
    fileprivate func _requestGroupMembers(){
        NetManager.sharedInstance().getGroupMemebers(withGroupID: groupID) { [unowned self](success:Bool, obj:Any) in
            if success{
                if let arr = obj as? [YHGroupMember],arr.count > 0 {
                    self.dataArray = arr
                    self._tableView.reloadData()
                }
            }else{
                
            }
        }
    }


}

extension YHGroupMembersList:UITableViewDelegate,UITableViewDataSource{
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CellGroupMemList.className()) as? CellGroupMemList
        if cell == nil{
            cell = CellGroupMemList(style: .default, reuseIdentifier: CellGroupMemList.className())
        }
        if dataArray.count > indexPath.item {
           let model = dataArray[indexPath.item]
           cell?.model = model
        }
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < dataArray.count {
            let model = dataArray[indexPath.row]
//            if let vc = CardDetailViewController(userId: model.userID){
//                vc.hidesBottomBarWhenPushed = true
//                navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    

}
