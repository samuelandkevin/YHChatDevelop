//
//  SearchFriView.h
//  PikeWay
//
//  Created by YHIOS002 on 16/10/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
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
