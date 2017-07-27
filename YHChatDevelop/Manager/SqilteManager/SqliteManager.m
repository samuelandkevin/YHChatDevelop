//
//  DataManager.m
//  FMDBDemo
//
//  Created by samuelandkevin on 16/11/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "SqliteManager.h"
#import "YHNetManager.h"

@implementation CreatTable

@end

@interface SqliteManager()

@end

@implementation SqliteManager


//设置App数据库
- (void)setupAppDB
{
    
    //判断本地有没有数据库文件
    if ([self _isExistFileAtPath:YHChatLogDir]) {
        //如果存在,那么获取DB版本信息
        int dbVersion = [self _getDbVersion];
        if (dbVersion < 1) {
            [self setDBVersion:1];
        }
        
    }
    
}

+ (instancetype)sharedInstance{
    static SqliteManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[SqliteManager alloc] init];
        
    });
    return g_instance;
}


#pragma mark - Lazy Load

- (NSMutableArray<CreatTable *> *)loginAcountArray{
    if (!_loginAcountArray) {
        _loginAcountArray = [NSMutableArray new];
    }
    return _loginAcountArray;
}

- (NSMutableArray<CreatTable *> *)chatLogArray{
    if (!_chatLogArray) {
        _chatLogArray = [NSMutableArray new];
    }
    return _chatLogArray;
}

- (NSMutableArray<CreatTable *> *)myFrisArray{
    if (!_myFrisArray) {
        _myFrisArray = [NSMutableArray new];
    }
    return _myFrisArray;
}

- (NSMutableArray<CreatTable *> *)dynsArray{
    if (!_dynsArray) {
        _dynsArray = [NSMutableArray new];
    }
    return _dynsArray;
}

- (NSMutableArray<CreatTable *> *)visitorsArray{
    if (!_visitorsArray) {
        _visitorsArray = [NSMutableArray new];
    }
    return _visitorsArray;
}

- (NSMutableArray<CreatTable *> *)officeFileArray{
    if (!_officeFileArray) {
        _officeFileArray = [NSMutableArray new];
    }
    return _officeFileArray;
}

- (NSMutableArray<CreatTable *> *)chatListArray{
    if (!_chatListArray) {
        _chatListArray = [NSMutableArray new];
    }
    return _chatListArray;
}

- (NSMutableArray<CreatTable *> *)chatGroupArray{
    if(!_chatGroupArray){
        _chatGroupArray = [NSMutableArray new];
    }
    return _chatGroupArray;
}

#pragma mark - Private 登录用户

//第一次建登录用户表
- (CreatTable *)_firstCreatLoginAccountQueueWithUserID:(NSString *)userID{
    
    NSString *pathLoginAccount = pathLoginWithDir(YHLoginDir, userID);
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:YHLoginDir]){
        //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHLoginDir]) {
            [fileM createDirectoryAtPath:YHLoginDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
    }
    
    DDLog(@"------LoginAcountDBPath-----\n:%@",pathLoginAccount);
    
    CreatTable *model = [CreatTable new];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathLoginAccount];
    
    if (queue) {
        
        //存ID和队列
        model.Id = userID;
        model.queue = queue;
        
        
        //存SQL语句
        NSString *tableName = tableNameLogin(userID);
        NSString *userSql = [YHUserInfo yh_sqlForCreatTable:tableName primaryKey:@"id"];
        NSString *companySql = [YHCompanyInfo yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSString *weSql = [YHWorkExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id" ];
        NSString *eeSql = [YHEducationExperienceModel yh_sqlForCreateTableWithPrimaryKey:@"id"];
        NSArray *sqlArr = nil;
        if (userSql && companySql && weSql && eeSql) {
            sqlArr = @[userSql,companySql,weSql,eeSql];
        }
        
        if (sqlArr) {
            model.sqlCreatTable = sqlArr;
        }
        
        [self.loginAcountArray addObject:model];
    }
    return model;
}

- (CreatTable *)_setupLoginAcountDBqueueWithUserID:(NSString *)userID{
    //是否已存在Queue
    for (CreatTable *model in self.loginAcountArray) {
        NSString *aID = model.Id;
        if ([aID isEqualToString:userID]) {
            
#ifdef DEBUG
            
            NSString *pathLogin = pathLoginWithDir(YHLoginDir, userID);
            DDLog(@"-----LoginAccountDBPath------%@",pathLogin);
#else
            
#endif
            return model;
            break;
        }
    }
    
    //没有就创建login表
    return [self creatLoginAccountTableWithUserID:userID];
}

#pragma mark - 文件大小
//所有数据库占的总空间
- (unsigned long long)totalSize{
    unsigned long long sizeUserDir = fileSize(YHUserDir);
    return sizeUserDir;
}

//退出登录清除缓存
- (void)clearCacheWhenLogout{
    [self.loginAcountArray removeAllObjects];
    [self.chatLogArray removeAllObjects];
    [self.myFrisArray removeAllObjects];
    [self.dynsArray removeAllObjects];
    [self.visitorsArray removeAllObjects];
    [self.officeFileArray removeAllObjects];
    [self.chatListArray removeAllObjects];
    
    [[NSFileManager defaultManager] removeItemAtPath:YHUserDir error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:YHVisitorsDir error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:YHChatListLogDir error:nil];
}

#pragma mark - 登录用户信息

//建我的好友表
- (CreatTable *)creatLoginAccountTableWithUserID:(NSString *)userID{
    
    CreatTable *model = [self _firstCreatLoginAccountQueueWithUserID:userID];
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

//更新登录用户信息
- (void)updateUserInfoWithItems:(NSArray <NSString *>*)updateItems complete:(void (^)(BOOL success,id obj))complete{
    
    YHUserInfo *loginUserInfo = [YHUserInfoManager sharedInstance].userInfo;
    NSString *myID = loginUserInfo.uid;
    CreatTable *model = [self _setupLoginAcountDBqueueWithUserID:myID];
    FMDatabaseQueue *queue = model.queue;
    
    NSDictionary *otherSQL = nil;
    if (updateItems) {
        otherSQL = @{YHUpdateItemKey:updateItems};
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        /** 存储:会自动调用insert或者update，不需要担心重复插入数据 */
        [db yh_saveDataWithTable:tableNameLogin(myID)  model:loginUserInfo userInfo:nil otherSQL:otherSQL option:^(BOOL save) {
            complete(save,nil);
        }];
        
    }];
    
}

//获取登录用户信息
- (void)getLoginUserInfoWithUid:(NSString *)uid complete:(void (^)(BOOL success,id obj))complete{
    
    CreatTable *model = [self _setupLoginAcountDBqueueWithUserID:uid];
    FMDatabaseQueue *queue = model.queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db yh_excuteDataWithTable:tableNameLogin(uid) model:[YHUserInfoManager sharedInstance].userInfo userInfo:nil fuzzyUserInfo:nil otherSQL:nil option:^(id output_model) {
            if (output_model) {
                complete(YES,output_model);
            }else{
                complete(NO,@"can not find user in dataBase");
            }
            
        }];
    }];
    
}


#pragma mark - filePrivate
- (BOOL)_deleteFileAtPath:(NSString *)filePath{
    if (!filePath || filePath.length == 0) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDLog(@"delete file error, %@ is not exist!", filePath);
        return NO;
    }
    NSError *removeErr = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeErr] ) {
        DDLog(@"delete file failed! %@", removeErr);
        return NO;
    }
    return YES;
}

- (BOOL)_isExistFileAtPath:(NSString *)filePath{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDLog(@" %@ is not exist!", filePath);
        return NO;
    }
    return YES;
}

- (int)_getDbVersion {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:kDatabaseVersionKey];
}

- (void)setDBVersion:(int)version{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:kDatabaseVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
