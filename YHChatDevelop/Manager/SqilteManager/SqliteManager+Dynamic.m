//
//  SqliteManager+Dynamic.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/4.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "SqliteManager+Dynamic.h"
#import "YHExpressionHelper.h"
@implementation SqliteManager (Dynamic)



#pragma mark - Private
//第一次建动态表
- (CreatTable *)_firstCreatDynQueueWithTag:(int)dynTag userID:(NSString *)userID{
    
    
    NSString *dir = nil;
    NSString *strID = userID;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        dir = [userID isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid] ? YHMyDynDir : YHFrisDynsDir;
    }else{
        //公共的动态标签
        dir = YHPublicDynDir;
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    
    NSString *pathDyn = pathDynWithDir(dir, strID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:dir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHDynDir]) {
            [fileM createDirectoryAtPath:YHDynDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:dir]) {
            [fileM createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    DDLog(@"-----数据库操作路径------\n%@",pathDyn);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathDyn];
    
    if (queue) {
        
        //存ID和队列
        model.Id = userID;
        model.queue = queue;
        model.type = dynTag;
        
        //存SQL语句
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        NSString *dynSql  = [YHWorkGroup yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *userSql = [YHUserInfo yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *forwardDynSql = [YHWorkGroup yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *weSql   = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql   = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *arrSql   = nil;
        if (dynSql && userSql && forwardDynSql && weSql && eeSql) {
            arrSql = @[dynSql,userSql,forwardDynSql,weSql,eeSql];
        }
        if (arrSql) {
            model.sqlCreatTable = arrSql;
        }
        
        [self.dynsArray addObject:model];
    }
    return model;
}

- (CreatTable *)_setupDynDBqueueWithTag:(int)dynTag userID:(NSString *)userID{
    //是否已存在Queue
    for (CreatTable *model in self.dynsArray) {
        NSString *aID = model.Id;
        int aTag      = model.type;
        if ([aID isEqualToString:userID] && aTag == dynTag) {
            
#ifdef DEBUG
            
            NSString *dir = nil;
            NSString *strID = userID;
            if (dynTag < 0) {
                //我的动态 / 好友动态
                dir = [userID isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid] ? YHMyDynDir : YHFrisDynsDir;
            }else{
                //公共的动态标签
                dir = YHPublicDynDir;
                strID = [NSString stringWithFormat:@"public%d",dynTag];
            }
            
            NSString *pathDyn = pathDynWithDir(dir, strID);
            
            DDLog(@"-----数据库操作路径------\n%@",pathDyn);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建动态表
    return [self creatDynTableWithTag:dynTag userID:userID];
}

//根据类型删除动态
- (void)_deleteDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *userID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        
        [db yh_deleteDataWithTable:tableName model:dyn userInfo:nil otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
        
    }];
}

//获取动态表数据条数
- (void)numberOfDynsInTable:(int)dynTag complete:(void(^)(NSInteger count))complete{
    NSString *userID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        [db numberOfDatasWithTable:tableName complete:complete];
    }];
}

#pragma mark - 动态
//建动态表
- (CreatTable *)creatDynTableWithTag:(int)dynTag userID:(NSString *)userID{
    
    CreatTable *model = [self _firstCreatDynQueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    NSArray *sqlArr = model.sqlCreatTable;
    for (NSString *sql in sqlArr) {
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL ok = [db executeUpdate:sql];
            if (ok == NO) {
                DDLog(@"----NO:%@---",sql);
            }
            
        }];
    }
    
    return model;
}


//更新多条动态
- (void)updateDynWithTag:(int)dynTag userID:(NSString *)userID  dynList:(NSArray <YHWorkGroup *>*)dynList complete:(void (^)(BOOL success,id obj))complete{
    
    
    if ([dynList isKindOfClass:[NSArray class]]) {
        if (!dynList.count) {
            complete(NO,@"dynList count is zero");
            return;
        }
    }
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        for (int i= 0; i< dynList.count; i++) {
            
            YHWorkGroup *model = dynList[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    if (i == dynList.count-1) {
                        complete(save,nil);
                    }else{
                        if (!save) {
                            complete(save,@"更新某条数据失败");
                        }
                    }
                    
                }];
                
            }];
        }
    });
    
    
    
}

//查询Dyn表
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID  lastDyn:(YHWorkGroup *)lastDyn length:(int)length complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameDyn(dynTag,userID);
        
        //设置otherSQL
        NSMutableDictionary *otherSQLDict = [NSMutableDictionary dictionary];
        [otherSQLDict setObject:@"order by publishTime desc" forKey:YHOrderKey];
        if (length) {
            [otherSQLDict setObject:@(length) forKey:YHLengthLimitKey];
        }
        
        if (lastDyn.publishTime) {
            NSString *lesserSQL = [NSString stringWithFormat:@" publishTime < '%@'",lastDyn.publishTime];
            [otherSQLDict setObject:lesserSQL forKey:YHLesserKey];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableName model:[YHWorkGroup new] userInfo:nil fuzzyUserInfo:nil otherSQL:otherSQLDict option:^(NSMutableArray *models) {
                
                for (YHWorkGroup *model in models) {
                    YHWGLayout *layout = [[YHWGLayout alloc] init];
                    [layout layoutWithText:model.msgContent];
                    model.layout = layout;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(YES,models);
                });
                
            }];
        }];

    });
    
}


// 模糊/条件查询Dyn表
- (void)queryDynTableWithTag:(int)dynTag userID:(NSString *)userID   userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQLDict:(NSDictionary *)otherSQLDict complete:(void (^)(BOOL success,id obj))complete{
    CreatTable *model = [self _setupDynDBqueueWithTag:dynTag userID:userID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameDyn(dynTag,userID);
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithTable:tableName model:[YHWorkGroup new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:otherSQLDict option:^(NSMutableArray *models) {
            
            for (YHWorkGroup *model in models) {
                YHWGLayout *layout = [[YHWGLayout alloc] init];
                [layout layoutWithText:model.msgContent];
                model.layout = layout;
            }
            complete(YES,models);
        }];
    }];
    
}

//删除Dyn表
- (void)deleteDynTableWithType:(int)dynTag userID:(NSString *)userID complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *dir = nil;
    NSString *strID = userID;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        dir = [userID isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid] ? YHMyDynDir : YHFrisDynsDir;
    }else{
        //公共的动态标签
        dir = YHPublicDynDir;
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    
    NSString *pathDyn = pathDynWithDir(dir, strID);
    BOOL success = [self _deleteFileAtPath:pathDyn];
    if (success) {
        
        for (CreatTable *model in self.dynsArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:userID]) {
                [self.dynsArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
    
}


//删除某一动态
- (void)deleteOneDyn:(YHWorkGroup *)dyn dynTag:(int)dynTag complete:(void(^)(BOOL success,id obj))complete{
    
    if (dynTag >= 0) {
        
        [self _deleteDyn:dyn dynTag:dynTag complete:complete];//删除公共动态标签表
        [self _deleteDyn:dyn dynTag:-1 complete:complete]; //删除我的动态表
    }else{
        
        [self _deleteDyn:dyn dynTag:dynTag complete:complete]; //删除我的动态表
        
        [self _deleteDyn:dyn dynTag:dyn.dynTag complete:complete];//删除公共动态
    }
    
    
}


@end
