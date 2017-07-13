//
//  YHChatDetailVC.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  聊天详情

#import <UIKit/UIKit.h>
#import "YHChatListModel.h"
#import "YHExpressionKeyboard.h"
#import "YHVoiceHUD.h"
#import "YHChatHeader.h"

@interface YHChatDetailVC : UIViewController

/******父类的属性*********/
//控件
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) YHExpressionKeyboard *keyboard;
@property (nonatomic,strong) YHVoiceHUD *imgvVoiceTips;

//数据
@property (nonatomic,strong) YHChatHelper *chatHelper;
@property (nonatomic,assign) BOOL showCheckBox;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) YHChatListModel *model; //note:必要参数


/******父类的方法*********/
- (void)setupExpKeyBoard;    //设置表情键盘
- (void)setupMsg;            //设置消息
- (void)loadChatLogFromCacheComplete:(void(^)(BOOL success, id obj))complete;                //从缓存加载聊天记录
- (void)refreshTableViewLoadNew:(YHRefreshTableView *)view;

@end
