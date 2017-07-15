//
//  YHConnectionSearchView.h
//  PikeWay
//
//  Created by YHIOS002 on 16/10/31.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHUserInfo.h"

@protocol YHConnectionSearchViewDelegate <NSObject>

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath userInfo:(YHUserInfo *)userInfo;
- (void)scrollViewWillBeginDragging;
@end

@interface YHConnectionSearchView : UIView
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy) NSArray *dataArray;
@property (nonatomic,weak) id<YHConnectionSearchViewDelegate>delegate;
@end
