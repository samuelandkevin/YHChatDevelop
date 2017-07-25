//
//  YHWorkGroup.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/5.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHWorkGroup.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
//#import "YHSerializeKit.h"
//#import "CellForWorkGroupRepost.h"
#import "NSObject+YHDBRuntime.h"


extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;
extern CGFloat maxContentRepostLabelHeight;
extern const CGFloat kMarginContentLeft;
extern const CGFloat kMarginContentRight;

@interface YHWorkGroup()


@end

@implementation YHWorkGroup
{
    CGFloat _lastContentWidth;
}

//缓存方式二:文件缓存

//YHSERIALIZE_CODER_DECODER();
//
//YHSERIALIZE_COPY_WITH_ZONE();

//YHSERIALIZE_DESCRIPTION();


#pragma mark - Private

#pragma mark - YHFMDB
+ (NSString *)yh_primaryKey{
    return @"dynamicId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"dynamicId":YHDB_PrimaryKey};
}


+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return @{@"userInfo":[NSString stringWithFormat:@"userInfo%@",YHDB_AppendingID],
             @"forwardModel":[NSString stringWithFormat:@"forwardModel%@",YHDB_AppendingID]};
}

+ (NSDictionary *)yh_getClassForKeyIsObject{
    return @{@"userInfo":[YHUserInfo class],
             @"forwardModel":[YHWorkGroup class]
             };
}

+ (NSArray *)yh_propertyDonotSave{
    return @[@"contentW",@"lastContentWidth",@"isOpening",@"shouldShowMoreButton",@"showDeleteButton",@"hiddenBotLine",@"layout"];
}

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return @{@"originalPicUrls":[NSURL class],
             @"thumbnailPicUrls":[NSURL class]};
}


@end

