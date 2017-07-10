//
//  YHWebViewController.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/6/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHWebViewController.h"
#import "HHUtils.h"
#import <objc/runtime.h>
#import "UIBarButtonItem+Extension.h"
#import "YHLoadView.h"
#import "YHChatDevelop-Swift.h"
#import "STMURLCache.h"

@interface YHWebViewController ()<UIWebViewDelegate,UIScrollViewDelegate>

#define HTML_TokenInvalid @"{\"status\":\"error\",\"code\":\"401\""
#define HTML_BodyInnerText @"document.body.innerText"
#define HTML_IsEmpty @"<head></head><body></body>"
#define HTML_Inner @"document.documentElement.innerHTML"

@property (nonatomic,assign) CGRect rect;

//控件
@property (nonatomic,strong) UIButton   *btnScrollToTop;
@property (nonatomic,strong) YHLoadView *viewLoadFail;
@property (nonatomic,strong) YHLoadingView *viewLoading;

//标志变量
@property (nonatomic,assign)  BOOL hasRegisterKeyboardNotification;
@property (nonatomic,assign)  BOOL keyboardIsShown;
@property (nonatomic,assign)  BOOL loadCache;//加载缓存,默认是从服务器获取资源

//其他
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) STMURLCache *sCache;
@end

@implementation YHWebViewController


- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url loadCache:(BOOL)loadCache{
    if (self  = [super init]) {
        _url  = url;
        _rect = frame;
        _loadCache = loadCache;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url{
    if(self = [super init]){
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    
}


- (void)initUI{
    
    
    [self setUpNavigationBar];
    self.navigationController.navigationBar.translucent = NO;
    
    //1.webview
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.opaque   = NO;
    _webView.scrollView.bounces = NO;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [_webView setScalesPageToFit:YES];
    _webView.scrollView.delegate = self;
    [self.view addSubview:_webView];
    [self setUpWebView];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    
    if (_loadCache && _url) {
        [self loadCacheWithURL:self.url];
    }
    
    
}

#pragma mark - KVO





#pragma mark - Lazy Load


- (YHLoadView *)viewLoadFail{
    if(!_viewLoadFail){
        _viewLoadFail = [YHLoadView loadFail];
        _viewLoadFail.center = CGPointMake(self.view.center.x, SCREEN_HEIGHT/4);
        WeakSelf
        [_viewLoadFail onReloadHandler:^{
            DDLog(@"onReload");
            NSMutableURLRequest *mreq = [NSMutableURLRequest requestWithURL:weakSelf.url];
            [weakSelf.webView loadRequest:mreq];
        }];
        [self.view addSubview:_viewLoadFail];
    }
    return _viewLoadFail;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - Action
- (void)onBack:(id)sender{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else{
        if(_presentedVC){
            [self dismissViewControllerAnimated:!_backAnimatedDisabled completion:NULL];
        }else
            [self.navigationController popViewControllerAnimated:!_backAnimatedDisabled];
    }
}

#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (!_finishLoading) {
        if (![self.view.subviews containsObject:_viewLoading]) {
            _viewLoading = [YHLoadingView showLoadingInView:self.view];
        }
    }
    
    if (!_enableIQKeyBoard) {
//        [[IQKeyboardManager sharedManager] setEnable:NO];
//        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    }
    self.navigationController.navigationBarHidden = self.navigationBarHidden;
    if (self.navigationBarHidden) {
        //状态栏背景添加
        if (![self.view viewWithTag:1111]) {
            UIView *statusBarBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            statusBarBG.tag = 1111;
            statusBarBG.backgroundColor = kBlueColor;
            [self.view addSubview:statusBarBG];
        }
    }
    
}


- (void)viewWillDisappear:(BOOL)animated{
    
//    [[IQKeyboardManager sharedManager] setEnable:YES];
//    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [super viewWillDisappear:animated];
    
}

- (void)dealloc{
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private


#pragma mark - Public

- (void)stopLoading{
    [self.webView stopLoading];
    _finishLoading = YES;
    [_viewLoading hideLoadingView];
}

- (void)setUpNavigationBar{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)setUpWebView{
    _webView.frame = _rect;
    
    if (!self.loadCache) {
        [self loadRequestWithURL:_url];
    }
}



- (void)webViewDidFailLoadWithError:(NSError *)error{
    //空操作,提供子类使用
}

- (BOOL)webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //空操作,提供子类使用
    return YES;
}

- (void)loadCacheWithURL:(NSURL *)url{
    
    if (![[NSURLCache sharedURLCache] isKindOfClass:[STMURLCache class]]) {
        configWebViewCache();
    }
    
    self.sCache = (STMURLCache *)[NSURLCache sharedURLCache];
    
    [self.sCache update:^(STMURLCacheMk *mk) {
        if (url) {
            mk.addRequestUrlWhiteList(url.absoluteString);
        }
    }];
    
    //------------web view 加载区域-----------
    NSURLRequest *re = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:re];
}

- (void)updateCacheWithURL:(NSURL *)url{
    
    [self.sCache clearCache];
    [self loadCacheWithURL:url];
}

- (void)clean{
    
    NSHTTPCookie *cookie = nil;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    NSURLCache *sCache = [NSURLCache sharedURLCache];
    [sCache removeAllCachedResponses];
    [sCache setDiskCapacity:0];
    [sCache setMemoryCapacity:0];
    
}



#pragma mark - KeyboardNotification
- (void)registerForKeyboardNotifications {
    if (_hasRegisterKeyboardNotification) {//注册的键盘通知，直接退出
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    _hasRegisterKeyboardNotification = YES;
}

- (void)unregisterKeyboardNotifications {
    if (!_hasRegisterKeyboardNotification) {
        return;
    }
    _hasRegisterKeyboardNotification = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self adjustScrollView:keyboardRect];
    
}


- (void)adjustScrollView:(CGRect)kbRect {
    
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.webView.scrollView.contentOffset = CGPointMake(0, kbRect.size.height);
    }];
    
}




#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.loadRequst = request;
    self.navigationType = navigationType;
    return [self webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    
}

//网页开始加载的时候调用
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLog(@"webViewDidStartLoad");
    if(![self.view.subviews containsObject:_viewLoading]){
        _viewLoading = [YHLoadingView showLoadingInView:self.view];
    }
    [self.viewLoadFail hideFailView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    _finishLoading = YES;
    [_viewLoading hideLoadingView];
    
    [self.viewLoadFail hideFailView];
    
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //检查登录信息
    NSString *strBody = [webView stringByEvaluatingJavaScriptFromString:HTML_BodyInnerText];
    if ([strBody hasPrefix:HTML_TokenInvalid]) {
        DDLog(@"token失效,请重新登录");
        [[NSNotificationCenter defaultCenter] postNotificationName:Event_Token_Unavailable object:self];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    _finishLoading = YES;
    [_viewLoading hideLoadingView];
    
    if (self.navigationBarHidden) {
        //状态栏背景移除
        UIView *statusBarBG = [self.view viewWithTag:1111];
        [statusBarBG removeFromSuperview];
    }
    
    
    if (error.code == 102){
        //链接无效,不做任何跳转
        
    }else{
        NSString *strInHTML = [webView stringByEvaluatingJavaScriptFromString:HTML_Inner];
        if ([strInHTML isEqualToString:HTML_IsEmpty]) {
            //网页没有内容
            if ([error.userInfo[@"cache"] boolValue] == NO) {
                DDLog(@"no HTML cache");
                //没缓存,显示失败View,点击可重新加载
                [self.viewLoadFail showLoadFailView];
                _noCache = YES;
            }
        }
        
        
    }
    
    [self webViewDidFailLoadWithError:error];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self scrollViewDidDrag];
}

- (void)scrollViewDidScroll{
    
}

- (void)scrollViewDidDrag{
    
}

- (void)loadRequestWithURL:(NSURL *)url{
    if (![[NSURLCache sharedURLCache] isKindOfClass:[STMURLCache class]]) {
        configWebViewCache();
    }
    
    self.sCache = (STMURLCache *)[NSURLCache sharedURLCache];
    
    [self.sCache update:^(STMURLCacheMk *mk) {
        if (url) {
            mk.addRequestUrlBlackList(url.absoluteString);
        }
    }];
    
    //------------web view 加载区域-----------
    // [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //[NSURLRequest requestWithURL:url]
    NSURLRequest *re = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [self.webView loadRequest:re];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
