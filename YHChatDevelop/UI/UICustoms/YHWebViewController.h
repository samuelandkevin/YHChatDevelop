//
//  YHWebViewController.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/6/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ZJScrollPageViewDelegate.h"

@interface YHWebViewController : UIViewController<ZJScrollPageViewChildVcDelegate>

@property (nonatomic,assign,readonly) BOOL finishLoading;
@property (nonatomic,assign,readonly) BOOL noCache;    //没有网页缓存
@property (nonatomic,assign) BOOL backAnimatedDisabled;//禁止返回动画（返回方式包含：pop或者dimiss）//默认NO

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JSContext *jsContext;
@property (nonatomic,assign) BOOL enableIQKeyBoard;
@property (nonatomic,assign) BOOL presentedVC;         //present方式展示VC
@property (nonatomic,assign) BOOL navigationBarHidden;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSURLRequest *loadRequst; //webView加载的请求
@property (nonatomic,assign) UIWebViewNavigationType navigationType;//导航类型


/**
 初始化YHWebViewController
 
 @param frame controller中view的frame
 @param url 加载url
 @param loadCache 加载缓存
 @return YHWebViewController
 */
- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url loadCache:(BOOL)loadCache ;
//停止加载
- (void)stopLoading;

#pragma mark - 提供父类的方法,子类可以根据需求重定义
- (void)setUpNavigationBar;
- (void)setUpWebView;       //子类可以在此方法重设webview的frame和url
- (BOOL)webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewDidFailLoadWithError:(NSError *)error;
- (void)onBack:(id)sender;
- (void)scrollViewDidScroll;
- (void)scrollViewDidDrag;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)loadRequestWithURL:(NSURL *)url; //加载请求（不带缓存）


#pragma mark - 缓存
- (void)loadCacheWithURL:(NSURL *)url;   //加载请求 (带缓存)
- (void)updateCacheWithURL:(NSURL *)url; //更新缓存
- (void)clean;


#pragma mark - KeyboardNotification
- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;
- (void)adjustScrollView:(CGRect)kbRect;
- (void)keyboardWillShow:(NSNotification *)aNotification;
@end
