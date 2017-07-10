//
//  YHRemoveGroupMembers.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/20.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  

import Foundation

class YHRemoveGroupMembers:YHWebViewController{
    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "移除群成员"
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem(title: "确定", target: self, selector: #selector(onSure(sender:)))

    }
    
    // MARK: - Action
    @objc fileprivate func onSure(sender:Any){
        //确定移除
        self.webView.stringByEvaluatingJavaScript(from: "minusMembers()")
    }
    
    
    // MARK: - Super
    override func webViewDidFinishLoad(_ webView: UIWebView!) {
        super.webViewDidFinishLoad(webView)
        //移除成功
        OCtoSwiftUtil.convert(with: self.jsContext!, funcName: "reloadGroupSetting"){

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotif_GroupSettingPage_Refresh_Swift), object: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}
