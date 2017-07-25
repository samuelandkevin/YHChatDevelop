//
//  YHScanResultVC.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/16.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import Foundation

class YHScanResultVC:UIViewController,UITableViewDelegate,UITableViewDataSource{
    public typealias onBackBlock = ((_ onBack:Bool)->Void)?
    
    private var _arrayScanReult = [String]()
    private var _aBlock:onBackBlock = nil
    private var _tableView  = UITableView()
    public convenience init(reusltData:[String]){
        self.init()
        _arrayScanReult = reusltData
    }
    
    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        self.title = "扫描结果"
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))
        
        _tableView = UITableView(frame:CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-64) , style: .plain)
        _tableView.delegate   = self
        _tableView.dataSource = self
        view.addSubview(_tableView)
    }
    
    deinit {
        debugPrint("YHScanResultVC is deinit")
    }
    
    // MARK: - Action
    func onBack(sender:Any){
        //返回"扫一扫"页
        if let block = _aBlock {
            block(true)
        }
        if let count = navigationController?.viewControllers.count ,count > 2 , let vc = navigationController?.viewControllers[1]  {
            navigationController?.popToViewController(vc, animated: true)
        }else{
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = _arrayScanReult[indexPath.row]
        cell?.textLabel?.numberOfLines = 3
    
        return cell!
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _arrayScanReult.count
    }
    
    // MARK: - UITableViewDelegate
    
    
}
