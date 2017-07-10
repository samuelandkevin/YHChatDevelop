//
//  YHCardSettingVC.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/5/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation
import MBProgressHUD

protocol CellCardSetting1Delegate :class {
    func onSwitchIn(cell:CellCardSetting1,on:Bool)
}

class CellCardSetting1:UITableViewCell{
    
    // MARK: - Public Property
    var title:String! {
        willSet(newValue){
            _label.text = newValue
        }
    }
    var isInMyBlackList:Bool!{
        willSet(newValue){
            _sw.isOn = newValue
        }
    }
    
    var botLine:UIView!
    var indexPath:IndexPath!
    weak var delegate:CellCardSetting1Delegate?
    
    // MARK: - Private Property
    private var _label:UILabel!
    private var _sw:UISwitch!
    
    // MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Method
    private func _setupUI(){
        //左标题
        _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 16.0)
        _label.textColor = UIColor.black
        contentView.addSubview(_label)

        //开关
        _sw = UISwitch()
        _sw.addTarget(self, action: #selector(onSwitch(sender:)), for: .valueChanged)
        contentView.addSubview(_sw)

        //分割线
        botLine = UIView()
        botLine.backgroundColor = UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
        contentView.addSubview(botLine)

        backgroundColor = UIColor.white
        _layoutUI()
    }
    
    private func _layoutUI(){
        _label.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.contentView).offset(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        _sw.snp.makeConstraints { [unowned self](make) in
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }

        botLine.snp.makeConstraints { [unowned self](make) in
            make.height.equalTo(1)
            make.left.bottom.right.equalTo(self.contentView)
        }
    
    }
    
    // MARK: - Action
    @objc private func onSwitch(sender:UISwitch){
        delegate?.onSwitchIn(cell: self, on: sender.isOn)
    }
}


class CellCardSetting2:UITableViewCell{
    
    var title:String! {
        willSet(newValue){
            _label.text = newValue
        }
    }
    var botLine:UIView!
    
    private var _label:UILabel!
    
    // MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        _setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func _setupUI(){
        //左标题
        _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 16.0)
        _label.textColor = UIColor.black
        contentView.addSubview(_label)

        //分割线
        botLine = UIView()
        botLine.backgroundColor = UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
        contentView.addSubview(botLine)
        
        accessoryType = .disclosureIndicator
        backgroundColor = UIColor.white
        _layoutUI()
    
    }
    
    private func _layoutUI(){
 
        _label.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.contentView).offset(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    
        botLine.snp.makeConstraints{ [unowned self](make) in
            make.height.equalTo(1)
            make.left.bottom.right.equalTo(self.contentView)
        }
    

    }
}

class YHCardSettingVC:UIViewController{
    

    // MARK: - Private Property
    fileprivate var _userInfo:YHUserInfo?
    fileprivate var _curUid:String?
    fileprivate let kSectionHeaderH:CGFloat       = 15.0//sectionHeader高度
    fileprivate let kSectionFooterH:CGFloat       = 15.0//sectionFooter高度
    fileprivate let kSectionDeleteFriendH:CGFloat = 44.0//删除好友高度
    
    var model:YHChatListModel?
    
    // 控件
    private lazy var _tableView:UITableView = {
        let aTableV = UITableView(frame: .zero, style: .plain)
        return aTableV
    }()
    
    // MARK: - init
    convenience init(userInfo:YHUserInfo){
        
        self.init()
        _userInfo = userInfo
        _curUid   = userInfo.uid
        
    }
    
    convenience init(userID:String){
        self.init()
        _curUid = userID
        SqliteManager.sharedInstance().queryOneFri(withID: _curUid) { [unowned self](success:Bool, obj:Any) in
            if success , let aObj = obj as? YHUserInfo{
                self._userInfo = aObj
                self._tableView.reloadData()
            }else{
                NetManager.sharedInstance().getVisitCardDetail(withTargetUid: self._curUid, complete: { [unowned self](success:Bool, obj:Any) in
                    if success , let aObj = obj as? YHUserInfo{
                        self._userInfo = aObj
                        self._tableView.reloadData()
                    }
                })
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life
    deinit {
        YHPrint("YHCardSettingVC is deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "设置"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        
        
        //tableView
        _tableView.frame      = view.frame
        _tableView.delegate   = self
        _tableView.dataSource = self
        _tableView.backgroundColor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        _tableView.separatorStyle  = .none
        view.addSubview(_tableView)

        _tableView.rowHeight = 44.0
        _tableView.register(CellCardSetting1.classForCoder(), forCellReuseIdentifier: CellCardSetting1.className())
        _tableView.register(CellCardSetting2.classForCoder(), forCellReuseIdentifier: CellCardSetting2.className())
        
        
    }
    
    // MARK: - Action
    func onBack(sender:Any){
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - @protocol UITableViewDataSource & UITableViewDelegate
extension YHCardSettingVC:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 3 || section == 4 {
            return 1
        }
        else if section == 1{
            return 0 //暂时隐藏
        }else if section == 2{
            return 2
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID1 = CellCardSetting1.className()
        let cellID2 = CellCardSetting2.className()
        
        if indexPath.section == 0 {
            let cell = CellCardSetting2(style: .default, reuseIdentifier: cellID2)
            cell.title = "分享名片"
            cell.botLine.isHidden = true
            return cell
        }else if indexPath.section == 1{
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID1) as? CellCardSetting1
            
            if cell == nil {
                cell = CellCardSetting1(style: .default, reuseIdentifier: cellID1)
            }
            cell?.indexPath = indexPath
            cell?.delegate = self
            if indexPath.row == 0{
                cell?.title = "不让他看我的动态"
                cell?.botLine.isHidden = false
            }
            else{
                cell?.title = "不看他的动态";
                cell?.botLine.isHidden = true
            }
            return cell!
        }else if indexPath.section == 2{
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: cellID1) as? CellCardSetting1
                
                if cell == nil {
                    cell = CellCardSetting1(style: .default, reuseIdentifier: cellID1)
                }
                cell?.indexPath = indexPath;
                cell?.delegate = self;
                if let aUserInfo =  _userInfo{
                    cell?.isInMyBlackList = aUserInfo.isInMyBlackList
                }
                cell?.title = "加入黑名单"
                cell?.botLine.isHidden = false
                return cell!
            }else{
                var cell = tableView.dequeueReusableCell(withIdentifier: cellID2) as? CellCardSetting2
                if cell == nil {
                    cell = CellCardSetting2(style: .default, reuseIdentifier: cellID2)
                }
                cell?.title = "投诉"
                cell?.botLine.isHidden = true
                return cell!
            }
            
        }else if indexPath.section == 3 && indexPath.row == 0{
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID2) as? CellCardSetting2
            if  cell == nil {
                cell = CellCardSetting2(style: .default, reuseIdentifier: cellID2)
            }
            cell?.title = "查看聊天记录"
            cell?.botLine.isHidden = true
            return cell!
            
        }else if indexPath.section == 4{
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId3")
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: ScreenWidth-20, height: kSectionDeleteFriendH))
            label.textAlignment = .center
            label.backgroundColor = UIColor(red: 252/255.0, green: 2/255.0, blue: 0, alpha: 1.0)
            label.text = "删除好友"
            label.layer.cornerRadius  = 4
            label.layer.masksToBounds = true
            label.textColor = UIColor.white
            cell.contentView.addSubview(label)
            cell.selectionStyle  = .none
            cell.backgroundColor = UIColor.clear
            
            return cell
        }else{
            return UITableViewCell()
        }


    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.1
        }
        return kSectionHeaderH
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerVInSection = UIView()
        headerVInSection.backgroundColor = UIColor.clear
        return headerVInSection
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerVInSection = UIView()
        footerVInSection.backgroundColor = UIColor.clear
        return footerVInSection
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 || section == 2 {
            return 0.1
        }
        else{
            return kSectionFooterH
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  indexPath.section == 0 && indexPath.row == 0 {
            YHPrint("点击分享名片")
            //分享名片
//            let shareView = YHSharePresentView()
//            shareView.shareType = .card
//            shareView.show()
//            shareView.dismissHandler({ [unowned self](isCanceled:Bool, index:Int) in
//                if isCanceled == false{
//                    switch index {
//                        case 3:
//                            
//                            let vc = ChooseMyFrisViewController()
//                            vc.shareType = .card
//                            vc.shareCardToPWFris = self._userInfo
//                            let nav = YHNavigationController(rootViewController: vc)
//                            self.present(nav, animated: true, completion: nil)
//                            
//                        break
//                        
//                        case 0:
//                            
//                            YHSocialShareManager.sharedInstance().snsShareContent(with: .card, platform: .weixin, shareObj: self._userInfo)
//                            
//                        break
//                        case 1:
//                            //微信好友
//                            YHSocialShareManager.sharedInstance().snsShareContent(with: .card, platform: .weixinSession, shareObj: self._userInfo)
//                          
//                        break
//                        default:
//                            
//                        break
//                    }
//                }
//            })
        }else if indexPath.row == 1 && indexPath.section == 2{
            //投诉
//            guard let auid = _userInfo?.uid else {
//               return
//            }
//            let vc = YHComplainVC(tagretID: auid, complainType: .user)
//            vc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(vc,animated:true)
            
        }else if indexPath.row == 0 && indexPath.section == 3{
            //查看聊天记录
            YHPrint("查看聊天记录")
        
            let vc = YHMsgLogVC()
            vc.model = model
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc,animated:true)
            
        }else if(indexPath.section == 4){
            //删除好友
            
            YHAlertView.show(title: "删除好友", message: "您确定要删除对方为好友吗?", cancelButtonTitle: "取消", otherButtonTitle: "确定", clickButtonBlock: { [unowned self](alertV:YHAlertView, buttonIndex:Int) in
                if buttonIndex == 1 {
                    
                    var hud:MBProgressHUD = showHUDWithText("", self.view) as! MBProgressHUD
                    NetManager.sharedInstance().postDeleteFriend(withFrinedId: self._userInfo?.uid, complete: { (success:Bool, obj:Any) in
                        if success {
                            
                            hud = showHUDWithText("已经成功删除好友", self.view) as! MBProgressHUD
                            hud.hide(true)
                            YHPrint("删除好友成功")
                            
                            self._userInfo?.friShipStatus = .notpassValidtion
                            self._userInfo?.addFriStatus  = .none
                            
                            let auid = YHUserInfoManager.sharedInstance().userInfo.uid
                            SqliteManager.sharedInstance().deleteOneFriWithfriID(auid, fri: self._userInfo, userInfo: nil, complete: { (success:Bool, obj:Any) in
                                if success {
                                    YHPrint("删除DB某个好友成功：\(obj)");
                                }else{
                                    YHPrint("删除DB某个好友失败：\(obj)");
                                }
                             })
                            
                            //通知上一页刷新数据
                            NotificationCenter.default.post(name: Notification.Name(rawValue:kNotif_MyFriendsPage_Refresh_Swift), object: self, userInfo: ["userInfo":self._userInfo,"operation":"delete"])
                            NotificationCenter.default.post(name: Notification.Name(rawValue:kNotif_CardDetailPage_Refresh_Swift), object: nil, userInfo: ["userInfo":self._userInfo])
                            NotificationCenter.default.post(name: Notification.Name(rawValue:"event.popFromChatVC"), object: nil, userInfo: nil)
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: { 
                                self.navigationController?.popViewController(animated: true)
                            })
                        }else{
                            if let aObj = obj as? Dictionary<String,Any>{
                                //服务器返回的错误描述
                                let msg = aObj[kRetMsg_Swift]
                                 postTips(msg, "删除好友失败")
                            }else{
                                //AFN请求失败的错误描述
                                postTips(obj, "删除好友失败")
                            }
                        
                        }
                        
                        hud.hide(true)
                    })
                }else{
                
                }
            })
        
          
            
            
        }

    }
    
}

// MARK: - @protocol CellCardSetting1Delegate
extension YHCardSettingVC:CellCardSetting1Delegate{
    func onSwitchIn(cell: CellCardSetting1, on: Bool) {
        if cell.indexPath.section == 2 && cell.indexPath.row == 0 {
            //黑名单开关
            YHPrint("黑名单开关:\(on)")
            NetManager.sharedInstance().postModifyBlacklist(withTargetID: _curUid, add: on, complete: {[unowned self] (success:Bool, obj:Any) in
                if success {
                    YHPrint("修改黑名单成功")
                    self._userInfo?.isInMyBlackList = on
                    
                    SqliteManager.sharedInstance().updateOneFri(self._userInfo, updateItems: ["isInMyBlackList"], complete: { (success:Bool, obj:Any) in
                        if success {
                            YHPrint("修改DB黑名单成功,\(obj)")
                        }else{
                            YHPrint("修改DB黑名单失败,\(obj)")
                        }
                    })
                    
                }else{
                    if let aObj = obj as? Dictionary<String,Any>{
                        //服务器返回的错误描述
                        let msg = aObj[kRetMsg_Swift]
                        postTips(msg, "修改黑名单失败")
                    }else{
                        //AFN请求失败的错误描述
                        postTips(obj, "修改黑名单失败")
                    }
                }
            })

        }
    }
}
