//
//  MyPasswordView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/6/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "MyPasswordView.h"
#import "Masonry.h"

@implementation MyPasswordView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor  =[UIColor whiteColor];
        
        self.title = [[UILabel alloc]init];
        self.title.font = [UIFont systemFontOfSize:16];
        self.title.textColor = [UIColor colorWithWhite:0.686 alpha:1.000];
        self.title.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.title];
        
        self.passwordTF = [[UITextField alloc]init];
        self.passwordTF.font = [UIFont systemFontOfSize:16 ];
        self.passwordTF.textColor =[UIColor colorWithWhite:0.686 alpha:1.000];
        self.passwordTF.backgroundColor = [UIColor whiteColor];
//        self.passwordTF.keyboardType = UIKeyboardTypeASCIICapable;
        self.passwordTF.secureTextEntry = YES;
        self.passwordTF.returnKeyType = UIReturnKeyNext;
//        self.passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;

        [self addSubview:self.passwordTF];
        
        self.btn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [self.btn sizeToFit];
        [self addSubview:self.btn];
        
        self.topline = [[UIView alloc]init];
        self.leftline = [[UIView alloc]init];
        self.bottomline = [[UIView alloc]init];
        self.rightline = [[UIView alloc]init];
        
        self.topline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
        self.leftline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
        self.bottomline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
        self.rightline.backgroundColor = [UIColor colorWithWhite:0.871 alpha:1.000];
        
        [self addSubview:self.topline];
        [self addSubview:self.leftline];
        [self addSubview:self.bottomline];
        [self addSubview:self.rightline];
        
//        self.passwordTF.backgroundColor = [UIColor redColor];
        
        [self masonry];
    }
    return self;
}

-(void)masonry{
    WeakSelf
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.left.equalTo(weakSelf).offset(15);
    }];
    
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf.btn.mas_left).offset(-15);
        make.left.equalTo(weakSelf.title.mas_right).offset(15);
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        make.width.mas_equalTo(0);
    }];
    
    [self.topline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.top.left.right.equalTo(weakSelf);
    }];
    
    [self.bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.bottom.left.right.equalTo(weakSelf);
    }];
    
    [self.leftline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.bottom.left.top.equalTo(weakSelf);
    }];
    
    [self.rightline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.bottom.right.top.equalTo(weakSelf);
    }];
}

@end
