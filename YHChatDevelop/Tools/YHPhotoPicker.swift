//
//  YHPhotoPiker.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/11/28.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  图片选择器工具

import UIKit
import AVFoundation
import Photos
import AssetsLibrary


@objc protocol YHPhotoPickerDelegate:class {
    func didFinishPickingPhotos(photos: [UIImage]!)
}


class YHPhotoPicker : NSObject,TZImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    typealias GrantedHandler = (_ granted:Bool)->Void
    weak var delegate:YHPhotoPickerDelegate?
    
    //单例
    class func shareInstance() -> YHPhotoPicker {
        struct single{
            static var g_Instance = YHPhotoPicker()
        }
        return single.g_Instance
    }
    
    
    //照片VC
    fileprivate lazy var imagePickerVC:TZImagePickerController? =  {
        let vc = TZImagePickerController(maxImagesCount: 1, delegate: self)
        return vc
    }()
    
    
    //拍照VC
    fileprivate lazy var cameraPickerVC:UIImagePickerController = {
        
        let vc = UIImagePickerController()
        
        let color = UIColor.colorWithHexString(hex: "0e92dd")
        
        vc.navigationBar.barTintColor = color;
        
        let attributes = ["NSForegroundColorAttributeName":UIColor.white,
                          "NSFontAttributeName":UIFont.systemFont(ofSize: 18)]
        
        vc.navigationBar.titleTextAttributes = attributes;
        return vc
    }()
    
    
    //询问相机是否授权
    public func isCameraGranted(handler:@escaping GrantedHandler){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { ( granted:Bool) in
                
                DispatchQueue.main.async {
                    if granted{
                        
                        YHPrint("=====用户允许使用相机=====")
                        handler(true)
                    }else{
                        YHPrint("=====用户不允许使用相机=====");
                        postTips("税道APP没有权限访问您的相机,请在设置中开启税道访问相机的权限", nil);
                        handler(false)
                    }
                }
                
            })
            
        }else{
            postTips("相机不可用", nil)
            handler(false)
        }
        
    }
    
    //询问相册是否授权
    public func isPhotoGranted() -> Bool {
        
        if ((UIDevice.current.systemVersion as NSString).doubleValue >= Double(8.0)){
            
            if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .notDetermined {
                return true
            }else{
                postTips("税道APP没有权限访问您的相册,请在设置中开启税道访问相册的权限", nil)
                return false
            }
        }else{
            
            let author = ALAssetsLibrary.authorizationStatus()
            if author == ALAuthorizationStatus.authorized || author == ALAuthorizationStatus.notDetermined {
                return true
            }else{
                postTips("税道APP没有权限访问您的相册,请在设置中开启税道访问相册的权限", nil)
                return false
            }
        }
        
    }
    
    //选择照片
    func choosePhoto(sourceType: UIImagePickerControllerSourceType,inViewController: UIViewController ){
        
        delegate = inViewController as? YHPhotoPickerDelegate
        //照片类型
        switch sourceType {
        case .photoLibrary:
            
            break
        case .camera:
            
            //相机
            isCameraGranted(handler: { [unowned self] (granted:Bool)  in
                
                if granted {
                    self._showCameraPickerVC(sourceType: .camera, inViewController: inViewController)
                }
                
            })
            
            break
            
        case .savedPhotosAlbum:
            //图片库
            if isPhotoGranted() {
                _showPhotoPickerVC(inViewController)
            }
            break
            
        }
        
    }
    
    // MARK: - Private
    //显示拍照控制器
    fileprivate func _showCameraPickerVC (sourceType: UIImagePickerControllerSourceType,inViewController:UIViewController){
        
        cameraPickerVC.delegate = self
        cameraPickerVC.sourceType = sourceType
        inViewController.present(cameraPickerVC, animated: true, completion: nil)
    }
    
    //显示图片控制器
    fileprivate func _showPhotoPickerVC(_ inViewController:UIViewController){
        if imagePickerVC == nil {
            imagePickerVC = TZImagePickerController(maxImagesCount: 1, delegate: self)
        }
        inViewController.present(imagePickerVC!, animated: true, completion: nil)
    }
    
    // MARK: - @protocol TZImagePickerControllerDelegate
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        if photos.count == 0 {return}
        
        var oriImg = photos[0]
        if isSelectOriginalPhoto == false {
            
            
            
            oriImg = compressImage(oriImage: oriImg, clipToRound: false)
        }
        
        delegate?.didFinishPickingPhotos(photos: [oriImg])
        imagePickerVC = nil
    }
    
    func didFinishPickingPhotos(photos: [UIImage]!){
        
    }
    
    // MARK: - @protocol UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //拍照取照片
        guard let vc = delegate as? UIViewController else{
            return
        }
        vc.dismiss(animated: true, completion: nil)
        let compressImage = self.compressImage(imgPickerVCinfo: info, clipToRound: false)
        delegate?.didFinishPickingPhotos(photos: [compressImage])
    }
    
    
    @nonobjc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Life
    deinit {
        YHPrint("YHPhotoPicker deinit")
    }
    
    // MARK: - Public
    //图片压缩  oriImage:原图
    //         clipToRound:裁剪成圆角
    public func compressImage(oriImage: UIImage,clipToRound:Bool) -> UIImage {
        
        var compressImage:UIImage!
        
        
        let imgData:Data!
        if let tmpData = UIImageJPEGRepresentation(oriImage, 0.1) {
            imgData = tmpData
            YHPrint("压缩后大小:\(imgData.count/1000)")
            compressImage = UIImage(data:imgData)
        }else if let tmpData = UIImagePNGRepresentation(oriImage){
            imgData = tmpData
            YHPrint("压缩后大小:\(imgData.count/1000)")
            compressImage = UIImage(data:imgData)
        }else{
            imgData = Data()
            YHPrint("没有压缩,采用原图")
            compressImage = oriImage
        }
        
        if clipToRound {
            
            let radius = compressImage.size.width < compressImage.size.height ? compressImage.size.width/2 : compressImage.size.height/2
            
            compressImage = compressImage.withCornerRadius(radius)
        }
        return compressImage
    }
    
    
    //图片压缩   info：UIImagePickerController的info
    //         clipToRound：裁剪成圆角
    public func compressImage(imgPickerVCinfo: [String : Any],clipToRound:Bool) -> UIImage {
        let oriImage = imgPickerVCinfo[UIImagePickerControllerOriginalImage] as! UIImage
        return compressImage(oriImage: oriImage, clipToRound: clipToRound)
        
        
    }
    
    
}


