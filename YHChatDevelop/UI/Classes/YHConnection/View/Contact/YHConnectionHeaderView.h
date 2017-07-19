//
//  YHConnectionHeaderView.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/31.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  通讯录头部视图

#import <UIKit/UIKit.h>

@interface YHConnectionHeaderView : UIView

@property (nonatomic,copy) NSArray <NSString *>*itemNameArray;
@property (nonatomic,copy) NSArray <NSString *>*iconNameArray;
@property (nonatomic,copy) NSArray <NSNumber *>*unReadMsgArray;

@property (nonatomic,strong) UITableView *tableView;
- (void)didSelectRowHandler:(void(^)(NSIndexPath *indexPath))handler;
@end
