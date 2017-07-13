//
//  OCtoSwiftUtil.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/11/3.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "OCtoSwiftUtil.h"
#import "YHChatDevelop-Swift.h"

@implementation OCtoSwiftUtil

+ (void)convertWithJSContext:(JSContext *)jsContext funcName:(NSString *)funcName complete:(void(^)())complete{
    jsContext[funcName] = complete;
}

+ (id)convertToObjectWithJsonString:(NSString *)jsonString{

    id retObj = nil;
    if ([jsonString isKindOfClass:[NSString class]]) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        retObj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        return  retObj;
    }else{
        return retObj;
    }
    
}

//获取Url
+ (NSURL *)getUrlWithPath:(NSString *)path encode:(BOOL)encode{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,path];
    if (encode) {
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSURL URLWithString:urlString];
}


+ (UIImage *)specialColorImage:(UIImage*)image withRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    //Create context
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    //Traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            //Change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    //Convert to image
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProviderRef,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProviderRef);
    UIImage* img = [UIImage imageWithCGImage:imageRef];
    
    //Release
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    return img;
}

+ (NSInteger)getLocationWithTargetString:(NSString *)targetString sourceString:(NSString *)sourceString{
    NSUInteger location = [sourceString rangeOfString:targetString].location;
    if (location == NSNotFound) {
        return -1;
    }
    return location;
}


#pragma mark - Private Methods
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

@end
