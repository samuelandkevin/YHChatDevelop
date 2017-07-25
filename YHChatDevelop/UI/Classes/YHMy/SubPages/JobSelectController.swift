//
//  JobSelectController.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/1/9.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import UIKit
import MBProgressHUD

class JobSelectController: UIViewController {

    let dataArray: Array = ["首席财务官(CFO)","首席税务官(CTO)","总税务师","总经理","副总经理","经理","副经理","总监","副总监","高级职员","职员","其他"]
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero , style: .plain)
        return tv
    }()
    
    var userInfo = YHUserInfo()
    
    var jobString: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        tableView.register(JobSelectCell.self, forCellReuseIdentifier: JobSelectCell.cellIdentifier)
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        tableView.separatorInset = .zero
        
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textColor = UIColor.white
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.setTitle("保存", for: .normal)
        btn.addTarget(self, action: #selector(JobSelectController.submitChange), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobSelectController.textFieldDidChange(notif:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)

    }
    
    func submitChange(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        userInfo.job = jobString ?? ""
        NetManager.sharedInstance().postEditMyCard(with: userInfo) {[unowned(unsafe) self] (isOK, obj) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if isOK == true {
                YHUserInfoManager.sharedInstance().userInfo.job = self.userInfo.job
                postTips("保存成功", nil)
                _ = self.navigationController?.popViewController(animated: true)
            }else{
                if let dic = obj as? Dictionary<String, Any>, let msg = dic["msg"]{
                    postTips(msg, "保存失败")
                }
            }
        }
    }
    
    deinit {
        YHPrint(self,"deinit")
    }
}

extension JobSelectController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            view.endEditing(true)
        }
        
        if string == "" {
            return true
        }
        
        var text: NSString = ""
        
        textField.text.flatMap{ $0 as NSString }.map{ text = $0 }
        
        var result = ""
        
        if text.length >= range.location {
            result = text.replacingCharacters(in: range, with: string)
        }
        
        if result.characters.count > 10 {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.jobString = textField.text
    }
    
    func textFieldDidChange(notif: Notification) {
        if let tf = notif.object, tf is UITextField{
            (tf as! UITextField).text.map{ self.jobString = $0 }
        }
    }
    
}

extension JobSelectController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JobSelectCell.cellIdentifier, for: indexPath) as! JobSelectCell
        
        cell.setCellTitle(str: self.dataArray[indexPath.row])
        if indexPath.row == self.dataArray.count - 1 {
            cell.other.delegate = self
            
            if let jobString = self.jobString, self.dataArray.contains(jobString) == false {
                cell.other.text = jobString
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! JobSelectCell
        
        if indexPath.row == self.dataArray.count - 1 {
            cell.other.becomeFirstResponder()
        }else{
            self.jobString = cell.title.text
            self.view.endEditing(true)
        }
    }
}

class JobSelectCell: UITableViewCell{
    
    lazy var title: UILabel = {
        let lab = UILabel()
        return lab
    }()
    
    lazy var other: UITextField = {
        let tf = UITextField()
        return tf
    }()
    
    static var cellIdentifier: String {
        get{
            return String(describing: self)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .gray
        
        addSubview(title)
        addSubview(other)
        
        title.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
        }
        
        other.snp.makeConstraints { [unowned(unsafe) self] (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
        }
        
    }
    
    func setCellTitle(str: String){
        if str == "其他" {
            other.isHidden = false
            title.isHidden = true
            other.placeholder = str
        }else{
            other.isHidden = true
            title.isHidden = false
            title.text = str
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
