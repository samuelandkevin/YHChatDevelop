//
//  ChineseString.h
//  samuelandkevin
//
//  Created by admin on 15/12/17.
//  Copyright © 2015年 Dope Beats Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChineseString : NSObject

@property(nonatomic,copy)NSString *string; //中文字符串（eg:郭靖）
@property(nonatomic,copy)NSString *pinYin; //拼音写法  （eg:GJ）

@end
