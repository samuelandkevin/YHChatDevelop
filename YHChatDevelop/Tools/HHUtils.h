//
//  HHUtils.h
//  PikeWay
//
//  Created by samuelandkevin on 14-6-26.
//  Copyright (c) 2014年 samuelandkevin.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HHUtils : NSObject


/**
 *  MD5加密字符串
 */
+ (NSString *)md5HexDigest:(NSString*)input;

/**
 *  获取iPhone机型
 */
+ (NSString*)phoneType;

/**
 *  获取iPhone系统
 *  @return eg:iOS8.1
 */
+ (NSString *)phoneSystem;

/**
 *  appStore上的版本号
 */
+ (NSString *)appStoreNumber;

/**
 *  app开发环境版本号
 */
+ (NSString *)appBulidNumber;

/**
 运营商
 */
+ (NSString *)carrierName;


@end

#ifdef __cplusplus
extern "C" {
#endif

/**
 返回文件长度，以字节为单位
 */
int getFileSize(NSString *path);


NSString * getDeviceVersion();
NSString * platformString ();
    BOOL checkABGranted();   //检查通讯录是否授权
    BOOL checkVideoGranted();//检查视频是否授权
/**
 比较不同数组中不同的ID（与上一次的缓存对比）
 @return 返回与是一次是否有变化
 */
BOOL compareStringIdsDiff( NSArray *allphones, NSString *phonesCacheFilePath, NSArray **addlist, NSArray **removelist );

#ifdef __cplusplus
    }
#endif
