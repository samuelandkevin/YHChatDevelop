//
//  YHNetManager.h
//  PikeWay
//
//  Created by YHIOS002 on 16/12/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NetManager.h"

@interface NetManager (AppInfo)

//获取页面能否打开信息
- (void)getPageInfoAboutCanOpenedComplete:(NetManagerCallback)complete;
@end
