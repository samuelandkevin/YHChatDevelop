//
//  DataManager.h
//  FMDBDemo
//
//  Created by YHIOS002 on 16/11/2.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHChatModel.h"
#import "FMDB.h"
#import "NSObject+YHDBRuntime.h"
#import "FMDatabase+YHDatabase.h"
#import "YHSqilteConfig.h"

//建表
@interface CreatTable : NSObject

@property (nonatomic,copy) NSString *Id;
@property (nonatomic,strong) FMDatabaseQueue *queue;
@property (nonatomic,copy) NSArray <NSString *> *sqlCreatTable;
@property (nonatomic,assign) int type;

@end

@interface SqliteManager : NSObject


typedef NS_ENUM(int,DBChatType){
    DBChatType_Group = 101, //群聊
    DBChatType_Private      //单聊
};


@property(nonatomic,strong) NSMutableArray < CreatTable *>*loginAcountArray;//登录账户Array
@property(nonatomic,strong) NSMutableArray < CreatTable *>*chatLogArray; //聊天Array
@property(nonatomic,strong) NSMutableArray < CreatTable *>*myFrisArray;  //我的好友Array
@property(nonatomic,strong) NSMutableArray < CreatTable *>*dynsArray; //动态Array
@property(nonatomic,strong) NSMutableArray < CreatTable *>*visitorsArray;//访客Array
@property(nonatomic,strong) NSMutableArray <CreatTable *>*officeFileArray;//聊天文件表（暂时只有一个Sql表）
@property(nonatomic,strong) NSMutableArray <CreatTable *>*chatListArray;//聊天列表Array


+ (instancetype)sharedInstance;

#pragma mark - 退出登录
/*
 *  退出登录清除缓存
 */
- (void)clearCacheWhenLogout;

#pragma mark - 登录用户信息

/**
 更新登录用户信息
 @param updateItems <#updateItems description#>
 @param complete 成功失败回调
 */
- (void)updateUserInfoWithItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete;


/**
 获取登录用户信息
 
 @param complete 成功失败回调
 */
- (void)getLoginUserInfoWithUid:(NSString *)uid complete:(void (^)(BOOL success,id obj))complete;



#pragma mark - filePrivate
/*
 *  删除指定路径文件
 */
- (BOOL)_deleteFileAtPath:(NSString *)filePath;

@end
