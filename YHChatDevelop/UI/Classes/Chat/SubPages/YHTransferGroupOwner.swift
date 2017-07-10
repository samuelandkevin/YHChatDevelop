//
//  YHTransferGroupOwner.swift
//  PikeWay
//
//  Created by YHIOS002 on 2017/6/20.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  转让群

import Foundation

class YHTransferGroupOwner:YHWebViewController{
    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "群主管理权转让"
    }
    
    // MARK: - Super
    override func webViewDidFinishLoad(_ webView: UIWebView!) {
        super.webViewDidFinishLoad(webView)
        //转让成功
        OCtoSwiftUtil.convert(with: self.jsContext!, funcName: "reloadGroupSetting"){
            //转让成功
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotif_GroupSettingPage_Refresh_Swift), object: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: { 
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}
