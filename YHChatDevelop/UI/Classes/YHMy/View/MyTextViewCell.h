//
//  MyTextViewCell.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/11.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"

@interface MyTextViewCell : UITableViewCell

@property(nonatomic,strong) IQTextView * textView;

@property(nonatomic,strong) UILabel * count;

@end
