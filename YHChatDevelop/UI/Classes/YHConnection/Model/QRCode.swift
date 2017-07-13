//
//  QRCode.swift
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

import Foundation

class QRCode:NSObject{
    
   
    class func createQRCodeImage(source:String) -> CIImage?{
        let data = source.data(using: .utf8)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")//设置纠错等级越高；即识别越容易，值可设置为L(Low) |  M(Medium) | Q | H(High)
        return filter?.outputImage
    }
    
    class func resizeQRCodeImage(image:CIImage,size:CGFloat) -> UIImage?{
        
        let extent = image.extent.integral
        let scale  = min(size/extent.width, size/extent.height)
        let width  = size_t(extent.width * scale)
        let height = size_t(extent.height * scale)
       
        let colorSpaceRef = CGColorSpaceCreateDeviceGray()
        
        guard let contextRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpaceRef, bitmapInfo: CGImageAlphaInfo.none.rawValue as UInt32) else{
            return nil
        }
        
        let context =  CIContext(options: nil)
       
        guard let imageRef = context.createCGImage(image, from: extent) else {
            return nil
        }
        contextRef.interpolationQuality = .none
        contextRef.scaleBy(x: scale, y: scale)
        contextRef.draw(imageRef, in: extent)
        
        guard let imageRefResized = contextRef.makeImage() else{
            return nil
        }

        let finalImage = UIImage(cgImage: imageRefResized)
       
        return finalImage
    }
    
    //暂时没转换成功
//    class func specialColorImage(image:UIImage,red:CGFloat,green:CGFloat, blue:CGFloat)-> UIImage?{
//        
//        let imageWidth  = image.size.width
//        let imageHeight = image.size.height
//        let bytesPerRow = size_t(imageWidth * 4)
//        let rgbImageBuf = UnsafeMutablePointer<size_t>.allocate(capacity: bytesPerRow*size_t(imageHeight))
//
//        
//        //Create context
//        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
//        
//        let contextRef = CGContext(data: rgbImageBuf, width: size_t(imageWidth), height: size_t(imageHeight), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpaceRef,  bitmapInfo: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue))
//
//        guard let cgImage = image.cgImage else {
//            return nil
//        }
//        contextRef?.draw(cgImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
//       
//        
//        //Traverse pixe
//        let pixelNum = size_t(imageWidth * imageHeight)
//        var pCurPtr  = rgbImageBuf
//        
//        for  _ in 0..<pixelNum {
//            if (pCurPtr & 0xFFFFFF00) < 0x99999900 {
//                //Change color
//                let ptr = pCurPtr
//                ptr[3] = size_t(red) //0~255
//                ptr[2] = size_t(green)
//                ptr[1] = size_t(blue)
//            }else{
//                let ptr = pCurPtr
//                ptr[0]  = 0
//            }
//            pCurPtr += 1
//            
//        }
//
//        
//        //Convert to image
//        guard let dataProviderRef = CGDataProvider(dataInfo: nil,
//                                      data: rgbImageBuf,
//                                      size: bytesPerRow * size_t(imageHeight),
//                                      releaseData: { (info, data, size) in
//                                        free(UnsafeMutableRawPointer(mutating: data))
//        }) else { return nil }
//
//
//        
//        guard let imageRef = CGImage(width: size_t(imageWidth),height: size_t( imageHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytesPerRow, space: colorSpaceRef,
//                               bitmapInfo: (CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.last.rawValue)), provider: dataProviderRef,
//                               decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) else {
//                                return nil
//        }
//        let img = UIImage(cgImage: imageRef)
//        return img
//    }
    
    class func addIconToQRCodeImage(image:UIImage,icon:UIImage, iconSize:CGSize) -> UIImage?{
        
        UIGraphicsBeginImageContext(image.size)
        //通过两张图片进行位置和大小的绘制，实现两张图片的合并；其实此原理做法也可以用于多张图片的合并
        let widthOfImage  = image.size.width
        let heightOfImage = image.size.height
        let widthOfIcon   = iconSize.width
        let heightOfIcon  = iconSize.height
        
        image.draw(in: CGRect(x: 0, y: 0, width: widthOfImage, height: heightOfImage))
        icon.draw(in: CGRect(x: (widthOfImage-widthOfIcon)/2, y: (heightOfImage-heightOfIcon)/2, width: widthOfIcon, height: heightOfIcon))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    class func addIconToQRCodeImage(image:UIImage,icon:UIImage, scale:CGFloat) -> UIImage?{
        //通过两张图片进行位置和大小的绘制，实现两张图片的合并；其实此原理做法也可以用于多张图片的合并
        let widthOfImage  = image.size.width
        let heightOfImage = image.size.height
        let widthOfIcon   = widthOfImage/scale
        let heightOfIcon  = heightOfImage/scale
        
        image.draw(in: CGRect(x: 0, y: 0, width: widthOfImage, height: heightOfImage))
        icon.draw(in: CGRect(x: (widthOfImage-widthOfIcon)/2, y: (heightOfImage-heightOfIcon)/2, width: widthOfIcon, height: heightOfIcon))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
}
