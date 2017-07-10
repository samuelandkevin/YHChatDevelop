//
//  HHTagsContainer.h
//  YHSOFT
//
//  Created by kun on 16/4/20.
//  Copyright © 2016年 kun Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHTagsContainer : UIView {
    NSArray *_tagsTitle;
}

/** tag的title字号 */
@property (nonatomic, assign)   int tagTitleFontSize;
@property (nonatomic, strong)   UIColor     *titleColor;

/** 此容器(View)可以容纳所有tag的最小高度 */
@property (nonatomic, assign)   int totalHeight;

/** 当前tags的标题数组 */
@property (nonatomic, strong)   NSArray *tagsTitle;
/**
 *  是否显示标签的背影框，默认不显示
 */
@property (nonatomic, assign)   BOOL    showBackground;

/* 标签是否需要响应点击事件 */
@property (nonatomic, assign)   BOOL    tagTouchable;

/**
 * 标签的对齐方式（目前只支持左-NSTextAlignmentLeft， 右-NSTextAlignmentRight）
 */
@property (nonatomic, assign)   NSTextAlignment     tagAlignment;
//
// 需要先设置以下4个属性，以确定各tag间的距离.否则使用默认的间距
//
@property (nonatomic, assign)   float   labelHorizontalMargin;
@property (nonatomic, assign)   float   labelVerticalMargin;
@property (nonatomic, assign)   float   tagHorizontalSpace;
@property (nonatomic, assign)   float   tagVerticalSpace;

/**
 *  标签背景颜色
 */
@property (nonatomic, strong)   UIColor *tagBackground;

/**
 *  标签边框颜色
 */
@property (nonatomic, strong)   UIColor *tagBorderColor;
/**
 *  标签边框高度
 */
@property  (nonatomic,assign)   float    tagBorderHeight;
/**
 *  显示标签圆角
 */
@property  (nonatomic,assign)   BOOL     showTagCorner;

/**
 * 接收点击消息block
 * @param tagid 点击的tag的id，id = 10 + index(在TagsTitle所设置数组的下标）
 */
@property (nonatomic,copy)      void (^didSelectTagBlock)(int tagid);


/** 
 * 设置一组tag的标题
 * @param arr NSString类型 代表tag的title
 */
- (void)setTagsTitle:(NSArray*)arr;

/** 根据titles估算最小的高度（刚好可以容纳所有标签） */
- (float)estimateViewHeightWithTitles:(NSArray *)titles;

#pragma mark - private

- (void)onTagButton:(UIButton *)btn;

@end
