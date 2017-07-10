//
//  YHChatModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHChatModel.h"
#import "NSObject+YHDBRuntime.h"


@implementation YHChatModel

#pragma mark - 数据库操作
+ (NSString *)yh_primaryKey{
    return @"chatId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"chatId":YHDB_PrimaryKey};
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

#pragma mark - Public Method
- (YHChatTextLayout *)textLayout{
    CGFloat addFontSize     = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    UIColor *textColor      = [UIColor blackColor];
    UIColor *matchTextColor = UIColorHex(527ead);
    UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
    if (_direction == 0) {
        textColor                 = [UIColor whiteColor];
        matchTextColor            = [UIColor greenColor];
        matchTextHighlightBGColor = [UIColor grayColor];
    }
    if (_msgType == YHMessageType_Text) {
        YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
        [layout layoutWithText:_msgContent fontSize:(14+addFontSize) textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
        _layout = layout;
    }
    return _layout;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeight = 0;
    }
    return self;
}


@end


@implementation YHAudioModel


@end

