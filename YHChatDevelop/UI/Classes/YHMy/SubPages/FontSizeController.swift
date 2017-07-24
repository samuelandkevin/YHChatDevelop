//
//  FontSizeController.swift
//  PikeWay
//
//  Created by YHIOS003 on 16/8/3.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import Foundation
import UIKit

class FontSizeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
	let cellIdantifier = "FontSizeCell"
    lazy var fontSize: Int = {
        let size = UserDefaults.standard.value(forKey: "setSystemFontSize")
        if let temp = size as? String, let exist = Int(temp) {
            return exist
        }else{
            UserDefaults.standard.setValue("2", forKey: "setSystemFontSize")
            return 2
        }
    }()
    lazy var label: UILabel = {
        let lab = UILabel()
        return lab
    }()
    
    
    
	deinit {
		YHPrint("FontSizeController is deinitialized")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.title = "字体大小"
        //返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(onBack(sender:)))

        self.label.font = UIFont.systemFont(ofSize: 16)
        self.label.text = "微信克隆版"
        
		self.view.addSubview(self.tableView)
		self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorStyle = .none
		self.tableView.register(FontSizeCell.classForCoder(), forCellReuseIdentifier: cellIdantifier)
        
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints { [unowned(unsafe) self](make) in
            make.center.equalTo(self.view)
        }
    
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdantifier, for: indexPath) as! FontSizeCell
		let arr = ["大", "中", "小"]

		cell.title.text = arr[(indexPath as NSIndexPath).row];
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let fontSize = (UserDefaults.standard.value(forKey: "setSystemFontSize") as AnyObject).int8Value

		if fontSize == (2 - (indexPath as NSIndexPath).row) * 2 {
			return;
		}
		switch (indexPath as NSIndexPath).row {
		case 0:
            self.fontSize = 4
		case 1:
            self.fontSize = 2
		case 2:
            self.fontSize = 0
		default: break
		}
        UserDefaults.standard.setValue(String(self.fontSize), forKey: "setSystemFontSize")
		NotificationCenter.default.post(name: Notification.Name(rawValue: "event.SystemFontSize_Change"), object: nil)
        let size = 16 + self.fontSize
        self.label.font = UIFont.systemFont(ofSize: CGFloat(size))
        
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let row = self.fontSize / 2
		let indexPath = IndexPath.init(row: 2 - row, section: 0)
		self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
	}
    
    func onBack(sender:Any) {
        _ = self.navigationController?.popViewController(animated: true);
        
    }

}
