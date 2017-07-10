//
//  NetManager+Connections.m
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NetManager+Connections.h"


@implementation NetManager (Connections)

//请求添加好友
- (void)postAddFriendwithFriendId:(NSString *)friendId complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathAddFriend];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if (!friendId) {
        complete(NO,@"好友Id为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"uid":friendId//被加好友Id
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//请求删除好友
- (void)postDeleteFriendWithFrinedId:(NSString *)friendId complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathDeleteFriend];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                           @"uid":friendId  //被删好友Id
                           };
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//获取新的好友
- (void)postNewAddFriendsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathNewFriends];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                           @"count":@(count),
                           @"page":@(currentPage)
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            NSDictionary *jsonObj  = obj;
            id dictData = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *newFriendsArray = dictData[@"newFriends"];
            
            //新的好友Model
            NSMutableArray *maNewFriendsModel = nil;
            if (newFriendsArray && [newFriendsArray isKindOfClass:[NSArray class]]) {
                
                maNewFriendsModel = [NSMutableArray arrayWithCapacity:newFriendsArray.count];
                for (int i = 0; i <[newFriendsArray count]; i++) {
                    NSDictionary *dict = newFriendsArray[i];
                    YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:dict curReqPage:currentPage isSelf:NO];
                    [maNewFriendsModel addObject:userInfo];
                }
                
            }
            else
            {
                maNewFriendsModel = [NSMutableArray array];
            }
            
            //回调的字典
            NSDictionary *dictRet = @{
                                      @"newFriends" :maNewFriendsModel,
                                      @"total"      :dictData[@"total"],
                                      @"count"      :dictData[@"count"]
                                      
                                      };
            
            
            complete(YES,dictRet);
            
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//获取我的好友
- (void)postMyFriendsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathMyFriends];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                           @"count":@(count),
                           @"page":@(currentPage)
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success) {
            NSDictionary *jsonObj    = obj;
            id dictData   = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray *newFriendsArray = dictData[@"friends"];
            
            //我的好友Model
            NSMutableArray *maFriendsModel = nil;
            if (newFriendsArray && [newFriendsArray isKindOfClass:[NSArray class]]) {
                
                maFriendsModel = [NSMutableArray arrayWithCapacity:newFriendsArray.count];
                for (int i = 0; i <[newFriendsArray count]; i++) {
                    NSDictionary *dict = newFriendsArray[i];
                    YHUserInfo *userInfo = [[DataParser shareInstance] parseUserInfo:dict curReqPage:currentPage isSelf:NO];
                    [maFriendsModel addObject:userInfo];
                }
                
            }
            else
            {
                maFriendsModel = [NSMutableArray array];
            }
            
            //回调的字典
            NSDictionary *dictRet = @{
                                      @"friends" :maFriendsModel,
                                      @"total"   :dictData[@"total"],
                                      };
            
            
            complete(YES,dictRet);
        }
        else
        {
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
}

//访问名片详情
- (void)getVisitCardDetailWithTargetUid:(NSString *)tagretUid complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathVisitCardDetail];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if (!tagretUid) {
        complete(NO,@"访问的用户Id为nil");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"userId":tagretUid,
                           @"vid":[YHUserInfoManager sharedInstance].userInfo.uid
                           };
    
    
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success) {
            
            NSDictionary *jsonObj    = obj;
            id dictData   = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSDictionary *dictPerson = dictData[@"account"];
            
            YHUserInfo *userInfo     = [[DataParser shareInstance] parseUserInfo:dictPerson curReqPage:0 isSelf:NO];
            complete(YES,userInfo);
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
}

//其他用户与我的关系查询
- (void)postGetRelationAboutMeWithUserIds:(NSArray *)userIds complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathRelationWithMe];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if (!userIds || !userIds.count) {
        complete(NO,@"其他用户Id为nil");
        return;
    }
    
    NSString *userIdsStr = [userIds componentsJoinedByString:@","];
    if (!userIdsStr) {
        userIdsStr = @"";
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"uids":userIdsStr,
                           @"vid":[YHUserInfoManager sharedInstance].userInfo.uid
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success) {
            id dictData =  [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray *userStatus = dictData[@"friends"];
            //userStauts数组元素是NSDictionary,有 status，uId两个key
            //status :0 已申请 1 已添加
            //uId    :
            
            complete(YES,userStatus);
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
}

//接受加好友请求
- (void)postAcceptAddFriendRequest:(NSString *)applicantId complete:(NetManagerCallback)complete
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathAcceptAddFriendReq];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken || ![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户id 或 token 不能为空");
        return;
    }
    if (!applicantId) {
        complete(NO,@"申请人Id为nil");
        return;
    }
    
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"uid":applicantId,
                           
                           };
    
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success) {
            NSDictionary *dictData =  [obj objectForKey:@"data"];
            NSArray *userStatus = dictData[@"friends"];
            //userStauts数组元素是NSDictionary,有 status，uId两个key
            //status :0 已申请 1 已添加
            //uId    :
            
            complete(YES,userStatus);
            
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
    
}

//查找好友
- (void)postFindFriendsWithKeyWord:(NSString *)keyWord complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathFindFriends];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token为nil");
        return;
    }
    
    if (!keyWord) {
        complete(NO,@"关键字为nil");
        return;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"keyword":keyWord,
                           kRequiedKeyAndValue
                           
                           };
    
    
    __weak typeof(self)weakSelf = self;
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        
        if (success)
        {
            
            NSDictionary *jsonObj    = obj;
            id dictData   = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                //找不到用户
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSDictionary *account = dictData[@"account"];
            NSString *uid         = account[@"id"];
            
            //获取名片信息
            [weakSelf getVisitCardDetailWithTargetUid:uid complete:^(BOOL success, id obj) {
                
                complete(success,obj);
                
            }];
            
        }
        else
        {
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
        
    }];
    
}

//获取某用户的账号信息（手机号和税道账号）
- (void)getUserAccountWithUserId:(NSString *)userId complete:(NetManagerCallback)complete{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathGetUserAccount];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken ){
        complete(NO,@"用户token 不能为空");
        return;
    }
    
    if (!userId) {
        complete(NO,@"用户Id为nil!");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"id":userId,
                             kRequiedKeyAndValue
                             };
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success) {
            
            NSDictionary *jsonObj = obj;
            //1.条件判断
            id dictData     = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            id userInfoDict = dictData[@"account"];
            if (![userInfoDict isKindOfClass:[NSDictionary class]]) {
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            if (!userInfoDict) {
                complete(NO,@"用户信息为nil!");
                return ;
            }
            NSString *mobilePhone = userInfoDict[@"mobilePhone"];
            NSString *taxAccount  = userInfoDict[@"userName"];
            if (!mobilePhone) {
                mobilePhone =@"";
            }
            if (!taxAccount) {
                taxAccount = @"";
            }
            
            //3.回调
            complete(YES,@{
                           @"mobilePhone":mobilePhone,
                           @"taxAccount":taxAccount
                           });
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *downloadProgress) {
        
    }];
    
}

//搜索人脉
- (void)getSearchConnectionWithKeyWord:(NSString *)keyWord count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathSearchConnection];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    if (!keyWord) {
        complete(NO,@"keyword为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"count":@(count),
                             @"page" :@(currentPage),
                             @"keyword":keyWord
                             };
    
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success) {
            
            NSDictionary *jsonObj  = obj;
            id dictData = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            
            NSArray  *conArray = dictData[@"accounts"];
            NSArray  *conRetArray = [NSArray new];
            if (conArray.count && [conArray isKindOfClass:[NSArray class]]) {
                conRetArray =  [[DataParser shareInstance] parseUserListWithListData:conArray curReqPage:currentPage];
            }
            
            complete(YES,conRetArray);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//投诉
- (void)postComplainContent:(NSString *)content type:(ComplainType)type targetID:(NSString*)targetID complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathComplain];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(!targetID){
        complete(NO,@"targetID is nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"complainTargetId":targetID,
                             @"content":content,
                             @"complainType" :@(type)
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//修改黑名单
- (void)postModifyBlacklistWithTargetID:(NSString *)targetID add:(BOOL)add complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[YHProtocol share].kBaseURL,[YHProtocol share].kPathModifyBlackList];
    requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@",[YHUserInfoManager sharedInstance].userInfo.accessToken]];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(!targetID){
        complete(NO,@"targetID is nil");
        return;
    }
    
    NSString *enabled = add? @"true":@"false";
    
    NSDictionary *params = @{
                             @"objectId":targetID,
                             @"enabled":enabled
                             };
    
    
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestUrl]];
    //设置请求超时
    request.timeoutInterval = 8;
    request.HTTPMethod = @"POST";
    
    //设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPBody = data;
    
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //创建session配置对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //创建session对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    //添加网络任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            complete(NO,error);
        }else{
            
            NSDictionary *jsonObj = nil;
            if([self canParseResponseObject:data jsonObj:&jsonObj requestUrl:requestUrl]){
                
                if([self isRequestSuccessWithJsonObj:jsonObj]){
                    
                    complete(YES,jsonObj[@"data"]);
                }
                else{
                    complete(NO,jsonObj);
                }
            }
            else{
                complete(NO,kParseError);
            }
            
        }
    }];
    
    [task resume];
    
}


@end
