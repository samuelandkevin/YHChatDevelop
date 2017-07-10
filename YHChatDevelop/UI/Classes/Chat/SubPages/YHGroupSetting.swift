//
//  YHGroupSetting.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/15.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  群设置

import Foundation

struct CellGroupSettingModel {
    var title:String?
    var content:String?
}

struct CellGroupSettingMembersModel{
    var model:YHGroupMember?
    var isBtnAdd    = false
    var isBtnRemove = false
}



class YHGroupSetting:UIViewController{
    
    //控件
    fileprivate var _tableView:YHRefreshTableView!
    fileprivate var _cellDelete:CellGroupSettingDelete!
    fileprivate var _cellGroupMembers:CellGroupSettingMembers!
    
    //data
    fileprivate var _dataArraySection0:[CellGroupSettingMembersModel]?
    fileprivate var _dataArraySection1:[CellGroupSettingModel]?
    fileprivate var _dataArrayGroupMembers:[YHGroupMember]?  //全部群成员
    fileprivate var _groupName:String?    //群名称
    fileprivate var _myNameInGroup:String?//我在本群的名字
    fileprivate var _isGroupOwner = false //是否群主
    
    //collectionView高度
    fileprivate let kMagin:CGFloat = 10
    fileprivate var itemWidth:CGFloat = 0
    fileprivate var itemHeight:CGFloat = 0
    fileprivate var _collectionViewH:CGFloat = 0
    
    //群ID
    var groupID:String = ""
    var model:YHChatListModel?
    
    // MARK: - Life
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //数据初始化
        itemWidth  = (ScreenWidth - 5 * kMagin)/4
        itemHeight = itemWidth + 30
        _dataArraySection0 = []
        _dataArraySection1 = []
        _dataArrayGroupMembers = []
        
        //section1数据
        let titleArr = ["全部组成员","讨论组名称","我在本组的名称","查看聊天记录","投诉"]
        for title in titleArr {
            var model = CellGroupSettingModel()
            model.title = title
            _dataArraySection1?.append(model)
        }
       
        _initUI()
        
        _requestGroupInfo()
        _requestGroupMembers()
        NotificationCenter.default.addObserver(self, selector: #selector(_refresh(aNotifi:)), name: NSNotification.Name.init(rawValue: kNotif_GroupSettingPage_Refresh_Swift), object: nil)
    }
    
    // MARK: - init
    private func _initUI(){
        title = "讨论组设置"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        
        //导航栏
        navigationController?.navigationBar.isTranslucent = false
        
        //tableView
        _tableView = YHRefreshTableView(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), style: .grouped)
        _tableView.delegate   = self
        _tableView.dataSource = self
        
        _tableView.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        _tableView.separatorStyle  = .none
        _tableView.register(CellGroupSetting.classForCoder(), forCellReuseIdentifier: CellGroupSetting.className())
        view.addSubview(_tableView)
        
        //会员头像Cell
        _cellGroupMembers = CellGroupSettingMembers(style: .default, reuseIdentifier: CellGroupSettingMembers.className())
        _cellGroupMembers.delegate = self
        
        //删除并退出Cell
        _cellDelete = CellGroupSettingDelete(style: .default, reuseIdentifier: CellGroupSettingDelete.className())
        _cellDelete.delegate = self
    }
    
    // MARK: - Private
    @objc func onBack(sender:Any){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Notification
    @objc fileprivate func _refresh(aNotifi:Notification){
        _requestGroupInfo()
        _requestGroupMembers()
    }
    
    // MARK: - 网络请求
    //获取群信息
    fileprivate func _requestGroupInfo(){
        NetManager.sharedInstance().postFetchGroupInfo(withGroupID: groupID) {[unowned self] (success:Bool, obj:Any) in
            if success{
                YHPrint("获取群信息成功\(obj)")
                
                guard let groupInfo = obj as? YHGroupInfo else{
                    return
                }
                
                self._dataArraySection0?.removeAll()
                
                //本机用户是否为群主
                self._isGroupOwner = YHUserInfoManager.sharedInstance().userInfo.uid == groupInfo.createdID ? true : false
                
               

                //设置讨论组名称
                self._groupName = groupInfo.groupName
                
                
                //创建CellGroupSettingMembersModel
                for aMem in groupInfo.members {
                    var model = CellGroupSettingMembersModel()
                    model.model = aMem
                    model.isBtnAdd = false
                    model.isBtnRemove = false
                    self._dataArraySection0?.append(model)
            
                }
                
                //添加“+”
                var model = CellGroupSettingMembersModel()
                model.model = nil
                model.isBtnAdd = true
                model.isBtnRemove = false
                self._dataArraySection0?.append(model)
                
                
                //添加“-”
                if self._isGroupOwner == true{
                    var model  = CellGroupSettingMembersModel()
                    model.model    = nil
                    model.isBtnAdd = false
                    model.isBtnRemove = true
                    self._dataArraySection0?.append(model)
                }
                
                self._cellGroupMembers.dataArray = self._dataArraySection0
                
                
                //计算CollectionView高度
                if let totalNum = self._dataArraySection0?.count{
                    var rowCount:CGFloat = 0
                    if totalNum/4 == 0 {
                        rowCount = 1
                    }else{
                        let delta = totalNum%4 == 0 ? 0:1
                        rowCount = CGFloat(totalNum/4) + CGFloat(delta)
                        YHPrint(delta)
                    }
                    
                    self._collectionViewH = self.kMagin + (rowCount-1)*self.kMagin + rowCount*self.itemHeight + self.kMagin
                    
                    YHPrint(totalNum,rowCount,self._collectionViewH)
                }
                
                self._tableView.reloadData()
                
                
            }else{
                YHPrint("获取群信息失败\(obj)")
            }
        }
    }
    
    
    //获取全部群成员
    fileprivate func _requestGroupMembers(){
        NetManager.sharedInstance().getGroupMemebers(withGroupID: groupID) { [unowned self](success:Bool, obj:Any) in
            if success{
                if let arr = obj as? [YHGroupMember],arr.count > 0 {
                    self._dataArrayGroupMembers    = arr
                    
                    for aMem in arr{
                        if aMem.userID == YHUserInfoManager.sharedInstance().userInfo.uid {
                            //我在本群的名称
                            self._myNameInGroup = aMem.userName
                            break
                        }
                    }
                    self._tableView.reloadData()
                }
            }else{
            
            }
        }
    }
    
    //修改群名称
    fileprivate func _requestModifyGroupName(newGroupName:String!){
        NetManager.sharedInstance().postModifyGroupName(withGroupID: groupID, newGroupName: newGroupName) { [unowned self](success:Bool, obj:Any) in
            if success{
                YHPrint("修改群名称成功")
                self._groupName = newGroupName
                self._tableView.reloadData()
            }else{
                YHPrint("修改群名称失败")
                postTips(obj, "修改群名称失败")
            }
        }
    }
    
    //修改我在本组的名称
    fileprivate func _requestModifyMyNameInGroup(newName:String!){
        NetManager.sharedInstance().postModiftyMyNameInGroup(withGroupID: groupID, newName: newName) { [unowned self](success:Bool, obj:Any) in
            if success{
                YHPrint("修改我在本组的名称成功\(obj)")
                self._myNameInGroup = newName
                self._requestGroupInfo()
                self._tableView.reloadData()
            }else{
                 YHPrint("修改我在本组的名称失败\(obj)")
                 postTips(obj, "修改我在本组的名称失败")
            }
        }
    }
    
    //转让群
    fileprivate func _requestTransferGroupOwner(){
      
        var token = ""
        if let aToken = YHUserInfoManager.sharedInstance().userInfo.accessToken {
            token = aToken
        }
        
        var path = YHProtocol.share().pathTransferGroupOwnerWeb
        path = path + "\(groupID)?accessToken=\(token)&transfer=1"
        let url = URL(string: path)
        DispatchQueue.main.async {
            if let vc = YHTransferGroupOwner(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), url: url, loadCache: false){
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
    //退出群聊
    fileprivate func _requestQuitGroup(){
        NetManager.sharedInstance().postQuitGroup(withGroupID: groupID) { [unowned self](success:Bool, obj:Any) in
            if success{
                YHPrint("退出群聊成功\(obj)")
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                YHPrint("退出群聊失败\(obj)")
                postTips(obj, "退出群聊失败")
            }
        }
    }
    
}



extension YHGroupSetting:UITableViewDataSource,UITableViewDelegate{
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let count = _dataArraySection0?.count ,count > 0 {
                return 1
            }
            return 0
        }
        if section == 1, let count = _dataArraySection1?.count{
            return count
        }
        if section == 2,_isGroupOwner == true{
            return 1
        }
        if section == 3{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return _cellGroupMembers
        }else if indexPath.section == 1{
            
            var cell = tableView.dequeueReusableCell(withIdentifier: CellGroupSetting.className()) as? CellGroupSetting
            if cell == nil{
                cell = CellGroupSetting(style: .default, reuseIdentifier: CellGroupSetting.className())
            }
            if let count = _dataArraySection1?.count,count > indexPath.row {
                var model  = _dataArraySection1?[indexPath.row]
                if indexPath.row == 0,count > 0,let allMem = _dataArrayGroupMembers,allMem.count > 0 {
                    model?.title = "全部组成员 (\( allMem.count))"
                }else if indexPath.row == 1,count > 1,_groupName?.isEmpty == false {
                    model?.content = _groupName
                }else if indexPath.row == 2,count > 2,_myNameInGroup?.isEmpty == false {
                    model?.content = _myNameInGroup
                }
                
                cell!.model = model
            }
            return cell!
            
        }else if indexPath.section == 2{
            
            var cell = tableView.dequeueReusableCell(withIdentifier: CellGroupSetting.className()) as? CellGroupSetting
            if  cell == nil{
                cell = CellGroupSetting(style: .default, reuseIdentifier: CellGroupSetting.className())
            }
            
            if self._isGroupOwner == true{
                //section2数据   "组长管理权转让"
                var model   = CellGroupSettingModel()
                model.title = "组长管理权转让"
                cell!.model = model
            }

            return cell!
        }else{
            return _cellDelete
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if indexPath.row == 0{
                //全部组成员
                let vc = YHGroupMembersList()
                vc.groupID = groupID
                if let arr = _dataArrayGroupMembers,arr.count > 0{
                    vc.dataArray = arr
                }
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                
            }else if indexPath.row == 1{
                //讨论组名称
                let alertC = UIAlertController(title: "讨论组名称", message: nil, preferredStyle: .alert)
                var tfGroupN = UITextField()
                alertC.addTextField(configurationHandler: { tf in
                    tf.placeholder = "讨论组名称"
                    tfGroupN = tf
                })
                
                let actionCancel = UIAlertAction(title: "取消", style: .destructive, handler: { (alertAction) in
                    
                })
                let actionSure = UIAlertAction(title: "确定", style: .default, handler: { [unowned self](alertAction) in
                    YHPrint(tfGroupN.text ?? "")
                    if let newGroupName = tfGroupN.text,newGroupName.isEmpty == false {
                        self._requestModifyGroupName(newGroupName: newGroupName)
                    }
                })
                alertC.addAction(actionCancel)
                alertC.addAction(actionSure)
                
                self.present(alertC, animated: true, completion: nil)
                
            }else if indexPath.row == 2{
                //我在本群的名字
                let alertC = UIAlertController(title: "我在本群的昵称", message: "设置你在组里的昵称,这个昵称只会在这个组内显示", preferredStyle: .alert)
                var tfMyName = UITextField()
                
                alertC.addTextField(configurationHandler: { tf in
                    tf.placeholder = "我在本群的昵称"
                    tfMyName = tf
                })
                
                let actionCancel = UIAlertAction(title: "取消", style: .destructive, handler: { (alertAction) in
                    
                })
                let actionSure = UIAlertAction(title: "确定", style: .default, handler: { (alertAction) in
                    YHPrint(tfMyName.text ?? "")
                    if let newName = tfMyName.text,newName.isEmpty == false {
                        self._requestModifyMyNameInGroup(newName: newName)
                    }
                })
                alertC.addAction(actionCancel)
                alertC.addAction(actionSure)
                
                self.present(alertC, animated: true, completion: nil)
            }else if indexPath.row == 3{
                //查看聊天记录
                let vc = YHMsgLogVC()
                vc.model = model
                navigationController?.pushViewController(vc, animated: true)
            }else if indexPath.row == 4{
                //投诉
                //https://apps.gtax.cn/taxtao/webim/group_complaints/ee4cb649-783b-4197-b855-7c4879ec13ea?accessToken=1A5B960F3A5C46F39D8980234A2AA5F5
//                let vc = YHComplainVC(tagretID: groupID, complainType: .groupChat)
//                vc.hidesBottomBarWhenPushed = true
//                navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if indexPath.section == 2{
            
            if indexPath.row == 0 {
                //群转让
                _requestTransferGroupOwner()
            }
        }
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return _collectionViewH > 0 ? _collectionViewH : 0
        }
        if indexPath.section == 3{
            return 100  //删除并退出
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let aFooterV = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 15))
        aFooterV.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        return aFooterV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 0.01
        }
        return 15
    }
}

// MARK: - CellGroupSettingDeleteDelegate
extension YHGroupSetting:CellGroupSettingDeleteDelegate{
    func onDelete(){
        YHPrint("点击删除并退出")
  
         YHAlertView.show(title: "删除并退出后，将不再接收此讨论组信息", message: nil, cancelButtonTitle: "取消", otherButtonTitle: "确定") { [unowned self](alertV:YHAlertView, buttonIndex:Int)  in
             if buttonIndex == 1{
                YHPrint("确定")
                self._requestQuitGroup()
             }
        }

    }
}

// MARK: - CellGroupSettingMembersDelegate
extension YHGroupSetting:CellGroupSettingMembersDelegate{
    //点击头像
    func onMemberAvatar(model:YHGroupMember) {
//        if let vc = CardDetailViewController(userId: model.userID){
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }

    //邀请好友到群聊
    func onInviteMember(){
        YHPrint("邀请好友到群聊")
        
//        let vc = YHChooseFriVC()
//        vc.hidesBottomBarWhenPushed = true
//        vc.barTitle = "邀请好友"
//        vc.groupId  = groupID
//        vc.pageType = .addGroupChatMember
//        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //删除群成员
    func onDeleteMember(){
        YHPrint("删除群成员")

        var token = ""
        if let aToken = YHUserInfoManager.sharedInstance().userInfo.accessToken {
            token = aToken
        }
        var path = YHProtocol.share().pathRemoveGroupMembers
       
        path = path + "\(groupID)?accessToken=\(token)&is_manger=1"
        let url = URL(string: path)
        DispatchQueue.main.async {
            if let vc = YHRemoveGroupMembers(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64), url: url, loadCache: false){
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}
