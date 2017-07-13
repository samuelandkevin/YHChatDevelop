//
//  YH3DTouch.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/5.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"

@interface YHWGTouchModel : NSObject

+ (YHWGTouchModel *)registerForPreviewInVC:(UIViewController *)vc sourceView:(UIView *)sourceView model:(YHWorkGroup *)model;

@end
