//
//  YHWGPhotoManager.m
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHWGPhotoManager.h"

//#define kContainerKey [NSString stringWithFormat:@"%lu%f%f",(unsigned long)picUrlArray.count,superViewWidth,margin]
//
//@interface  YHWGPhotoManager()
//
//@property (nonatomic, strong) NSMutableDictionary<NSString*,YHWorkGroupPhotoContainer *> *containersDict;
//
//@end
//
@implementation YHWGPhotoManager
//
//+ (instancetype)shareInstance{
//    static YHWGPhotoManager *g_instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        g_instance = [[YHWGPhotoManager alloc] init];
//    });
//    return g_instance;
//}
//
//- (NSMutableDictionary<NSString *,YHWorkGroupPhotoContainer *> *)containersDict{
//    if (!_containersDict) {
//        _containersDict = [NSMutableDictionary new];
//    }
//    return _containersDict;
//}
//
//#pragma mark - Public
//
//- (YHWorkGroupPhotoContainer *)getContainerWithPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin{
//    if (!picUrlArray || picUrlArray.count == 0) {
//        return nil;
//    }
//    
//    YHWorkGroupPhotoContainer *container = self.containersDict[kContainerKey];
//    if (container) {
//        return container;
//    }
//    container = [[YHWorkGroupPhotoContainer alloc] init];
//    [self.containersDict setObject:container forKey:@(picUrlArray.count)];
//    return container;
//}
//
//- (CGFloat)containerHeightWithPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin{
//    YHWorkGroupPhotoContainer *container = self.containersDict[kContainerKey];
//    if (!container) {
//        container = [self getContainerWithPicUrlArray:picUrlArray superViewWidth:superViewWidth margin:margin];
//    }
//    return container.containerHeight;
//}
//
//- (void)setupPicUrlArray:(NSArray *)picUrlArray superViewWidth:(CGFloat)superViewWidth margin:(CGFloat)margin{
//    if (picUrlArray.count == 0) {
//        return;
//    }
//    YHWorkGroupPhotoContainer *container = self.containersDict[kContainerKey];
//    if (!container) {
//        container = [self getContainerWithPicUrlArray:picUrlArray superViewWidth:superViewWidth margin:margin];
//    }
//    [container setupWithPicUrlArray:picUrlArray superViewWidth:superViewWidth margin:margin];
//}


@end
