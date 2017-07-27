//
//  YHIndicatorButton.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/7.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHIndicatorButton.h"

@implementation YHIndicatorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        if (!_indicator) {
            _indicator = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width * 0.6, 2)];
            _indicator.backgroundColor = [UIColor colorWithRed:19/255.0 green:157/255.0 blue:84/255.0 alpha:1];
            _indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _indicator.center = CGPointMake(self.bounds.size.width * 0.5, _indicator.center.y);
        }
        [self addSubview:_indicator];
    }
    else {
        [_indicator removeFromSuperview];
    }
    
}




@end
