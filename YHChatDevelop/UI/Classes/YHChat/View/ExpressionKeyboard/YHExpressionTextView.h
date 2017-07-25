//
//  YHExpressionTextView.h
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/7/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHExpressionTextView : UITextView

@property(nullable, nonatomic,copy)   NSString    *placeholder;
@property(nullable, nonatomic,copy)   UIFont *placeholderFont;
@property (nonatomic,copy  ) NSString *emoticon;
@property (nonatomic,strong) NSMutableArray <NSString *>*emoticonArray;
//删除表情
- (void)deleteEmoticon;

@end
