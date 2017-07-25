//
//  CustomerNavigationController.h
//  testCustomerNavigationBar
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 GDsamuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YHNavigationController : UINavigationController
@property(nonatomic,strong) UIView * naviBar;

-(void)CreateNaviBar;

@end
