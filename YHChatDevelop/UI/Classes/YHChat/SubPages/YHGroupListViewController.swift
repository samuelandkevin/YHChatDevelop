//
//  YHGroupListViewController.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/7/20.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  讨论组列表

import Foundation

class YHGroupListViewController:UIViewController{
    
    fileprivate var _tableView:YHRefreshTableView!
    fileprivate var _dataArray:[YHChatGroupModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _dataArray = [YHChatGroupModel]()
        
        title = "讨论组"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        
        //tableView
        _tableView = YHRefreshTableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), style: .plain)
        _tableView.delegate   = self
        _tableView.dataSource = self
        _tableView.backgroundColor = kTbvBGColor_Swift
        _tableView.separatorStyle  = .none
        view.addSubview(_tableView)
        
        _tableView.rowHeight = 60.0
        _tableView.register(
            CellForChatGroup.classForCoder(), forCellReuseIdentifier: NSStringFromClass(CellForChatGroup.classForCoder()))
        _tableView.enableLoadNew = true
        //请求数据
        _requestGroupList(loadNew: true)
        
    }
    
    // MARK:- 网络请求
    fileprivate func _requestGroupList(loadNew:Bool){
        
        
        var refreshType:YHRefreshType
        if loadNew == true {
            refreshType = .loadNew;
            self._tableView.noMoreData = true
        }
        else{
            refreshType = .loadMore;
        }

        self._tableView.loadBegin(refreshType)
        
        NetManager.sharedInstance().getGroupChatListComplete { [weak self](success, obj) in
            if let weakSelf = self{
                weakSelf._tableView.loadFinish(refreshType)
                if let retObj = obj as?[YHChatGroupModel]{
                    if loadNew == true{
                        weakSelf._dataArray.removeAll()
                        weakSelf._dataArray = retObj
                        weakSelf._tableView.reloadData()
                    }
                    
                }
            }
            
        }
    }
    
    // MARK:- Action
    @objc fileprivate func onBack(sender:Any){
        navigationController?.popViewController(animated: true)
    }
    
    
}

// MARK:- UITableViewDataSource&UITableViewDelegate
extension YHGroupListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID1 =  NSStringFromClass(CellForChatGroup.classForCoder())
       
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID1) as? CellForChatGroup
        
        if cell == nil {
            cell = CellForChatGroup(style: .default, reuseIdentifier: cellID1)
        }
        cell?.isOnlyShowGroup = true
        if  _dataArray.count > indexPath.row{
            let model = _dataArray[indexPath.row]
            cell?.model = model
            cell?.indexPath = indexPath
            cell?.delegate  = self
        }
        
        return cell!
   
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

extension YHGroupListViewController:CellForChatGroupDelegate{

    func didSelectOneGroup(_ didSel: Bool, inCell cell: CellForChatGroup!) {
        
        if  let indexPath = cell.indexPath, _dataArray.count > indexPath.row{
            
            var token = ""
            if let aToken = YHUserInfoManager.sharedInstance().userInfo.accessToken {
                token = aToken
            }
            if token.isEmpty == true {
                return
            }
            
            let model = _dataArray[indexPath.row]
            guard let groupID  = model.groupID else{
                return
            }
            

            let groupTitle = model.groupName
            
            let path = YHProtocol.share().pathGroupChat + "/\(groupID)?accessToken=\(token)"
            let url = URL(string:path)
            DispatchQueue.main.async {
                
//                if let vc = YHChatVC(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), url: url, loadCache: false){
//                    vc.title = groupTitle
//                    vc.sessionID = groupID
//                    vc.pageType = 1
//                    vc.hidesBottomBarWhenPushed = true
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
                
            }
            
            
        }

    }
}

extension YHGroupListViewController:YHRefreshTableViewDelegate{
    
    func refreshTableViewLoadNew(_ view: YHRefreshTableView!) {
            _requestGroupList(loadNew: true)
    }
    
    func refreshTableViewLoadmore(_ view: YHRefreshTableView!) {
        
    }
}
