//
//  CustomerNavigationController.m
//  testCustomerNavigationBar
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 GDsamuelandkevin. All rights reserved.
//

#import "YHNavigationController.h"

@interface YHNavigationController ()

@end

@implementation YHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏背景颜色
    UIColor *color = kBlackColor;
    self.navigationBar.barTintColor = color;
    
    //设置导航栏标题颜色
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationBar.titleTextAttributes = attributes;
    
    //设置返回按钮的颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    //状态栏文字白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

//根据颜色返回图片
+(UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)CreateNaviBar
{
    if (self.naviBar == nil) {
        self.naviBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 66)];
        self.naviBar.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:self.naviBar];
        self.navigationController.navigationBarHidden = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
