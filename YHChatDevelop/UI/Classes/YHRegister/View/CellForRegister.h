//
//  CellForRegister.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/4/23.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellForRegister : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgvDownArrow;//下拉箭头

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cstTextFieldTrailing;//输入框右边距离约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cstBotLineLeading;//底线左边距离约束

@property (weak, nonatomic) IBOutlet UITextField *textField;   //输入框
@property (weak, nonatomic) IBOutlet UIView *viewBotLine; //底部分隔线
@property (copy, nonatomic) NSString *strPlaceHolder;//textField的占位字符串

+ (instancetype)cell;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)resetCell;
@end
