//
//  CellForRegister2.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/23.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellForRegister2 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnNext; //下一步
@property (nonatomic,copy) void(^onNextBlock)();//点击"下一步"回调
+ (instancetype)cell;

@end
