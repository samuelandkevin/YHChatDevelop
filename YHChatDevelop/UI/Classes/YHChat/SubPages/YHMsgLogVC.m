//
//  YHMsgLogVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/7/10.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHMsgLogVC.h"

@implementation YHMsgLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" target:self selector:@selector(onMore:) block:^(UIButton *btn) {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"取消" forState:UIControlStateSelected];
        [btn setTitle:@"更多" forState:UIControlStateNormal];
    }];
    
}

#pragma mark - Super Method
//设置表情键盘
- (void)setupExpKeyBoard{

}

//设置消息
- (void)setupMsg{

}

//从缓存加载聊天记录
- (void)loadChatLogFromCacheComplete:(void (^)(BOOL, id))complete{
    WeakSelf
    [super loadChatLogFromCacheComplete:^(BOOL success, id obj) {
        [weakSelf.tableView scrollToBottomAnimated:NO];
    }];

}


#pragma mark - private


#pragma mark - Action
- (void)onMore:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.showCheckBox = sender.selected? YES:NO;
    [self.tableView reloadData];
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
