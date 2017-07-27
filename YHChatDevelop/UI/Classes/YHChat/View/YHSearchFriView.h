//
//  SearchFriView.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@protocol YHSearchFriViewDelegate <NSObject>

- (void)didSelSearchFri:(BOOL)didSel userArray:(NSArray *)userArray;
@optional
- (void)scrollViewWillBeginDragging;
@end


@interface YHSearchFriView : UIView
@property (nonatomic,strong) NSMutableArray <YHUserInfo *>*dataArray;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,weak) id <YHSearchFriViewDelegate>delegate;

@end
