//
//  SqliteManager+Chat.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/6/23.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "SqliteManager+Chat.h"

@implementation SqliteManager (Chat)

#pragma mark - 聊天记录
//建聊天表
- (CreatTable *)creatChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID{
    
    CreatTable *model = [self _firstCreatChatLogQueueWithType:type sessionID:sessionID];
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


//更新多条聊天信息
- (void)updateChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID chatLogList:(NSArray <YHChatModel *>*)chatLogList complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameChatLog(sessionID);
        for (int i= 0; i< chatLogList.count; i++) {
            
            YHChatModel *model = chatLogList[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (i == chatLogList.count-1) {
                            if (complete) {
                                complete(save,nil);
                            }
                        }else{
                            if (!save && complete) {
                                complete(save,@"更新某条数据失败");
                            }
                        }
                    });
                }];
                
            }];
        }
 
    });
    
    
}

//更新某条聊天信息
- (void)updateOneChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID aChatLog:(YHChatModel*)aChatLog updateItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = model.queue;
    
    NSDictionary *otherSQL = nil;
    if (updateItems) {
        otherSQL = @{YHUpdateItemKey:updateItems};
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
        [db yh_saveDataWithTable:tableNameChatLog(sessionID)  model:aChatLog userInfo:nil otherSQL:otherSQL option:^(BOOL save) {
            complete(save,nil);
        }];
        
    }];
}


//查询ChatLog表
- (void)queryChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
        FMDatabaseQueue *queue = model.queue;
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameChatLog(sessionID) model:[YHChatModel new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(YES,models);
                    }
                });
            }];
        }];
    });
}

//查询ChatLog表   按长度length获取聊天记录
- (void)queryChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID  lastChatLog:(YHChatModel *)lastChatLog length:(int)length complete:(void (^)(BOOL success,id obj))complete{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
        FMDatabaseQueue *queue = model.queue;
        
        //设置otherSQL
        NSMutableDictionary *otherSQLDict = [NSMutableDictionary dictionary];
        [otherSQLDict setObject:@"order by createTime desc" forKey:YHOrderKey];
        if (length) {
            [otherSQLDict setObject:@(length) forKey:YHLengthLimitKey];
        }
        
        if (lastChatLog.createTime) {
            NSString *lesserSQL = [NSString stringWithFormat:@" createTime < '%@'",lastChatLog.createTime];
            [otherSQLDict setObject:lesserSQL forKey:YHLesserKey];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameChatLog(sessionID) model:[YHChatModel new] userInfo:nil fuzzyUserInfo:nil otherSQL:otherSQLDict option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([models isKindOfClass:[NSArray class]] && models.count >1 ) {
                        [models sortUsingComparator:^NSComparisonResult(YHChatModel *obj1, YHChatModel *obj2) {
                            return NSOrderedDescending;
                        }];
                    }
                    
                    for (YHChatModel *model in models) {
                        model.layout = [model textLayout];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) {
                            complete(YES,models);
                        }
                    });
                });
            }];
        }];
    });

}


//查询多条聊天信息
- (void)queryChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID list:(NSArray<YHChatModel *>*)chatLogList complete:(void (^)(BOOL, id))complete{
    
    CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = model.queue;
    
    __block NSMutableArray *maRet = [NSMutableArray new];
    for (YHChatModel *model in chatLogList) {
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDataWithTable:tableNameChatLog(sessionID) model:model userInfo:nil fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
                if (output_model) {
                    [maRet addObject:output_model];
                }
            }];
        }];
    }
    complete(YES,maRet);
    
}

//查询一条聊天信息
- (void)queryaChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID aChatLog:(YHChatModel *)aChatLog userInfo:(NSDictionary *)userInfo complete:(void (^)(BOOL, id))complete{
    
    CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithTable:tableNameChatLog(sessionID) model:aChatLog userInfo:userInfo fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
            complete(YES,output_model);
        }];
        
    }];
}

//删除聊天信息数组
- (void)deleteChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID list:(NSArray <YHChatModel *>*)chatLogList complete:(void(^)(BOOL success,id obj))complete;{
    
    CreatTable *model1 = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = model1.queue;
    
    for (YHChatModel *model in chatLogList) {
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_deleteDataWithTable:tableNameChatLog(sessionID) model:model userInfo:nil otherSQL:nil option:^(BOOL del) {
            }];
        }];
    }
    
}

//删除某条消息记录
- (void)deleteOneChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID msgID:(NSString *)msgID complete:(void(^)(BOOL success,id obj))complete{
    
    if (!msgID) {
        complete(NO,@"msgID is nil");
        return;
    }
    
    CreatTable *cmodel     = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = cmodel.queue;
    YHChatModel *model = [YHChatModel new];
    model.chatId       = msgID;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithTable:tableNameChatLog(sessionID) model:model userInfo:nil otherSQL:nil option:^(BOOL del) {
            complete(del,nil);
        }
         ];
    }];
}

//删除ChatLog表
- (void)deleteChatLogTableWithType:(DBChatType)type sessionID:(NSString *)sessionID complete:(void(^)(BOOL success,id obj))complete{
    
    switch (type) {
        case DBChatType_Group:{
            
            NSString *pathLog = pathLogWithDir(GroupChatLogDir, sessionID);
            BOOL success = [self _deleteFileAtPath:pathLog];
            if (success) {
                
                for (CreatTable *model in self.chatLogArray) {
                    NSString *aID = model.Id;
                    if ([aID isEqualToString:sessionID]) {
                        [self.chatLogArray removeObject:model];
                        break;
                    }
                }
                
            }
            complete(success,nil);
        }
            break;
        case DBChatType_Private:{
            
            NSString *pathLog = pathLogWithDir(PriChatLogDir, sessionID);
            BOOL success = [self _deleteFileAtPath:pathLog];
            if (success) {
                
                for (CreatTable *model in self.chatLogArray) {
                    NSString *aID = model.Id;
                    if ([aID isEqualToString:sessionID]) {
                        [self.chatLogArray removeObject:model];
                        break;
                    }
                }
            }
            complete(success,nil);
            
        }
            
        default:
            break;
    }
    
    
    
}

//删除某一聊天信息
- (void)deleteaChatLogWithType:(DBChatType)type sessionID:(NSString *)sessionID aChatLog:(YHChatModel *)aChatLog userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupDBqueueWithType:type sessionID:sessionID];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithTable:tableNameChatLog(sessionID) model:aChatLog userInfo:userInfo otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
}

#pragma mark - 聊天列表

//建聊天列表表
- (CreatTable *)creatChatListTableWithUid:(NSString *)uid{
    
    CreatTable *model = [self _firstChatListTableWithUid:uid];
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


/*
 *  更新ChatList表多条信息
 */
- (void)updateChatListModelArr:(NSArray <YHChatListModel *>*)chatListModelArr uid:(NSString *)uid complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupChatListDBqueueWithUid:uid];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameChatList(uid);
        
        for (int i= 0; i< chatListModelArr.count; i++) {
            
            YHChatListModel *model = chatListModelArr[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    if (i == chatListModelArr.count-1) {
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

//删除ChatList表某条信息
- (void)deleteOneChatListModel:(YHChatListModel *)clModel uid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete{
    CreatTable *model = [self _setupChatListDBqueueWithUid:uid];
    FMDatabaseQueue *queue = model.queue;
    NSString *tableName = tableNameChatList(uid);
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db yh_deleteDataWithTable:tableName model:clModel userInfo:nil otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
    
}


//查询ChatList表
- (void)queryChatListTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    NSString *uid = [YHUserInfoManager sharedInstance].userInfo.uid;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupChatListDBqueueWithUid:uid];
        FMDatabaseQueue *queue = model.queue;
        
        //设置otherSQL
        NSMutableDictionary *otherSQLDict = [NSMutableDictionary dictionary];
        [otherSQLDict setObject:@"order by isStickTop desc" forKey:YHOrderKey];//消息置顶
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameChatList(uid) model:[YHChatListModel new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(YES,models);
                });
            }];
        }];
    });
}

//删除ChatLog表
- (void)deleteChatListTableWithUid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete{
    NSString *pathChatList = pathChatListLogWithDir(YHChatListLogDir, uid);
    BOOL success = [self _deleteFileAtPath:pathChatList];
    if (success) {
        
        for (CreatTable *model in self.chatListArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:uid]) {
                [self.chatListArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
}


#pragma mark - 聊天文件
//建办公文件表
- (CreatTable *)creatFileTable{
    
    CreatTable *model = [self _firstCreatOfficeQueue];
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

//更新某一个办公文件
- (void)updateOfficeFile:(YHFileModel *)officeFile complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupOfficeFileDBqueue];
        FMDatabaseQueue *queue = model.queue;
        NSString *tableName = tableNameOfficeFile();
        
        [queue inDatabase:^(FMDatabase *db) {
            /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
            [db yh_saveDataWithTable:tableName model:officeFile userInfo:nil otherSQL:nil option:^(BOOL save) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(save,nil);
                });
            }];
            
        }];
    });
    
    
}

//查询办公文件
- (void)queryOfficeFilesUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupOfficeFileDBqueue];
        FMDatabaseQueue *queue = model.queue;
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameOfficeFile() model:[YHFileModel new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(YES,models);
                });
                
            }];
        }];
    });
    
}

//查询某个文件
- (void)queryOneOfficeFileWithFileNameInserver:(NSString *)fileNameInserver complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupOfficeFileDBqueue];
        FMDatabaseQueue *queue = model.queue;
        YHFileModel *fileModel = [YHFileModel new];
        fileModel.filePathInServer = fileNameInserver;
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDataWithTable:tableNameOfficeFile() model:fileModel userInfo:nil fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (output_model) {
                        complete(YES,output_model);
                    }else{
                        complete(NO,@"can not find user in dataBase");
                    }
                });
                
            }];
        }];
    });
}

//删除办公文件表
- (void)deleteOfficeFileTableComplete:(void(^)(BOOL success,id obj))complete{
    NSString *path = pathOfficeFileWithDir(OfficeDir);
    BOOL success = [self _deleteFileAtPath:path];
    if (success) {
        [self.officeFileArray removeAllObjects];
    }
    complete(success,nil);
}

//删除某一个办公文件
- (void)deleteOneOfficeFile:(YHFileModel *)officeFile userInfo:(NSDictionary *)userInfo complete:(void(^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupOfficeFileDBqueue];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_deleteDataWithTable:tableNameOfficeFile() model:officeFile userInfo:userInfo otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
}

#pragma mark - 讨论组

//建讨论组列表表
- (CreatTable *)creatGroupListTableWithUid:(NSString *)uid{
    
    CreatTable *model = [self _firstGroupListTableWithUid:uid];
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


/*
 *  更新GroupList表
 */
- (void)updateGroupList:(NSArray <YHChatGroupModel *>*)groupList uid:(NSString *)uid complete:(void (^)(BOOL success,id obj))complete{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupGroupListDBqueueWithUid:uid];
        FMDatabaseQueue *queue = model.queue;
        
        NSString *tableName = tableNameGroupList(uid);
        
        for (int i= 0; i< groupList.count; i++) {
            
            YHChatGroupModel *model = groupList[i];
            
            [queue inDatabase:^(FMDatabase *db) {
                /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
                [db yh_saveDataWithTable:tableName model:model userInfo:nil otherSQL:nil option:^(BOOL save) {
                    if (i == groupList.count-1) {
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

//删除某个群
- (void)deleteOneGroupModel:(YHChatGroupModel *)groupModel uid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete{
    CreatTable *model = [self _setupGroupListDBqueueWithUid:uid];
    FMDatabaseQueue *queue = model.queue;
    NSString *tableName = tableNameGroupList(uid);
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db yh_deleteDataWithTable:tableName model:groupModel userInfo:nil otherSQL:nil option:^(BOOL del) {
            complete(del,@(del));
        }];
    }];
    
}


/*
 *  查询GroupList表
 */
- (void)queryGroupListTableWithUserInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo complete:(void (^)(BOOL success,id obj))complete{
    
    NSString *uid = [YHUserInfoManager sharedInstance].userInfo.uid;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CreatTable *model = [self _setupGroupListDBqueueWithUid:uid];
        FMDatabaseQueue *queue = model.queue;
        
        [queue inDatabase:^(FMDatabase *db) {
            [db yh_excuteDatasWithTable:tableNameGroupList(uid) model:[YHChatGroupModel new] userInfo:userInfo fuzzyUserInfo:fuzzyUserInfo otherSQL:nil option:^(NSMutableArray *models) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(YES,models);
                });
            }];
        }];
    });
    
}

/*
 *  删除GroupList表
 */
- (void)deleteGroupListTableWithUid:(NSString *)uid complete:(void(^)(BOOL success,id obj))complete{
    NSString *pathGroupList = pathGroupListWithDir(GroupListDir, uid);
    BOOL success = [self _deleteFileAtPath:pathGroupList];
    if (success) {
        
        for (CreatTable *model in self.chatGroupArray) {
            NSString *aID = model.Id;
            if ([aID isEqualToString:uid]) {
                [self.chatGroupArray removeObject:model];
                break;
            }
        }
        
    }
    complete(success,nil);
}



#pragma mark - Private 聊天记录
//初始化聊天FMDBQueue
- (CreatTable *)_setupDBqueueWithType:(DBChatType)type sessionID:(NSString *)sessionID{
    
    if (!sessionID) {
        return nil;
    }
    //是否已存在Queue
    for (CreatTable *model in self.chatLogArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:sessionID]) {
            
#ifdef DEBUG
            NSString *dir = nil;
            switch (type) {
                case DBChatType_Group:
                    dir = GroupChatLogDir;
                    break;
                case DBChatType_Private:
                    dir = PriChatLogDir;
                    break;
                default:
                    break;
            }
            
            NSString *pathLog = pathLogWithDir(dir, sessionID);
            DDLog(@"-----数据库操作路径------\n%@",pathLog);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建聊天表
    return [self creatChatLogTableWithType:type sessionID:sessionID];
    
}

//第一次建聊天表
- (CreatTable *)_firstCreatChatLogQueueWithType:(DBChatType)type sessionID:(NSString *)sessionID{
    
    NSString *dir = nil;
    switch (type) {
        case DBChatType_Group:{
            dir = GroupChatLogDir;
        }
            break;
        case DBChatType_Private:{
            dir = PriChatLogDir;
        }
            
        default:
            break;
    }
    
    NSString *pathLog = pathLogWithDir(dir, sessionID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:dir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatLogDir]){
            [fileM createDirectoryAtPath:YHChatLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:dir]){
            [fileM createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    DDLog(@"-----数据库操作路径------\n%@",pathLog);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathLog];
    
    if (queue) {
        
        //存ID和队列
        model.Id = sessionID;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameChatLog(sessionID);
        NSString *chatSql = [YHChatModel yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *picSql = [YHPicModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSString *fileSql = [YHFileModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSString *gifSql  = [YHGIFModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSString *checkinSql = [YHCheckinModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        if (picSql && chatSql && fileSql && gifSql && checkinSql) {
            model.sqlCreatTable = @[picSql,chatSql,fileSql,gifSql,checkinSql];
        }
        
        [self.chatLogArray addObject:model];
    }
    return model;
}

#pragma mark - Private 聊天列表
- (CreatTable *)_setupChatListDBqueueWithUid:(NSString *)uid{
    //是否已存在Queue
    for (CreatTable *model in self.chatListArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:uid]) {
            
#ifdef DEBUG
            
            NSString *pathChatList = pathChatListLogWithDir(YHChatListLogDir, uid);
            DDLog(@"-----chatListDBPath------%@",pathChatList);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建我的好友表
    return [self creatChatListTableWithUid:uid];
}


//第一次建chatList表
- (CreatTable *)_firstChatListTableWithUid:(NSString *)uid{
    
    NSString *pathChatList = pathChatListLogWithDir(YHChatListLogDir, uid);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:YHChatListLogDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHDocumentDir]) {
            [fileM createDirectoryAtPath:YHDocumentDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatLogDir]) {
            [fileM createDirectoryAtPath:YHChatLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatListLogDir]) {
            [fileM createDirectoryAtPath:YHChatListLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    DDLog(@"------ChatListDBPath-----:%@",pathChatList);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathChatList];
    
    if (queue) {
        
        //存ID和队列
        model.Id    = uid;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameChatList(uid);
        NSString *chatListSql = [YHChatListModel yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSArray *sqlArr = nil;
        if (chatListSql) {
            sqlArr = @[chatListSql];
        }
        
        if (sqlArr) {
            model.sqlCreatTable = sqlArr;
        }
        
        [self.chatListArray addObject:model];
    }
    return model;
}



#pragma mark - Private 办公文件
//第一次建聊天表
- (CreatTable *)_firstCreatOfficeQueue{
    
    NSString *dir = OfficeDir;
    NSString *pathLog = pathOfficeFileWithDir(OfficeDir);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:dir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:OfficeDir]){
            [fileM createDirectoryAtPath:OfficeDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    DDLog(@"-----数据库操作路径------\n%@",pathLog);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathLog];
    
    if (queue) {
        
        //存ID和队列
        
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameOfficeFile();
        NSString *creatTableSql = [YHFileModel yh_sqlForCreatTable:tableName primaryKey:@"id"];
        if (creatTableSql) {
            model.sqlCreatTable = @[creatTableSql];
        }
        
        [self.officeFileArray addObject:model];
    }
    return model;
}

//设置办公文件队列
- (CreatTable *)_setupOfficeFileDBqueue{
    //是否已存在Queue
    NSString *pathLog = pathOfficeFileWithDir(OfficeDir);
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:pathLog];
    if (self.officeFileArray.count) {
        
        if (exist) {
#ifdef DEBUG
            DDLog(@"-----数据库操作路径------\n%@",pathLog);
            return self.officeFileArray[0];
#else
            
#endif
        }else{
            [self.officeFileArray removeAllObjects];
        }
        
    }
    
    //没有就创建文件目录表
    return [self creatFileTable];
}


#pragma mark - Private 讨论组列表
- (CreatTable *)_setupGroupListDBqueueWithUid:(NSString *)uid{
    //是否已存在Queue
    for (CreatTable *model in self.chatGroupArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:uid]) {
            
#ifdef DEBUG
            
            NSString *pathGroupList = pathGroupListWithDir(GroupListDir, uid);
            DDLog(@"-----groupListDBPath------\n%@",pathGroupList);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建我的好友表
    return [self creatGroupListTableWithUid:uid];
}


//第一次建GroupList表
- (CreatTable *)_firstGroupListTableWithUid:(NSString *)uid{
    
    NSString *pathGroupList = pathGroupListWithDir(GroupListDir, uid);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:GroupListDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHDocumentDir]) {
            [fileM createDirectoryAtPath:YHDocumentDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatLogDir]) {
            [fileM createDirectoryAtPath:YHChatLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:GroupListDir]) {
            [fileM createDirectoryAtPath:GroupListDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    DDLog(@"------GroupListDBPath-----\n:%@",pathGroupList);
    
    CreatTable *model = [[CreatTable alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathGroupList];
    
    if (queue) {
        
        //存ID和队列
        model.Id    = uid;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameGroupList(uid);
        NSString *chatGroupSql = [YHChatGroupModel yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSArray *sqlArr = nil;
        if (chatGroupSql) {
            sqlArr = @[chatGroupSql];
        }
        
        if (sqlArr) {
            model.sqlCreatTable = sqlArr;
        }
        
        [self.chatGroupArray addObject:model];
    }
    return model;
}




@end
