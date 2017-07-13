//
//  YHCommentData.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 16/5/15.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHUserInfo.h"

@interface YHCommentData : NSObject

@property (nonatomic, copy) NSString    *publishTime;//发布时间
@property (nonatomic,strong)YHUserInfo  *authorInfo;//评论人
@property (nonatomic, copy) NSString    *commentId;
@property (nonatomic, copy) NSMutableAttributedString    *commentContent;//评论内容
@property (nonatomic, copy) NSString    *contentId;
@property (nonatomic, copy) NSString    *content;
@property (nonatomic, retain) YHCommentData *toReplyCommentData;

@end
