//
//  YHCellWave.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/4/19.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  波浪效果Cell

#import <UIKit/UIKit.h>

@interface YHCellWave : UITableViewCell

- (void)startAnimation:(void(^)(BOOL finished))complete;
@end
