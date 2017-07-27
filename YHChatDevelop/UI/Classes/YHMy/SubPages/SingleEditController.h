//
//  SingleEditController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"

typedef enum : NSUInteger {
    expSchool=10,
    expMajor,
    expCompany,
    expPosition,
} Experience;

typedef enum : NSUInteger {
    userName,
    company,
    position,
    department
} UserProperty;

@interface SingleEditController : UIViewController

@property(nonatomic,strong) IQTextView * textView;

@property(nonatomic,strong) NSString * String;

@property(nonatomic,copy) NSString * placeholder;

@property(nonatomic, assign) Experience experience;


@end
