//
//  YHAppInfo.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHAppInfoManager.h"
#import "YHNetManager.h"


@interface YHCanOpenPageModel : NSObject
@property (nonatomic,copy) NSString *pageId;
@property (nonatomic,assign)BOOL canOpen;
@property (nonatomic,copy) NSArray *title;

@end

@implementation YHCanOpenPageModel


@end

//
#define Page_sideMenu @"1"
//保存
#define kCanOpenSideMenu @"canOpen_SideMenu"
@interface YHAppInfoManager()
@property (nonatomic, assign)BOOL requestPagesCanOpenSuccess;//请求能打开的页面成功
@property (nonatomic, strong)NSMutableArray <YHCanOpenPageModel*>*pagesArray;

@end

@implementation YHAppInfoManager

+ (instancetype)shareInstanced
{
    static YHAppInfoManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHAppInfoManager alloc] init];
    });
    return g_instance;
    
}

#pragma mark - Lazy Load
- (NSString *)userAgent{
    if (!_userAgent) {
        UIWebView *tempWebV = [[UIWebView alloc] init];
        NSString *sAgent = [tempWebV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *aUserAgent = [NSString stringWithFormat:@"%@; ShuiDao /%@",sAgent,[HHUtils appStoreNumber]];
        [tempWebV stringByEvaluatingJavaScriptFromString:aUserAgent];
        NSDictionary*dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:aUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
        _userAgent = aUserAgent;
    }
    return _userAgent;
}

- (NSMutableArray<YHCanOpenPageModel *> *)pagesArray{
    if (!_pagesArray) {
        _pagesArray = [NSMutableArray new];
    }
    return _pagesArray;
}

- (void)requestPagesCanOpenComplete:(void(^)(BOOL success,id obj))complete{
    
    WeakSelf
    if (self.requestPagesCanOpenSuccess) {
        
        complete(YES,weakSelf.pagesArray);
        
    }else{
        
        [[NetManager sharedInstance] getPageInfoAboutCanOpenedComplete:^(BOOL success, id obj) {
            if (success) {
                weakSelf.requestPagesCanOpenSuccess = YES;
                
                NSArray *pagesArr = obj;
                [self.pagesArray removeAllObjects];
                for (NSDictionary *dict in pagesArr) {
                    
                    YHCanOpenPageModel *model = [YHCanOpenPageModel new];
                    model.pageId   = dict[@"function_id"];
                    int is_enable  = [dict[@"is_enable"] intValue];//0是启用 1是禁用
                    model.canOpen = (is_enable == 1 ? YES : NO);
                    model.title = dict[@"function_name"];
                    [weakSelf.pagesArray addObject:model];
                }
                complete(YES,weakSelf.pagesArray);
            }else{
                
                if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable) {
                    complete(NO,YHNetworkStatus_NotReachable);
                }else{
                    complete(NO,nil);
                }
                
            }
        }];

    }
    
}

- (void)canOpenSideMenu:(void(^)(BOOL canOpen,id obj))complete{
    
//    BOOL canOpen = [[NSUserDefaults standardUserDefaults] boolForKey:kCanOpenSideMenu];
//    if (canOpen) {
//        self.canOpenSideMenu = YES;
//        complete(YES,nil);
//    }else{

//    }
    
    WeakSelf
    [self requestPagesCanOpenComplete:^(BOOL success,id obj) {
        
        if (success) {
            NSArray *pagesArray = obj;
            for (YHCanOpenPageModel *model in pagesArray) {
                if ([model.pageId isEqualToString:Page_sideMenu]) {
                    if (model.canOpen) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCanOpenSideMenu];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        weakSelf.canOpenSideMenu = YES;
                    }else{
                        weakSelf.canOpenSideMenu = NO;
                        
                        //kun调试 （打开这段代码,可以显示企业栏目）
//                        weakSelf.canOpenSideMenu = YES;
//                        model.canOpen = YES;
                    }
                    complete(model.canOpen,nil);
                    break;
                }
            }
            
        }else{
            
            complete(NO,obj);
            
        }
    }];
}

@end
