//
//  SqliteManager+Fris.m
//  PikeWay
//
//  Created by YHIOS002 on 17/1/3.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "SqliteManager+Fris.h"



@implementation SqliteManager (Fris)


#pragma mark - Private
//第一次建我的好友表
- (CreatTable *)_firstCreatFrisQueueWithFriID:(NSString *)friID{
    
    
    NSString *pathMyFri = pathFrisWithDir(YHFrisDir, friID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:YHFrisDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHFrisDir]) {
            [fileM createDirectoryAtPath:YHFrisDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    DDLog(@"-----数据库操作路径------\n%@",pathMyFri);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathMyFri];
    
    if (queue) {
        
        //存ID和队列
        model.Id = friID;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameFris(friID);
        NSString *userSql = [YHUserInfo yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *weSql = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *sqlArr = nil;
        if (userSql && weSql && eeSql) {
            sqlArr = @[userSql,weSql,eeSql];
        }
        
        if (sqlArr) {
            model.sqlCreatTable = sqlArr;
        }
        
        [self.myFrisArray addObject:model];
    }
    return model;
}

- (CreatTable *)_setupFrisDBqueueWithFriID:(NSString *)friID{
    //是否已存在Queue
    for (CreatTable *model in self.myFrisArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:friID]) {
            
#ifdef DEBUG
            
            NSString *pathLog = pathFrisWithDir(YHFrisDir, friID);
            DDLog(@"-----数据库操作路径------\n%@",pathLog);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建我的好友表
    return [self creatFrisTableWithfriID:friID];
}

#pragma mark - 我的好友
//建我的好友表
- (CreatTable *)creatFrisTableWithfriID:(NSString *)friID{
    
    CreatTable *model = [self _firstCreatFrisQueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    NSArray *sqlArr    = model.sqlCreatTable;
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

//更新Fris表多条信息
- (void)updateFrisListWithFriID:(NSString *)friID frislist:(NSArray <YHUserInfo *>*)frislist complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameFris(friID);
        for (int i= 0; i< frislist.count; i++) {
            
            YHUserInfo *model = frislist[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    if (i == frislist.count-1) {
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

//更新某个好友信息
- (void)updateOneFri:(YHUserInfo *)aFri updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete{
    
    if (!aFri.uid) {
        complete(NO,@"friID is nil");
        return;
    }
    NSString *myID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupFrisDBqueueWithFriID:myID];
    FMDatabaseQueue *queue = model.queue;
    
    NSDictionary *otherSQL = nil;
    if (updateItems) {
        otherSQL = @{YHUpdateItemKey:updateItems};
    }
    
    
    [queue inDatabase:^(FMDatabase *db) {
        /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
        [db yh_saveDataWithTable:tableNameFris(myID)  model:aFri userInfo:nil otherSQL:otherSQL option:^(BOOL save) {
            complete(save,nil);
        }];
        
    }];
}

//查询某个好友信息
- (void)queryOneFriWithID:(NSString *)friID complete:(void (^)(BOOL success,id obj))complete{
    
    NSString *myID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupFrisDBqueueWithFriID:myID];
    FMDatabaseQueue *queue = model.queue;
    
    YHUserInfo *friInfo = [YHUserInfo new];
    friInfo.uid = friID;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithTable:tableNameFris(myID) model:friInfo userInfo:nil fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
            if (output_model) {
                complete(YES,output_model);
            }else{
                complete(NO,@"can not find user in dataBase");
            }
            
        }];
    }];
    
    
}

//查询Fris表
- (void)queryFrisTableWithFriID:(NSString *)friID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
        FMDatabaseQueue *queue = model.queue;
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameFris(friID) model:[YHUserInfo new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(YES,models);
                });
                
            }];
        }];
    });
    
}


//查询多个好友
- (void)queryFrisWithfriIDs:(NSArray<NSString *> *)friIDs complete:(void (^)(NSArray *successUserInfos,NSArray *failUids))complete{
    __block NSMutableArray *successArr = [NSMutableArray new];
    __block NSMutableArray *failArr    = [NSMutableArray new];
    for (NSString *friID in friIDs) {
        [self queryOneFriWithID:friID complete:^(BOOL success, id obj) {
            if (success) {
                if (obj) {
                    [successArr addObject:obj];
                }
                
            }else{
                
                [failArr addObject:friID];
            }
        }];
    }
    complete(successArr,failArr);
    
    
}

//删除Fris表
- (void)deleteFrisTableWithFriID:(NSString *)friID complete:(void(^)(BOOL success,id obj))complete{
    
    NSString *pathFris = pathFrisWithDir(YHFrisDir, friID);
    BOOL success = [self _deleteFileAtPath:pathFris];
    if (success) {
        
        for (CreatTable *model in self.myFrisArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:friID]) {
                [self.myFrisArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
    
}

//删除某一好友
- (void)deleteOneFriWithfriID:(NSString *)friID fri:(YHUserInfo *)fri userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithTable:tableNameFris(friID) model:fri userInfo:userInfo otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
}


//删除多个好友
- (void)deleteFrisWithFriID:(NSString *)friID frisList:(NSArray <YHUserInfo *>*)frisList complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupFrisDBqueueWithFriID:friID];
    FMDatabaseQueue *queue = model.queue;
    
    for (YHUserInfo *model in frisList) {
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_deleteDataWithTable:tableNameFris(friID) model:model userInfo:nil otherSQL:nil option:^(BOOL del) {
            }];
        }];
    }
    
}



@end
