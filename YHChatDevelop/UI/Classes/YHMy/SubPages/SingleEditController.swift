//
//  SingleEditController.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/6.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

import UIKit
import MBProgressHUD

class SingleEditController_notFinish: UIViewController, UITextViewDelegate {

    private lazy var textView: IQTextView = {
        let tv = IQTextView(frame: CGRect(x: 15, y: 15, width: ScreenWidth - 30, height: 55))
        tv.backgroundColor = UIColor.white
        if let fontSize = UserDefaults.standard.value(forKey: "setSystemFontSize") as? CGFloat {
            tv.font = UIFont.systemFont(ofSize: fontSize)
        }
        tv.textColor = UIColor(white: 0.557, alpha: 1.0)

        return tv
    }()
    
    private var exp: String = SingleEditExp.noExp
    
    private var content: String = "" {
        willSet{
            self.textView.text = newValue
        }
    }
    
    private var placeholder: String = "" {
        willSet{
            self.textView.placeholder = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.957, alpha: 1.0)
        
        view.addSubview(textView)
        
        textView.delegate = self
    
    }

    required init(with title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configureTopBtn() {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.textColor = UIColor.white
        btn.addTarget(self, action: #selector(SingleEditController_notFinish.rightBtnFunc), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: btn)
        self.navigationController?.navigationItem.rightBarButtonItem = rightItem
    }
    
    func rightBtnFunc(){
        view.endEditing(true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if exp != SingleEditExp.noExp {
            if self.textView.text != self.content {
                let arr: [String] = [exp, self.textView.text]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "event.singleVC.value"), object: arr)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
        
        if self.title == "姓名" {
            
        }
            
        
    }
    
}

