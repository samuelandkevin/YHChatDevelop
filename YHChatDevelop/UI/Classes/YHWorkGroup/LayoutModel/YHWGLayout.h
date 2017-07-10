//
//  YHWGLayout.h
//  PikeWay
//
//  Created by YHIOS002 on 17/3/24.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYKit.h"

@interface YHWGLayout : NSObject

@property (nonatomic, assign, readonly) CGFloat shrinkTextHeight; //未展开文本高度
@property (nonatomic, assign, readonly) CGFloat fullTextHeight;//展开全文高度
@property (nonatomic, strong) YYTextLayout *textLayout;    //默认状态文本
@property (nonatomic, strong) YYTextLayout *fullTextLayout;//全文文本
@property (nonatomic, assign, readonly) CGFloat designatedTextHeight;//指定文本高度
@property (nonatomic, assign, readonly) BOOL shouldShowMore;//文本超过指定高度

- (void)layoutWithText:(NSString *)text;

@end
