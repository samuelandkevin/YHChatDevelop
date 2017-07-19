//
//  YHChatTableView.h
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/14.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YHChatTableViewDelegate <NSObject>

@optional
- (void)loadMoreData;//下拉加载更多

@end

@interface YHChatTableView : UITableView

@property(nonatomic,weak)id<YHChatTableViewDelegate> refreshDelegate;

//开始加载
- (void)loadBegin;
//结束加载
- (void)loadFinish;
//没有更多数据
- (void)setNoMoreData;
@end
