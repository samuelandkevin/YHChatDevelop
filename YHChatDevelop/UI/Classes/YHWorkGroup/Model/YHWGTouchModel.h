//
//  YH3DTouch.h
//  PikeWay
//
//  Created by YHIOS002 on 16/12/5.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"

@interface YHWGTouchModel : NSObject

+ (YHWGTouchModel *)registerForPreviewInVC:(UIViewController *)vc sourceView:(UIView *)sourceView model:(YHWorkGroup *)model;

@end
