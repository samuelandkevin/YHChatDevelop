//
//  LabelController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/13.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LabelArrayNoObject,
    LabelArrayUpdating,
    LabelArrayUpdateFinish,
    LabelArrayUpdateFailure
} LabelArrayState;

@interface LabelController : UIViewController

@end
