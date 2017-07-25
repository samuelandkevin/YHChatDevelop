//
//  YHNetManager.h
//  PikeWay
//
//  Created by kun on 16/4/28.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  工作圈请求


#import "NetManager.h"

//动态内容可见性
typedef NS_ENUM(int , DynmaicVisible){
    DynmaicVisible_AllPeople = 0, //所有人
    DynmaicVisible_OnlyMe,        //仅自己可见
    DynmaicVisible_Friends,       //密友可见
    DynmaicVisible_Group          //指定分组可见
};


//排序方式
typedef NS_ENUM(int,SortType){
    SortType_Time = 1, //按时间排序
    SortType_Hot       //按热度排序
};

@interface NetManager (WorkGroup)


/**
*  发布动态
*
*  @param dynmaicContent   动态内容
*  @param originalPicUrls  原图片url数组
*  @param thumbnailPicUrls 缩略图url数组
*  @param visible          动态内容可见性 DynmaicVisible
*  @param atUsers          @用户
*  @param dynamicType      动态的标签类型
*  @param complete         成功失败回调
*/
- (void)postSendDynamicContent:(NSString *)dynmaicContent originalPicUrls:(NSArray<NSURL *>*)originalPicUrls thumbnailPicUrls:(NSArray<NSURL *>*)thumbnailPicUrls visible:(DynmaicVisible)visible atUsers:(NSArray *)atUsers dynamicType:(int)dynamicType complete:(NetManagerCallback)complete;

/**
 *  上传图片数组
 *
 *  @param pics     image数组
 *  @param complete 成功返回:图片url数组
 *  @param progress 进度值
 */
- (void)postUploadPics:(NSArray<UIImage*> *)pics complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress;

/**
 *  上传要发布动态的图片
 *
 *  @param originalPics  原图image数组
 *  @param thumbnailPics 缩略图image数组
 *  @param complete      成功返回Dictionary   
          {key:"originalPicUrls", value:原始图片url数组
           key:"thumbnailPicUrls",value:缩略图url数组}
 *  @param progress      进度值
 */
- (void)postUploadOriginalPics:(NSArray<UIImage*> *)originalPics thumbnailPics:(NSArray<UIImage*> *)thumbnailPics complete:(NetManagerCallback)complete progress:(YHUploadProgress)progress;

/**
 *  获取工作圈动态
 *
 *  @param count       <#count description#>
 *  @param currentPage <#currentPage description#>
 *  @param complete    <#complete description#>
 */
- (void)postWorkGroupDynamicsCount:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete __deprecated_msg("请使用postWorkGroupDynamicsCount:currentPage:dynamicType:complete:");

/**
 *  按标签类型获取工作圈动态
 *
 *  @param count       请求数量
 *  @param currentPage 当前页
 *  @param dynamicType 标签类型
 *  @param complete    成功失败回调
 */
- (void)postWorkGroupDynamicsCount:(int)count currentPage:(int)currentPage dynamicType:(int)dynamicType complete:(NetManagerCallback)complete;
/**
 *  评论某条动态
 *
 *  @param dynamicId 动态Id
 *  @param content   评论内容
 *  @param complete  成功失败回调
 */
- (void)postCommentDynamic:(NSString*)dynamicId content:(NSString *)content complete:(NetManagerCallback)complete;

/**
 *  赞某条动态
 *
 *  @param dynamicId 动态Id
 *  @param isLike    喜欢
 *  @param complete  成功失败回调
 */
- (void)postLikeDynamic:(NSString *)dynamicId isLike:(BOOL)isLike complete:(NetManagerCallback)complete;


/**
 *  获取某一动态的评论列表
 *
 *  @param dynamicId   动态Id
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getDynamicCommentListWithId:(NSString *)dynamicId count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;


/**
 *  获取某一动态的点赞列表
 *
 *  @param dynamicId   动态Id
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)postDynamicLikeListWithId:(NSString *)dynamicId
                           count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  获取某一动态的分享列表
 *
 *  @param dynamicId   动态Id
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)postDynamicShareListWithId:(NSString *)dynamicId
                             count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

//转发某一条动态
- (void)postDynamicRepostWithId:(NSString *)dynamicId content:(NSString *)content visible:(DynmaicVisible)visible atUsers:(NSArray *)atUsers complete:(NetManagerCallback)complete;

/**
 *  删除动态评论
 *
 *  @param commentId 评论Id
 *  @param dynamicId 动态评论Id
 *  @param complete  成功失败回调
 */
- (void)postDeleteDynamicCommentWithId:(NSString *)commentId dynamicId:(NSString *)dynamicId complete:(NetManagerCallback)complete;

/**
 *  获取动态详情页
 *
 *  @param dynamciId 动态Id
 *  @param complete  <#complete description#>
 */
- (void)postDynamicDetailWithId:(NSString *)dynamciId complete:(NetManagerCallback)complete;

/**
 *  搜索动态
 *
 *  @param keyWord     关键词
 *  @param type        <#type description#>
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getSearchDynamicWithKeyWord:(NSString *)keyWord sortType:(SortType)sortType count:(int)count currentPage:(int)currentPage complete:(NetManagerCallback)complete;

/**
 *  综合搜索
 *
 *  @param keyWord     关键词
 *  @param count       单页返回的记录数量
 *  @param currentPage 当前页码
 *  @param complete    成功失败回调
 */
- (void)getSynthesisSearchWithKeyWord:(NSString *)keyWord complete:(NetManagerCallback)complete;


/**
 *  回复评论
 *
 *  @param commentContent 评论内容
 *  @param dynamicId      动态Id
 *  @param commentId      评论Id
 *  @param replyUid       回复评论Id
 *  @param complete       成功失败回调
 */
- (void)postReplyCommentWithContent:(NSString *)commentContent dynamicId:(NSString *)dynamicId commentId:(NSString *)commentId replyUid:(NSString *)replyUid complete:(NetManagerCallback)complete;
@end
