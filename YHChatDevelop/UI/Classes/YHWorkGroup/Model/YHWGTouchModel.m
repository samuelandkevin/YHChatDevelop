//
//  YH3DTouch.m
//  PikeWay
//
//  Created by YHIOS002 on 16/12/5.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHWGTouchModel.h"
//#import "YHDynDetailVC.h"

@interface YHWGTouchModel()<UIViewControllerPreviewingDelegate>
@property (nonatomic,weak)UIViewController *previewVC;
@property (nonatomic,strong)YHWorkGroup *model;

@end

@implementation YHWGTouchModel


+ (YHWGTouchModel *)registerForPreviewInVC:(UIViewController *)vc sourceView:(UIView *)sourceView model:(YHWorkGroup *)model{
   
    YHWGTouchModel *obj = [YHWGTouchModel new];
    obj.previewVC = vc;
    obj.model = model;
    if (kSystemVersion > 9.0) {
        if (vc.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            DDLog(@"3D Touch  可用!");
            [vc registerForPreviewingWithDelegate:obj sourceView:sourceView];
        } else {
//            DDLog(@"3D Touch 无效");
        }
    }
    return obj;
}

#pragma mark - 3DTouch
//peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    
    //设定预览的界面
//    YHDynDetailVC *chidVC = [[YHDynDetailVC alloc] initWithWorkGroup:self.model];
//    chidVC.preferredContentSize = CGSizeMake(0,SCREEN_HEIGHT-64);
//    
//    
//    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
//    CGRect rect = CGRectMake(0, 0, chidVC.view.frame.size.width,500);
//    previewingContext.sourceRect = rect;
//
//    //返回预览界面
//    return chidVC;
    return nil;
}

//pop（按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [_previewVC.navigationController pushViewController:viewControllerToCommit animated:YES];
}


- (void)dealloc{
//    DDLog(@"YH3DTouch dealloc");
}

@end
