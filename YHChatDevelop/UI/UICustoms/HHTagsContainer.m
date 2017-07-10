//
//  HHTagsContainer.m
//  YHSOFT
//
//  Created by kun on 16/4/20.
//  Copyright © 2016年 kun Co.,Ltd. All rights reserved.
//

#import "HHTagsContainer.h"
//#import "HHUICommon.h"


const float c_labelHorizontalMargin = 6.0f;
const float c_labelVerticalMargin = 3.0f;
const float c_tagHorizontalMargin = 10.0f;
const float c_tagVerticalMargin = 6.0f;
const float c_tagBorderHeight   = 0;

@interface HHTagsContainer () {
//    NSArray *_arrayTagsTitle;
}

@end

@implementation HHTagsContainer

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [self initVariable];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initVariable];
}

- (void)initVariable {
    _tagTitleFontSize = 12.0f;
    _labelHorizontalMargin = c_labelHorizontalMargin;
    _labelVerticalMargin = c_labelVerticalMargin;
    _tagHorizontalSpace = c_tagHorizontalMargin;
    _tagVerticalSpace = c_tagVerticalMargin;
    _tagBorderHeight  = c_tagBorderHeight;
    _tagTouchable    = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setShowBackground:(BOOL)showBackground {
    _showBackground = showBackground;
}

-(void)setTagsTitle:(NSArray*)arr {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.totalHeight = 0;
    _tagsTitle = arr;
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:_tagTitleFontSize]};
    __block CGRect previousFrame = CGRectZero;
    if (_tagAlignment == NSTextAlignmentRight) previousFrame = CGRectMake(self.bounds.size.width, 0, 0, 0);
    __block CGRect btnSize = CGRectZero;
    [arr enumerateObjectsUsingBlock:^(NSString*str, NSUInteger idx, BOOL *stop) {
        
        UIButton*tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.frame    = CGRectZero;
        
        if (_showBackground) {
            if (self.tagBackground) {
                tagBtn.backgroundColor          = self.tagBackground;
            }else{
                tagBtn.backgroundColor          = [UIColor colorWithRed:240/250.0 green:240/250.0 blue:240/250.0 alpha:1.0];
            }
        }
        
        if (!_tagTouchable) tagBtn.enabled      = NO;
        else tagBtn.userInteractionEnabled      = YES;
        
        [tagBtn setTitleColor:_titleColor==nil?kBlueColor:_titleColor forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        tagBtn.titleLabel.font          = [UIFont systemFontOfSize:_tagTitleFontSize];
        
        [tagBtn setTitle:str forState:UIControlStateNormal];
        tagBtn.tag = 10 + idx;
        tagBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        if(_tagBorderColor){
            tagBtn.layer.borderColor   = _tagBorderColor.CGColor;
        }else{
            tagBtn.layer.borderColor    = kBlueColor.CGColor;
        }
        
//        tagBtn.layer.borderWidth    = 0.3;
        
        [self addSubview:tagBtn];
        [tagBtn addTarget:self action:@selector(onTagButton:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize Size_str = [str sizeWithAttributes:attrs];
        Size_str.width  += _labelHorizontalMargin * 2;
        Size_str.height += _labelVerticalMargin * 2;
        
        CGRect newRect = CGRectZero;
        
        if (_tagAlignment == NSTextAlignmentLeft) {
            tagBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            if (previousFrame.origin.x + previousFrame.size.width + Size_str.width + _tagHorizontalSpace > self.bounds.size.width) {
                newRect.origin = CGPointMake(_tagHorizontalSpace, previousFrame.origin.y + Size_str.height + _tagVerticalSpace);
                _totalHeight += Size_str.height + _tagVerticalSpace;
            }
            else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + _tagHorizontalSpace, previousFrame.origin.y);
            }
        }
        else {
            tagBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            if (previousFrame.origin.x - Size_str.width - _tagHorizontalSpace < 0) {
                newRect.origin = CGPointMake(self.bounds.size.width - _tagHorizontalSpace - Size_str.width, previousFrame.origin.y + Size_str.height + _tagVerticalSpace);
                _totalHeight += Size_str.height + _tagVerticalSpace;
            }
            else {
                newRect.origin = CGPointMake(previousFrame.origin.x - Size_str.width - _tagHorizontalSpace, previousFrame.origin.y);
            }
        }
        
        newRect.size    = Size_str;
        
        [tagBtn setFrame:newRect];
        tagBtn.layer.borderWidth    = _tagBorderHeight;
        if (_showTagCorner) {
            tagBtn.layer.cornerRadius   = newRect.size.height * 0.5;
            tagBtn.layer.masksToBounds  = YES;
        }
        
        
        previousFrame   = tagBtn.frame;
        btnSize = newRect;
        
    }];
    
    _totalHeight = _totalHeight + btnSize.size.height + _tagVerticalSpace;
    CGRect tempFrame = self.frame;
    tempFrame.size.height = _totalHeight;
    self.frame = tempFrame;
    
}

- (float)estimateViewHeightWithTitles:(NSArray *)titles {
    if (!titles || titles.count == 0) {
        return 0;
    }
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:_tagTitleFontSize]};
    __block CGRect previousFrame = CGRectZero;
    __block float   estimateHeight = 0;
    
    [titles enumerateObjectsUsingBlock:^(NSString * str, NSUInteger idx, BOOL * stop) {
        
        CGSize Size_str = [str sizeWithAttributes:attrs];
        Size_str.width += _labelHorizontalMargin * 2;
        Size_str.height += _labelVerticalMargin * 2;
        
        CGRect newRect = CGRectZero;
        if (previousFrame.origin.x + previousFrame.size.width + Size_str.width + _tagHorizontalSpace > self.bounds.size.width) {
            newRect.origin = CGPointMake(_tagHorizontalSpace, previousFrame.origin.y + Size_str.height + _tagVerticalSpace);
            estimateHeight += Size_str.height + _tagVerticalSpace;
        }
        else {
            newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + _tagHorizontalSpace, previousFrame.origin.y);
        }
        
        newRect.size    = Size_str;
        previousFrame   = newRect;
        
        if (idx == titles.count - 1) {
            estimateHeight = estimateHeight + newRect.size.height + _tagVerticalSpace;
        }
    }];
//    DLog(@"est %f wid %f , %@", estimateHeight, self.bounds.size.width, titles);
    return estimateHeight;
}


- (void)onTagButton:(UIButton *)btn {
    DDLog(@"click %ld", (long)btn.tag);
    if (_didSelectTagBlock) _didSelectTagBlock((int)btn.tag);
}

@end
