//
//  YHSynthesisSearch.h
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHWorkGroup.h"
#import "YHUserInfo.h"

@interface YHSynthesisSearch : NSObject

@property (nonatomic,strong) NSMutableArray <YHWorkGroup*>* dynArray;//动态
@property (nonatomic,strong) NSMutableArray <YHUserInfo*>* friArray;//好友
@property (nonatomic,strong) NSMutableArray <YHUserInfo*>* conArray;//人脉
@property (nonatomic,assign) NSIndexPath *selIndexPath;

+ (instancetype)shareInstance;

@end
