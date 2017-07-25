//
//  NetManager+WorkGroup.m
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//


#import "NetManager+WorkGroup.h"
#import "YHChatDevelop-Swift.h"

@implementation NetManager (WorkGroup)

#pragma mark - Prviate
//获取上传的图片字符串
- (NSString *)getPicStringWithpicUrls:(NSArray<NSURL *>*)picUrls{
    NSMutableString *picUrlString = [NSMutableString new];
    for (int i=0; i<[picUrls count]; i++)
    {
        
        NSURL    *picUrl    = picUrls[i];
        NSString *urlString = [picUrl absoluteString];
        //url之间用“|”分开
        if (urlString && urlString.length)
        {
            if (i == (picUrls.count-1))
            {
                [picUrlString appendString:urlString];
            }
            else
            {
                [picUrlString appendString:[NSString stringWithFormat:@"%@|",urlString]];
            }
        }
        
    }
    if (picUrlString && picUrlString.length) {
        return picUrlString;
    }
    else
        return nil;
    
}

#pragma mark - Public

//发布动态
- (void)postSendDynamicContent:(NSString *)dynmaicContent originalPicUrls:(NSArray<NSURL *>*)originalPicUrls thumbnailPicUrls:(NSArray<NSURL *>*)thumbnailPicUrls visible:(DynmaicVisible)visible atUsers:(NSArray *)atUsers dynamicType:(int)dynamicType complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathSendDynamic;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    //必要参数
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户Id为nil");
        return;
    }
    [params setObject:[YHUserInfoManager sharedInstance].userInfo.uid forKey:@"userId"
     ];
    
    if (![YHUserInfoManager sharedInstance].userInfo.accessToken) {
        complete(NO,@"用户accessToken为nil");
        return;
    }
    [params setObject:[YHUserInfoManager sharedInstance].userInfo.accessToken forKey:@"accessToken"
     ];
    
    [params setObject:@(dynamicType) forKey:@"dynamicType"];//动态类型
    
    //文本内容
    if(dynmaicContent && dynmaicContent.length){
       [params setObject:dynmaicContent forKey:@"text"];
    }
    
    //原图
    if (originalPicUrls) {
        
        NSString *originalPicString = [self getPicStringWithpicUrls:originalPicUrls];
        if (originalPicString) {
            [params setObject:originalPicString forKey:@"pics"];
        }
    }
    
    //缩略图(改变后此参数不必要)
    if (thumbnailPicUrls) {
        NSString *thumbnailPicString = [self getPicStringWithpicUrls:thumbnailPicUrls];
        if (thumbnailPicString) {
            [params setObject:thumbnailPicString forKey:@"thumbnaiPic"];
        }
    }
    
    
    //可见性
    [params setObject:@(visible) forKey:@"visible"];
    
    //@用户
    if (atUsers) {
        if (dynmaicContent) {
            [params setObject:dynmaicContent forKey:@"userList"];
        }
    }


    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//上传图片数组
- (void)postUploadPics:(NSArray<UIImage*> *)pics complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress;{
    

    NSString *requestUrl = [YHProtocol share].pathUploadImage;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    
    if (!pics || !pics.count) {
        complete(NO,@"上传图片为nil");
        return;
    }
    
    NSDictionary *params = @{
                           @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                           };
    
    [self uploadWithRequestUrl:requestUrl parameters:params imageArray:pics fileNames:nil name:@"files" mimeType:@"image/png" progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
       progress(bytesWritten,totalBytesWritten);
    } complete:^(BOOL success, id obj) {
        if(success)
        {
            
            NSDictionary *dictData  =  obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSArray *arrayPics  =  dictData[@"pics"];
            NSMutableArray *maRet = [NSMutableArray array];
            if ([arrayPics isKindOfClass:[NSArray class]] && arrayPics.count) {
                for (NSDictionary *dict in arrayPics) {
                    NSString *picUrtStr = dict[@"picUrl"];
                    NSURL *picUrl = [NSURL URLWithString:picUrtStr];
                    [maRet addObject:picUrl];
                }
            }
            complete(YES,maRet);
        }
        else{
            complete(NO,obj);
        }

    }];
   
}

//上传图片
- (void)postUploadOriginalPics:(NSArray<UIImage*> *)originalPics thumbnailPics:(NSArray<UIImage*> *)thumbnailPics complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress{

    __weak typeof(self)weakSelf      = self;
    __block NSArray *oriPicRetArray  = nil;
//    __block NSArray *thumPicRetArray = nil;
   
    if (!originalPics || !originalPics.count) {
        complete(NO,@"上传原图为nil");
        return;
    }
    
//    if (!thumbnailPics) {
//        complete(NO,@"上传缩略图为nil");
//        return;
//    }
    
        /******1.上传原图*************/
        [weakSelf postUploadPics:originalPics complete:^(BOOL success, id obj) {
            if (success) {
                
                oriPicRetArray = [obj copy];
                NSDictionary *dictRet            = [NSDictionary new];
                NSMutableArray *thumbPicRetArray = [NSMutableArray array];
                for (NSURL *oriUrl in oriPicRetArray)
                {
                    NSString *oriUrlStr     = [oriUrl absoluteString];
                    NSString *thumbUrlStr   = [oriUrlStr stringByAppendingString:@"!m226x226.jpg"];
                    NSURL *thumbUrl = [NSURL URLWithString:thumbUrlStr];
                    if (!thumbUrl) {
                        thumbUrl = [NSURL URLWithString:@""];
                    }
                    [thumbPicRetArray addObject:thumbUrl];
                }
                
                dictRet = @{ @"originalPicUrls":oriPicRetArray ,
                             @"thumbPicUrls":thumbPicRetArray};
                complete(YES,dictRet);
                
            }
            else{
                complete(NO,obj);
            }
            
        } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
            progress(bytesWritten,totalBytesWritten);
        }];
    
    
}

//获取工作圈动态列表
- (void)postWorkGroupDynamicsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathWorkGroupDynamicList;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"uid":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"count":@(count),
                             @"page":@(currentPage)
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success)
        {
            NSDictionary  *dictData = obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray       *dynArray = dictData[@"dynamics"];
            NSMutableArray *userArray = [NSMutableArray new];
            if ([dynArray isKindOfClass:[NSArray class]] && [dynArray count]) {
                userArray = [[[DataParser shareInstance] parseWorkGroupListWithData:dynArray curReqPage:currentPage] mutableCopy];
            }
            
            complete(YES,userArray);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//按标签类型获取工作圈动态
- (void)postWorkGroupDynamicsCount:(int)count currentPage:(int)currentPage dynamicType:(int)dynamicType complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathWorkGroupDynamicListByTag;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"uid":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"count":@(count),
                             @"page":@(currentPage),
                             @"dynamicType":@(dynamicType)
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success)
        {
            NSDictionary  *dictData = obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray        *dynArray  = dictData[@"dynamics"];
            NSMutableArray *userArray = [NSMutableArray new];
            if ([dynArray isKindOfClass:[NSArray class]] && [dynArray count]) {
                userArray = [[[DataParser shareInstance] parseWorkGroupListWithData:dynArray curReqPage:currentPage] mutableCopy];
            }
            
            complete(YES,userArray);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//评论某一条动态
- (void)postCommentDynamic:(NSString*)dynamicId content:(NSString *)content complete:(NetManagerCallback)complete{
   
    NSString *requestUrl = [YHProtocol share].pathCommentDynamic;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    if (!content || !content.length) {
        complete(NO,@"评论内容不能为空");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"id":dynamicId,
                             @"text":content
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//赞某条动态
- (void)postLikeDynamic:(NSString *)dynamicId isLike:(BOOL)isLike complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathLikeDynamic;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    NSString *isLikeStr = isLike? @"click":@"cancel";
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"dynamicId":dynamicId,
                             @"OperationType":isLikeStr
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        complete(success,obj);
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//获取某一动态的评论列表
- (void)getDynamicCommentListWithId:(NSString *)dynamicId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathDynamicCommentList;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"id":dynamicId,
                             @"page":@(currentPage),
                             @"count":@(count)
                             };
    
    [self getWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj)
    {
        
        if (success) {
            
            NSDictionary *dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray *commentArray =  dictData[@"comments"];
            
            NSArray *commentList = [NSArray new];
            commentList = [[DataParser shareInstance] parseCommentListWithListData:commentArray];
            
            complete(YES,commentList);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//获取某一动态的点赞列表
- (void)postDynamicLikeListWithId:(NSString *)dynamicId
                           count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathDynamicLikeList;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"dynamicId":dynamicId,
                             @"page":@(currentPage),
                             @"count":@(count)
                             };
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success) {
            
            NSDictionary *dictData = [obj objectForKey:@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray *likeUsersArray =  dictData[@"users"];
            
            NSArray *arrayRet = [NSArray new];
            arrayRet = [[DataParser shareInstance] parseUserListWithListData:likeUsersArray curReqPage:currentPage];
            
            complete(YES,arrayRet);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];


}

- (void)postDynamicShareListWithId:(NSString *)dynamicId
                             count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{


}

//转发某一条动态
- (void)postDynamicRepostWithId:(NSString *)dynamicId content:(NSString *)content visible:(DynmaicVisible)visible atUsers:(NSArray *)atUsers complete:(NetManagerCallback)complete{

    NSString *requestUrl = [YHProtocol share].pathDynamicRepost;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id为nil");
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                            @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                            @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                            @"id":dynamicId,
                            @"visible":@(visible)                               }];
    
    //文本内容
    NSString *contentStr = @"";
    if (!content || !content.length) {
        contentStr = @"转发动态";
    }else{
        contentStr = content;
    }
    
    [params setObject:contentStr forKey:@"text"];
    
    //@用户
    if (atUsers && atUsers.count) {
        NSString *atUserStr = [atUsers componentsJoinedByString:@","];
        if (atUserStr) {
            [params setObject:atUserStr forKey:@"atUserStr"];
        }
    }
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        if (success) {
            complete(YES,obj);
        }
        else{
            complete(NO,obj);
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
    }];
}

//删除动态评论
- (void)postDeleteDynamicCommentWithId:(NSString *)commentId dynamicId:(NSString *)dynamicId complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathDeleteDynamicComment;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    if (!commentId) {
        complete(NO,@"评论Id 不能为空");
        return;
    }
    
    if (!dynamicId) {
        complete(NO,@"动态Id不能为空");
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                                                                                    @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                                                                                    @"id":commentId,
                                                     @"dynamicId":dynamicId                                                             }];
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
            complete(success,obj);

    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//获取动态详情页数据
- (void)postDynamicDetailWithId:(NSString *)dynamciId curReqPage:(int)curReqPage complete:(NetManagerCallback)complete
{
    
    NSString *requestUrl = [YHProtocol share].pathGetDynamciDetail;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    if (!dynamciId) {
        complete(NO,@"动态Id 不能为空");
        return;
    }
    
    NSDictionary *params = @{
                             
        @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
        @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
        @"dynamicId":dynamciId
                                                                                    };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success) {
            
            NSDictionary *jsonObj  = obj;
            id dictData = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            id dictDynamic = dictData[@"dynamics"];
            
            if (![dictDynamic isKindOfClass:[NSDictionary class]]) {
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            YHWorkGroup *model = [[DataParser shareInstance] parseWorkGroupWithDict:dictDynamic curReqPage:curReqPage];
            complete(YES,model);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//搜索动态
- (void)getSearchDynamicWithKeyWord:(NSString *)keyWord sortType:(SortType)sortType count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete{
    
    NSString *requestUrl = [YHProtocol share].pathSearchDynamic;
    
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
                             @"type" :@(sortType),
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
            
            NSArray  *dynamicArray = dictData[@"dynamics"];
            NSArray  *dynamicRetArray = [NSArray new];
            if (dynamicArray.count) {
                dynamicRetArray = [[DataParser shareInstance] parseWorkGroupListWithData:dynamicArray curReqPage:currentPage];
            }
        
            complete(YES,dynamicRetArray);
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

//综合搜索
- (void)getSynthesisSearchWithKeyWord:(NSString *)keyWord complete:(NetManagerCallback)complete{
    NSString *requestUrl = [YHProtocol share].pathSynthesisSearch;
    
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
            
            NSArray  *dynamicArray = dictData[@"dynamics"];
            NSArray  *dynamicRetArray = [NSArray new];
            if (dynamicArray.count) {
                dynamicRetArray = [[DataParser shareInstance] parseWorkGroupListWithData:dynamicArray curReqPage:0];
            }
            
            NSArray  *connectionArray = dictData[@"accounts"];
            NSArray  *connectionRetArray = [NSArray new];
            if (connectionArray.count && [connectionArray isKindOfClass:[NSArray class]]) {
              connectionRetArray =  [[DataParser shareInstance] parseUserListWithListData:connectionArray curReqPage:0];
            }
            
            complete(YES,@{
                           @"accounts":connectionRetArray,
                           @"dynamics":dynamicRetArray
                           });
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

- (void)postReplyCommentWithContent:(NSString *)commentContent dynamicId:(NSString *)dynamicId commentId:(NSString *)commentId replyUid:(NSString *)replyUid complete:(NetManagerCallback)complete{
   
    NSString *requestUrl = [YHProtocol share].pathReplyComment;
    
    //参数判断
    if(![YHUserInfoManager sharedInstance].userInfo.accessToken){
        complete(NO,@"用户token 不能为空");
        return;
    }
    if(![YHUserInfoManager sharedInstance].userInfo.uid){
        complete(NO,@"用户uid 不能为空");
        return;
    }
    if (!commentContent) {
        complete(NO,@"评论内容为nil");
        return;
    }
    if (!commentId) {
        complete(NO,@"评论Id为nil!");
        return;
    }
    if (!dynamicId) {
        complete(NO,@"动态Id为nil!");
        return;
    }
    if (!replyUid) {
        complete(NO,@"回复用户id为nil!");
        return;
    }
    
    NSDictionary *params = @{
                             @"accessToken":[YHUserInfoManager sharedInstance].userInfo.accessToken,
                             @"userId":[YHUserInfoManager sharedInstance].userInfo.uid,
                             @"cuid":replyUid,
                             @"text":commentContent,
                             @"cid":commentId,
                             @"id":dynamicId
                             
                             };
    
    
    [self postWithRequestUrl:requestUrl parameters:params complete:^(BOOL success, id obj) {
        
        if (success) {
            
            NSDictionary *jsonObj  = obj;
            id dictData = jsonObj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            
            NSArray  *dynamicArray = dictData[@"dynamics"];
            NSArray  *dynamicRetArray = [NSArray new];
            if (dynamicArray.count) {
                dynamicRetArray = [[DataParser shareInstance] parseWorkGroupListWithData:dynamicArray curReqPage:0];
            }
            
            NSArray  *connectionArray = dictData[@"accounts"];
            NSArray  *connectionRetArray = [NSArray new];
            if (connectionArray.count && [connectionArray isKindOfClass:[NSArray class]]) {
                connectionRetArray =  [[DataParser shareInstance] parseUserListWithListData:connectionArray curReqPage:0];
            }
            
            complete(YES,@{
                           @"accounts":connectionRetArray,
                           @"dynamics":dynamicRetArray
                           });
        }
        else{
            complete(NO,obj);
        }
    } progress:^(NSProgress *uploadProgress) {
        
    }];

}

@end
