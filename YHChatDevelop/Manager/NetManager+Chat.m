//
//  NetManager+Chat.m
//  PikeWay
//
//  Created by YHIOS002 on 16/10/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NetManager+Chat.h"
#import "YHUnReadMsg.h"
#import "YHProtocolConfig.h"
#import "YHUserInfoManager.h"
#import "DataParser.h"
#import "NetManager.h"

@implementation NetManager (Chat)

//发起群聊
- (void)postCreatGroupChatWithUserArray:(NSArray<YHUserInfo *>*)userArray complete:(NetManagerCallback)complete{

    NSString *baseUrl = kBaseURL;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",baseUrl,kPathCreatGroupChat];
     requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@",[YHUserInfoManager sharedInstance].userInfo.accessToken]];
    
    NSMutableArray *maParams = [NSMutableArray new];
    for (YHUserInfo *userInfo in userArray) {

        NSDictionary *dict =[NSDictionary new];
        if (!userInfo.userName.length) {
            userInfo.userName = @"匿名用户";
        }
        if(!userInfo.uid.length){
            complete(NO,@"uid is nil");
            return;
        }
        dict = @{
                 @"memberName":userInfo.userName,
                 @"memberUserId":userInfo.uid
                 };
        [maParams addObject:dict];
    }

    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestUrl]];
    //设置请求超时
    request.timeoutInterval = 8;
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:maParams options:0 error:nil];
    request.HTTPBody = data;

    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //创建session配置对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
   
    //创建session对象
   
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    //添加网络任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            DDLog(@"请求失败...");
            complete(NO,error);
        }else{

            NSDictionary *jsonObj = nil;
            if([self canParseResponseObject:data jsonObj:&jsonObj requestUrl:requestUrl]){
                
                if([self isRequestSuccessWithJsonObj:jsonObj])
                {
                    complete(YES,jsonObj[@"data"]);
                }
                else
                {
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

//添加群成员
- (void)postAddGroupMemberWithGroupId:(NSString *)groupId userArray:(NSArray<YHUserInfo *>*)userArray complete:(NetManagerCallback)complete{
    
    if (!groupId.length) {
        complete(NO,@"groupId is nil!");
        return;
    }
   
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathAddGroupMember];
    requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@",[YHUserInfoManager sharedInstance].userInfo.accessToken]];
    
    NSMutableArray *maParams = [NSMutableArray new];
    for (YHUserInfo *userInfo in userArray) {
        
        NSDictionary *dict =[NSDictionary new];
        if (!userInfo.userName.length) {
            userInfo.userName = @"匿名用户";
        }
        if(!userInfo.uid.length){
            complete(NO,@"uid is nil");
            return;
        }
        dict = @{
                 @"memberName":userInfo.userName,
                 @"memberUserId":userInfo.uid,
                 @"groupId":groupId
                 };
        [maParams addObject:dict];
    }
    
    
    //创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:requestUrl]];
    //设置请求超时
    request.timeoutInterval = 8;
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:maParams options:0 error:nil];
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
                
                if([self isRequestSuccessWithJsonObj:jsonObj])
                {
                    complete(YES,jsonObj[@"data"]);
                }
                else
                {
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

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{


        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __block NSURLCredential *credential = nil;
        //判断服务器返回的证书是否是服务器信任的
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            /*disposition：如何处理证书
             NSURLSessionAuthChallengePerformDefaultHandling:默认方式处理
             NSURLSessionAuthChallengeUseCredential：使用指定的证书    NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消请求
             */
            
            if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
        //安装证书
        if (completionHandler) {
            completionHandler(disposition, credential);
        }
    

}

//获取聊天历史记录
- (void)postFetchChatLogWithType:(QChatType)chatType sessionID:(NSString *)sessionID timestamp:(NSString *)timestamp complete:(NetManagerCallback)complete{

     NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathGetChatLog];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"token is nil");
        return;
    }
    
    if (!sessionID) {
        complete(NO,@"sessionID is nil");
        return;
    }
    
    //
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary: @{ @"audienceId":sessionID,                                                        @"isGroupChat":@(chatType),@"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken                                                          }];
    if (timestamp) {
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
        [dataFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dataFormatter dateFromString:timestamp];
        NSTimeInterval cursor = [date timeIntervalSince1970];
        [dict setObject:@(cursor) forKey:@"cursor"];
    }
   

    //由于时间关系,后台返回数据格式跟之前不一样 
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        return;
    }
    

    [self.requestManager  POST:requestUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *parseJsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&parseJsonError];
        if (parseJsonError) {
            return complete(NO,parseJsonError.localizedDescription);
        }
        else {
            //数组
            if ([jsonObject isKindOfClass:[NSArray class]] ){
                NSArray *obj = (NSArray *)jsonObject;
                NSArray *logArr = [[DataParser shareInstance] parseChatLogWithListData:obj];
                complete(YES,logArr);
                
            }else{
                complete(NO,@"return data is not array format");
            }
        }

        
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                       
        complete(NO,error);
    }];
}


//获取未读消息
- (void)postFetchUnReadMsgComplete:(NetManagerCallback)complete{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathUnReadMsg];
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"token is nil");
        return;
    }
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken
                           };
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {

        if (success) {
            
            //1.返回参数判断
            NSDictionary *jsonObj = obj;
            id dictData  = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSDictionary *dict = dictData;
            YHUnReadMsg *model = [YHUnReadMsg new];
            model.groupChat   = [dict[@"group_cuout"] intValue];
            model.privateChat = [dict[@"private_count"] intValue];
            model.newFri      = [dict[@"new_friend_count"] intValue];
            complete(YES,model);
            
        }else{
            complete(success,obj);
        }
       
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//获取群聊列表
- (void)getGroupChatListComplete:(NetManagerCallback)complete{
    
     NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathGetGroupChatList];
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"token is nil");
        return;
    }
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken
                           };
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            //1.返回参数判断
            NSDictionary *jsonObj = obj;
            id dictData  = jsonObj[@"data"];
            if ([dictData isKindOfClass:[NSArray class]]) {
                NSArray *temp = dictData;
                NSArray *retArr = [[DataParser shareInstance] parseGroupListWithListData:temp];
                complete(YES,retArr);
                
            }else{
                complete(NO,kServerReturnEmptyData);
            }
            
        }else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *downloadProgress) {
        
    }];
}


//群发送消息 (mark:接口设置了消息只能单发)
- (void)postSendChatMsgWithArray:(NSArray<YHChatModel*>*)array complete:(NetManagerCallback)complete;{
    
    //已经发送消息的数量
    __block NSUInteger hasSendMsgCount = 0;
    //发送失败的用户ID
    __block NSMutableArray *receiverIDofSendFail = [NSMutableArray array];
    for(YHChatModel *model in array){
        NSString *rID = model.audienceId;
        int msgType   = model.msgType;
        NSString *msg = model.msgContent;
        int chatType  = model.chatType;
        [self postSendChatMsgToReceiverID:rID msgType:msgType msg:msg chatType:chatType complete:^(BOOL success, id obj) {
            hasSendMsgCount ++;
            if (hasSendMsgCount == array.count) {
                if (receiverIDofSendFail.count) {
                    complete(NO,receiverIDofSendFail);
                }else{
                    complete(YES,@"群发消息成功");
                }
                
            }else{
                if (!success) {
                    [receiverIDofSendFail addObject:rID];
                }
            }
        }];
    }
    
}

//单发消息
- (void)postSendChatMsgToReceiverID:(NSString *)rID msgType:(int)msgType msg:(NSString *)msg chatType:(QChatType)chatType complete:(NetManagerCallback)complete{

    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathSendChatMsg];
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"token is nil");
        return;
    }
    if (!rID) {
         complete(NO,@"receiverID is nil");
        return;
    }
    if (!msg) {
        msg = @"";
    }
    BOOL isGroupChat = NO;
    if (chatType == QChatType_Group) {
        isGroupChat = YES;
    }
    
    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           @"audienceId":rID,
                           @"content":msg,
                           @"isGroupChat":@(isGroupChat),
                           @"msgType":@(msgType)
                           };
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        // 。。。。后台没有返回错误码,判断请求成功与失败特殊处理。
        if([obj isKindOfClass:[NSError class]]){
            //网络问题导致请求失败
            complete(NO,obj);
        }else{
            if(obj){
                complete(YES,obj);
            }else{
                complete(NO,obj);
            }
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//获取聊天列表
- (void)postFetchChatListWithTimestamp:(NSString *)timestamp type:(QChatType)type complete:(NetManagerCallback)complete{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathGetChatList];
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"token is nil");
        return;
    }
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken}];
    if(type != QChatType_All){
        [dict setObject:@(type) forKey:@"type"];
    }
    
    
    if (timestamp) {
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
        [dataFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dataFormatter dateFromString:timestamp];
        NSTimeInterval cursor = [date timeIntervalSince1970];
        [dict setObject:@(cursor) forKey:@"cursor"];
    }else{
        NSTimeInterval cursor = [[NSDate date] timeIntervalSince1970];
        [dict setObject:@(cursor) forKey:@"cursor"];
    }
    
    //由于时间关系,后台返回数据格式跟之前不一样
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        return;
    }
    
    [self.requestManager GET:requestUrl parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *parseJsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&parseJsonError];
        if (parseJsonError) {
            return complete(NO,parseJsonError.localizedDescription);
        }
        else {
            //数组
            if ([jsonObject isKindOfClass:[NSArray class]] ){
                NSArray *obj = (NSArray *)jsonObject;
                NSArray *logArr = [[DataParser shareInstance] parseChatListWithListData:obj];
                complete(YES,logArr);
                
            }else{
                complete(NO,@"return data is not array format");
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         complete(NO,error);
    }];
   
}

//消息置顶/取消置顶
- (void)postMsgStick:(BOOL)msgStick msgID:(NSString *)msgID complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,msgStick?kPathMsgStick:kPathMsgCancelStick];
    
    if (!msgID) {
        complete(NO,@"msgID is nil");
        return;
    }
    requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/%@",msgID]];

    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"token is nil");
        return;
    }

    NSDictionary *dict = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken};
    
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        return;
    }
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            complete(YES,obj);
        }else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//获取群成员
- (void)getGroupMemebersWithGroupID:(NSString *)groupID complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathGroupMembers];
    
    if (!groupID) {
        complete(NO,@"groupID is nil");
        return;
    }
    
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"token is nil");
        return;
    }
    
    NSDictionary *dict = @{@"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           };

    requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/%@",groupID]];
    [self getWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            //1.返回参数判断
            NSDictionary *jsonObj = obj;
            id dictData  = jsonObj[@"data"];
            if ([dictData isKindOfClass:[NSArray class]]) {
                NSArray *temp = dictData;
                NSArray *retArr = [[DataParser shareInstance] parseGroupMembersWithList:temp];
                complete(YES,retArr);
                
            }else{
                complete(NO,kServerReturnEmptyData);
            }
        }else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];
    
}

//删除会话
- (void)postDeleteSessionWithID:(NSString *)sessionID sessionUserID:(NSString *)sessionUserID complete:(NetManagerCallback)complete{

    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathDeleteSession];
    
    if (!sessionID) {
        complete(NO,@"sessionID is nil");
        return;
    }
    
    if (!sessionUserID) {
        complete(NO,@"sessionUserID is nil");
        return;
    }
    
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"token is nil");
        return;
    }
    
    NSDictionary *dict = @{@"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                          };
    requestUrl = [requestUrl stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",sessionID,sessionUserID]];
    
    [self postWithRequestUrl:requestUrl parameters:dict complete:^(BOOL success, id obj) {
        if (success) {
            complete(YES,obj);
        }else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

    
}

@end
