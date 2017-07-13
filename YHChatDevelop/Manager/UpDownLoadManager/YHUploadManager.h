//
//  YHUploadManager.h
//  samuelandkevin
//
//  Created by samuelandkevin on 17/1/12.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHFileModel.h"

@interface YHUploadManager : NSObject


+ (YHUploadManager*)sharedInstance;

/*
 *  上传聊天语音
 *  @param recordPath       后台返回的Url
 *  @param progress         上传进度
 *  @param complete         成功失败回调
 */
- (void)uploadChatRecordWithPath:(NSString *)recordPath complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress;

/*
 *  上传办公格式的文件        （PDF,Word,Excel）
 *  @param fileModel        YHFileModel
 *  @param progress         上传进度
 *  @param complete         成功失败回调
 */
- (void)uploadOfficeFileWithFileModel:(YHFileModel *)fileModel complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progres;

@end
