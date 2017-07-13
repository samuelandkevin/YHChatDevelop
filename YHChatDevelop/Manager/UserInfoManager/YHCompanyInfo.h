//
//  YHCompanyInfo.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/5/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  企业用户Model

#import <Foundation/Foundation.h>

@interface YHCompanyInfo : NSObject

@property (nonatomic,copy) NSString *uid;    //企业用户ID
@property (nonatomic,copy) NSString *baseUrl;//企业首页
@property (nonatomic,copy) NSString *createDate;
@property (nonatomic,copy) NSString *expireDate;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *shortName;
@property (nonatomic,assign) int status;
@property (nonatomic,copy) NSString *updateDate;

@end
