//
//  CardDetailViewController.h
//  MyProject
//
//  Created by samuelandkevin on 16/4/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  名片详情控制器（可显示自己或好友的名片详情）

#import "YHUserInfo.h"
#import "YHChatListModel.h"

@interface CardDetailViewController : UIViewController

@property (nonatomic,assign) BOOL isFromScanVC;//从扫一扫进入
@property (nonatomic,strong) YHChatListModel *model;
- (instancetype)initWithUserInfo:(YHUserInfo *)userInfo;
- (instancetype)initWithUserId:(NSString *)userId;

@end
