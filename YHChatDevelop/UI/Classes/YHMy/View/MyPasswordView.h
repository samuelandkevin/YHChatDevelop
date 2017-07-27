//
//  MyPasswordView.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPasswordView : UIView

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UITextField *passwordTF;

@property(nonatomic,strong) UIButton * btn;

@property (nonatomic, strong) UIView *topline;
@property (nonatomic, strong) UIView *leftline;
@property (nonatomic, strong) UIView *bottomline;
@property (nonatomic, strong) UIView *rightline;

@end
