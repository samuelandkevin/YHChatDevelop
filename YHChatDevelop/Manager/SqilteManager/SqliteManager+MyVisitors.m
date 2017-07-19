//
//  SqliteManager+MyVisitors.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/10.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "SqliteManager+MyVisitors.h"

@implementation SqliteManager (MyVisitors)


#pragma mark - 我的访客
//建我的访客表
- (CreatTable *)creatVistorsTableWithIntervieweeID:(NSString *)intervieweeID{
    
    CreatTable *model = [self _firstCreatVistorsQueueWithIntervieweeID:intervieweeID];
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

- (void)updateMyVisitorsList:(NSArray <YHUserInfo *>*)vistorsList complete:(void (^)(BOOL success,id obj))complete{
    NSString * intervieweeID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupMyVisitorsDBqueueWithIntervieweeID:intervieweeID];
    FMDatabaseQueue *queue = model.queue;
    
    NSString *tableName = tableNameVisitors(intervieweeID);
    for (int i= 0; i< vistorsList.count; i++) {
        
        YHUserInfo *model = vistorsList[i];
        
        [queue inDatabase:^(FMDatabase *db) {
            /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
            [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                if (i == vistorsList.count-1) {
                    complete(save,nil);
                }else{
                    if (!save) {
                        complete(save,@"更新某条数据失败");
                    }
                }
                
            }];
            
        }];
    }
    
}

//查询我的访客表
- (void)queryMyVisitorsTableWithLastData:(YHUserInfo *)lastData length:(int)length complete:(void (^)(BOOL success,id obj))complete{
    
    NSString *intervieweeID = [YHUserInfoManager sharedInstance].userInfo.uid;
    CreatTable *model = [self _setupMyVisitorsDBqueueWithIntervieweeID:intervieweeID];
    FMDatabaseQueue *queue = model.queue;
    
    
    //设置otherSQL
    NSMutableDictionary *otherSQLDict = [NSMutableDictionary dictionary];
    [otherSQLDict setObject:@"order by visitTime desc" forKey:YHOrderKey];
    if (length) {
        [otherSQLDict setObject:@(length) forKey:YHLengthLimitKey];
    }
    
    if (lastData.visitTime) {
        NSString *lesserSQL = [NSString stringWithFormat:@" visitTime < '%@'",lastData.visitTime];
        [otherSQLDict setObject:lesserSQL forKey:YHLesserKey];
    }
    
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDatasWithTable:tableNameVisitors(intervieweeID) model:[YHUserInfo new] userInfo:nil fuzzyUserInfo:nil otherSQL:otherSQLDict option:^(NSMutableArray *models) {
            complete(YES,models);
        }];
    }];
}


#pragma mark - Private

//第一次建我的好友表
- (CreatTable *)_firstCreatVistorsQueueWithIntervieweeID:(NSString *)intervieweeID{
    
    NSString *pathVisitors = pathVistorsWithDir(YHVisitorsDir, intervieweeID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:YHVisitorsDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHCacheDir]) {
            [fileM createDirectoryAtPath:YHCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHVisitorsDir]) {
            [fileM createDirectoryAtPath:YHVisitorsDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    DDLog(@"------VistorsDBPath-----:%@",pathVisitors);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathVisitors];
    
    if (queue) {
        
        //存ID和队列
        model.Id = intervieweeID;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameVisitors(intervieweeID);
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
        
        [self.visitorsArray addObject:model];
    }
    return model;
}


- (CreatTable *)_setupMyVisitorsDBqueueWithIntervieweeID:(NSString *)intervieweeID{
    //是否已存在Queue
    for (CreatTable *model in self.visitorsArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:intervieweeID]) {
            
#ifdef DEBUG
            
            NSString *pathVisitors = pathVistorsWithDir(YHVisitorsDir, intervieweeID);
            DDLog(@"-----vistorsDBPath------%@",pathVisitors);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建我的好友表
    return [self creatVistorsTableWithIntervieweeID:intervieweeID];
}

@end
