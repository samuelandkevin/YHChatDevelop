//
//  ThirdViewController.m
//  MyProject
//
//  Created by samuelandkevin on 16/4/10.
//  Copyright © 2016年 kun. All rights reserved.
//
#import "YHChatDevelop-Swift.h"
#import "YHConnectioniewController.h"

#import "YHNetManager.h"
//#import "NewFansVC.h"
#import "HHUtils.h"
#import "YHUserInfoManager.h"
//#import "YHTalentListController.h"
#import "YHMyFriendsManager.h"
#import "CellForMyFri.h"
#import "YHRefreshTableView.h"
#import "RegexKitLite.h"
#import "pinyin.h"
//#import "YHCacheManager.h"
#import "YHNetManager.h"
#import "YHConnectionHeaderView.h"
//#import "YHGroupListVC.h"
#import "CardDetailViewController.h"
#import "YHConnectionSearchView.h"
#import "YHSqliteManager.h"
#import "YHIMHandler.h"
#import "AddFansViewController.h"
#import "Masonry.h"
//#import "UMMobClick/MobClick.h"


#define kTbvHeaderViewH 88 //headerView高度
#define kSearchBarH     44


@interface YHConnectioniewController () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,YHConnectionSearchViewDelegate,CellForMyFriDelegate>{
    
    
    BOOL _isSelbtnAdd; //添加按钮选中
    int _curMyFriendsReqPage;
}
@property (nonatomic, strong) YHRefreshTableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *btnView;
@property (nonatomic, strong) YHConnectionSearchView *searchView;
@property (nonatomic, strong) YHMyFriendsManager *myFriManager;
@property (nonatomic, strong) NSMutableArray *maSearchResult;

@property (nonatomic, assign) BOOL rBtnSelected;
@property (nonatomic, strong) YHPopMenu *popView;
@property (nonatomic, strong) YHConnectionHeaderView *hView;

@property (nonatomic, strong) UILabel *lbContacters;//联系人总数
@end

@implementation YHConnectioniewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //1.initUI
    
    [self initUI];
    
    
    //2.addNotification
    
    [self addNotification];
    
    
    self.myFriManager = [YHMyFriendsManager shareInstance];
    
    //缓存方式二：文件
    //    NSArray *cacheList = [[YHCacheManager shareInstance] getCacheMyFriendsList];
    //
    //    if (cacheList.count)
    //    {
    //        self.myFriManager.allFriendsArray = [cacheList mutableCopy];
    //        [self getSortArr:self.myFriManager.allFriendsArray];
    //        [self.tableView reloadData];
    //    }
    
    //    [self requestMyfriendsListLoadNew:YES];
    
    //缓存方式一：DB
    WeakSelf
    [[SqliteManager sharedInstance] queryFrisTableWithFriID:[YHUserInfoManager sharedInstance].userInfo.uid userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
        if (success) {
            NSArray *cacheList = obj;
            DDLog(@"query success :%@",cacheList);
            weakSelf.lbContacters.hidden = NO;
            if(cacheList.count){
                weakSelf.myFriManager.allFriendsArray = [cacheList mutableCopy];
                [weakSelf getSortArr:weakSelf.myFriManager.allFriendsArray];
                [weakSelf _setupContactersCount:cacheList.count];
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf requestMyfriendsListLoadNew:YES];
            }
        }else{
            DDLog(@"fail :%@",obj);
            [weakSelf requestMyfriendsListLoadNew:YES];
        }
    }];
    
}


#pragma mark - addNotification
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnClick:) name:@"YHDiscoveryView.click" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:Event_SystemFontSize_Change object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage:) name:Event_MyFriendsPage_Refresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout) name:Event_Logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBadge) name:Event_TabbarBadeg_Update object:nil];
    
}

#pragma mark - notificationMethod
- (void)btnClick:(NSNotification *)sender
{
//    YHDiscoveryView *view = sender.object;
//    
//    switch (view.tag)
//    {
//        case 301:
//        {
//            DDLog(@"行业大咖");
////            YHTalentListController *vc = [[YHTalentListController alloc] init];
////            vc.hidesBottomBarWhenPushed = YES;
////            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//            
//        case 302:
//        {
//            DDLog(@"找法规");
//            YHWebController *vc = [[YHWebController alloc] init];
//            
//            NSString *baserUrl = [[YHProtocol share].kBaseURL stringByReplacingOccurrencesOfString:@"/api" withString:@""];
//            NSString *urlString = [NSString stringWithFormat:@"%@/lawlib/search?accessToken=%@", baserUrl, [YHUserInfoManager sharedInstance].userInfo.accessToken];
//            vc.url = [NSURL URLWithString:urlString];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//            
//        case 303:
//        {
//            DDLog(@"问答");
//        }
//            break;
//            
//        default:
//            break;   
//	}
}

- (void)updateFont:(NSNotification *)aNotifi{
    [self.tableView removeFromSuperview];
    [self initUI];
    [self.tableView reloadData];
}

#pragma mark - initBtnView
- (UIView *)btnView
{
    if (!_btnView)
    {
        _btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 74)];
//        YHDiscoveryView *dakaView = [[YHDiscoveryView alloc] init];
//        
//        dakaView.icon.image = [UIImage imageNamed:@"dis_daka"];
//        dakaView.tag = 301;
//        
//        YHDiscoveryView *lawView = [[YHDiscoveryView alloc] init];
//        
//        lawView.icon.image = [UIImage imageNamed:@"dis_law"];
//        lawView.tag = 302;
//        YHDiscoveryView *QAView = [[YHDiscoveryView alloc] init];
//        
//        QAView.icon.image = [UIImage imageNamed:@"dis_Q&A"];
//        QAView.tag = 303;
//        QAView.hidden = YES;
//        [_btnView addSubview:dakaView];
//        [_btnView addSubview:lawView];
//        [_btnView addSubview:QAView];
//        
//        [dakaView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_btnView).offset(13);
//            make.right.equalTo(lawView.mas_left).offset(-49);
//            make.height.width.equalTo(@74);
//        }];
//        
//        [lawView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_btnView).offset(13);
//            make.centerX.equalTo(_btnView);
//            make.height.width.equalTo(@74);
//        }];
//        
//        [QAView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_btnView).offset(13);
//            make.left.equalTo(lawView.mas_right).offset(49);
//            make.height.width.equalTo(@74);
//        }];
    }
    
    return _btnView;
}

#pragma mark - Lazy Load
- (NSMutableArray *)maSearchResult{
    
    if (!_maSearchResult) {
        _maSearchResult = [NSMutableArray array];
    }
    return _maSearchResult;
}

- (YHConnectionSearchView *)searchView{
    if (!_searchView) {
        _searchView = [[YHConnectionSearchView alloc] initWithFrame:CGRectMake(0, kSearchBarH, SCREEN_WIDTH, SCREEN_HEIGHT-kSearchBarH-64-49)];
        _searchView.delegate = self;
        [self.view addSubview:_searchView];
    }
    return _searchView;
}

#pragma mark - initUI
- (void)initUI
{
    self.title = @"通讯录";
    
    //导航栏
    self.navigationController.navigationBar.translucent = NO;
    //    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRight:)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    //searchBar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchBarH)];
    searchBar.placeholder = @"搜索";
    searchBar.layer.borderWidth = 1;
    searchBar.layer.borderColor = kTbvBGColor.CGColor;
    searchBar.barTintColor = kTbvBGColor;
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar =searchBar;
    
    
    //tableView
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, kSearchBarH, SCREEN_WIDTH, SCREEN_HEIGHT-64-kSearchBarH-49) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight  = 60.0f;
    self.tableView.backgroundColor = kTbvBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = RGBCOLOR(160, 160, 160);
    [self.tableView registerClass:[CellForMyFri class] forCellReuseIdentifier:NSStringFromClass([CellForMyFri class])];
    [self.view addSubview:self.tableView];
    
    [self.tableView setEnableLoadNew:YES];
    
    //tableViewHeaderView
    _hView = [[YHConnectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTbvHeaderViewH)];
    _hView.iconNameArray = @[@"connections_img_newFriends",@"connections_img_groupChat"];
    _hView.itemNameArray = @[@"新的朋友",@"讨论组"];
    int newFri = [YHIMHandler sharedInstance].badgeModel.newFri;
    _hView.unReadMsgArray = @[@(newFri),@0];
    self.tableView.tableHeaderView = _hView;
    
    WeakSelf
    [self.hView didSelectRowHandler:^(NSIndexPath *indexPath) {
        if (indexPath.row == 0) {
            //新的好友
//            NewFansVC *vc = [[NewFansVC alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            //群聊
            NSString *path = [YHProtocol share].pathGroupList;
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@",[YHUserInfoManager sharedInstance].userInfo.accessToken]];
//            YHGroupListVC *vc = [[YHGroupListVC alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:path] loadCache:YES];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    //footerView
    _lbContacters = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    _lbContacters.backgroundColor  = [UIColor whiteColor];
    _lbContacters.textColor        = kGrayColor;
    _lbContacters.textAlignment    = NSTextAlignmentCenter;
    _lbContacters.hidden           = YES;
    self.tableView.tableFooterView = _lbContacters;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YHConnectionSearchViewDelegate
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath userInfo:(YHUserInfo *)userInfo{
    
    CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
    vc.hidesBottomBarWhenPushed = YES;
    char a = pinyinFirstLetter([userInfo.userName characterAtIndex:0]);
    NSString *key = [[NSString stringWithFormat:@"%c", a] uppercaseString];
    self.myFriManager.selPrefixLetter = key;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewWillBeginDragging{
    [self.searchBar resignFirstResponder];
    if (!self.searchBar.text.length) {
        self.searchView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString *key       = self.myFriManager.prefixLetters[section];
    NSArray  *arrayNick = self.myFriManager.usersDictSort[key];
    return arrayNick.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    CellForMyFri *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForMyFri class])];
    
    NSString *key       = [self.myFriManager.prefixLetters objectAtIndex:indexPath.section];
    NSArray *arrayNick  = self.myFriManager.usersDictSort[key];
    if (indexPath.row < arrayNick.count) {
        cell.model = [arrayNick objectAtIndex:indexPath.row];
        cell.delegate = self;
    }
    cell.imgvSel.hidden = YES;
    cell.btnTapScope.enabled = NO;
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.myFriManager.prefixLetters.count;
}


//点击索引栏滚动到指定位置
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    
    // 让table滚动到对应的indexPath位置
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    return [self.myFriManager.usersDictSort allKeys].count;
}

//索引栏数组
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *maIndex = [NSMutableArray array];
    if (self.myFriManager.prefixLetters && self.myFriManager.prefixLetters) {
        maIndex = [self.myFriManager.prefixLetters mutableCopy];
    }
    return maIndex;
}

//自定义headerInSectionView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    static NSString *headerId = @"headFoot";
    UITableViewHeaderFooterView * hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
    if (!hf) {
        hf = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerId];
        hf.contentView.backgroundColor = kTbvBGColor;
        
        //首字母
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 20)];
        labelTitle.tag = 101;
        labelTitle.font = [UIFont systemFontOfSize:14.0f];
        labelTitle.textColor = RGBCOLOR(160, 160, 160);
        [hf addSubview:labelTitle];
    }
    
    //设置section标题
    UILabel *labelTitle = (UILabel *)[hf viewWithTag:101];
    NSString *preLetter = [self.myFriManager.prefixLetters objectAtIndex:section];
    labelTitle.text = preLetter;
    return hf;
    
}

//headerInSection 行高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakSelf
    NSString *preLetter = [self.myFriManager.prefixLetters objectAtIndex:indexPath.section];
    NSArray *userListInpreLetter  = self.myFriManager.usersDictSort[preLetter];
    if (indexPath.row < userListInpreLetter.count) {
        CellForMyFri *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell startAnimation:^(BOOL finished) {
            YHUserInfo *userInfo  = userListInpreLetter[indexPath.row];
            CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
            vc.hidesBottomBarWhenPushed = YES;
            weakSelf.myFriManager.selPrefixLetter = preLetter;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        
        
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if(!searchBar.text.length){
        self.searchView.hidden = YES;
        [self.maSearchResult removeAllObjects];
        self.searchView.dataArray = self.maSearchResult;
        [self.searchView.tableView reloadData];
    }
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (!searchBar.text.length) {
        self.searchView.hidden = YES;
        return;
    }
    self.searchView.hidden = NO;
    //空格去除
    if([searchBar.text hasPrefix:@" "]){
        searchBar.text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    
    [self.maSearchResult removeAllObjects];
    for (int i= 0; i < self.myFriManager.prefixLetters.count; i++)
    {
        if (i < self.myFriManager.prefixLetters.count)
        {
            if (!self.myFriManager.prefixLetters[i]) {
                continue;
            }
            
            NSArray *arrayNick      = [self.myFriManager.usersDictSort valueForKey:self.myFriManager.prefixLetters[i]];
            
            for (YHABUserInfo *userInfo in arrayNick)
            {
                
                if ([userInfo.mobilephone containsString:searchBar.text] )
                {
                    [self.maSearchResult addObject:userInfo];
                    continue;
                }
                else if([userInfo.userName containsString:searchBar.text]){
                    [self.maSearchResult addObject:userInfo];
                    continue;
                }
                
                
            }
        }
    }
    
    self.searchView.dataArray = self.maSearchResult;
    [self.searchView.tableView reloadData];
    self.searchView.hidden = NO;
}

#pragma mark - CellForMyFriDelegate
- (void)didSelectOneFriend:(BOOL)didSel inCell:(CellForMyFri *)cell{
    
    WeakSelf
    [cell startAnimation:^(BOOL finished) {
        YHUserInfo *userInfo  = cell.model;
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
        vc.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
}



#pragma mark - Private
//设置联系人数量
- (void)_setupContactersCount:(NSInteger)count{
   _lbContacters.text = [NSString stringWithFormat:@"%ld位联系人",count];
}

/**
 *  获取排序后的好友数组
 *
 *  @param arrToSort 待排序的数组
 *
 *  @return 排序成功的数组
 */
- (NSMutableArray *)getSortArr:(NSMutableArray *)arrToSort
{
    //pei
//    [self setFooterCount:arrToSort.count];
    //pei
    [arrToSort sortUsingComparator:^NSComparisonResult(YHABUserInfo * obj1, YHABUserInfo * obj2) {
        
        return  [obj1.userName localizedCaseInsensitiveCompare:obj2.userName];
    }];
    
    NSMutableDictionary *dictSourceData = [NSMutableDictionary dictionary];
    for (YHABUserInfo *info in arrToSort) {
        if (!info.userName.length) {
            info.userName = @"匿名用户";
        }
        
        NSString *key = [NSString string];
        BOOL isEn = [info.userName isMatchedByRegex:@"^[a-zA-Z]+"];
        if(isEn){
            //首位为字母开头
            key = [[info.userName substringToIndex:1] uppercaseString];
        }else{
            char a = pinyinFirstLetter([info.userName characterAtIndex:0]);
            key = [[NSString stringWithFormat:@"%c", a] uppercaseString];
        }
        
        NSMutableArray *nickByLetter = dictSourceData[key];
        if (!nickByLetter) {
            nickByLetter = [NSMutableArray array];
            [dictSourceData setObject:nickByLetter forKey:key];
        }
        [nickByLetter addObject:info];
    }
    
    
    NSArray *tempKeySort = [[dictSourceData allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString  *obj1, NSString *obj2) {
        
        char a1 = [obj1 characterAtIndex:0];
        char a2 = [obj2 characterAtIndex:0];
        
        if (a1 > a2) {
            return NSOrderedDescending;
        }else if(a1 == a2){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
        
    }];
    
    NSMutableArray *maResultKeySort = [NSMutableArray arrayWithArray:tempKeySort];
    if(maResultKeySort.count)
    {
        if ([tempKeySort[0] isEqualToString:@"#"])
        {
            //交换首尾位置
            [maResultKeySort removeObject:@"#"];
            [maResultKeySort addObject:@"#"];
        }
        self.myFriManager.prefixLetters = maResultKeySort;
        self.myFriManager.usersDictSort = dictSourceData;
    }
    else{
        self.myFriManager.prefixLetters = nil;
        self.myFriManager.usersDictSort         = nil;
    }
    
    return  arrToSort;
}

- (void)showPopMenu{
    CGFloat itemH = 50;
    CGFloat w = 150;
    CGFloat h = itemH;
    CGFloat r = 5;
    CGFloat x = SCREEN_WIDTH - w - r;
    CGFloat y = 10;
    
    YHPopMenu *popView = [[YHPopMenu alloc] initWithFrame:CGRectMake(x, y, w, h)];
    popView.iconNameArray = @[@"chat_img_add"];
    popView.itemNameArray = @[@"添加朋友"];
    popView.itemH     = itemH;
    popView.fontSize  = 16.0f;
    popView.fontColor = [UIColor whiteColor];
    popView.canTouchTabbar = YES;
    [popView show];
    _popView = popView;
    
    WeakSelf
    [popView dismissWithHandler:^(BOOL isCanceled, NSInteger row) {
        if (!isCanceled) {
            
            DDLog(@"点击第%ld行",(long)row);
            if (!row) {
                AddFansViewController *vc = [[AddFansViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        
        weakSelf.rBtnSelected = NO;
    }];
}

- (void)hidePopMenuWithAnimation:(BOOL)animate{
    [_popView hideWithAnimate:animate];
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestMyfriendsListLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    [self requestMyfriendsListLoadNew:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     [self.view endEditing:YES];
}


#pragma mark - NSNotification
- (void)refreshPage:(NSNotification *)aNotification{
    [self requestMyfriendsListLoadNew:YES];
}

- (void)handleLogout{
    [self.myFriManager.allFriendsArray removeAllObjects];
    [self.myFriManager.prefixLetters removeAllObjects];
    [self.myFriManager.usersDictSort removeAllObjects];
    [self.tableView reloadData];
}

- (void)handleBadge{
    int newFri = [YHIMHandler sharedInstance].badgeModel.newFri;
    _hView.unReadMsgArray = @[@(newFri),@0];
    [self.hView.tableView reloadData];
    
}

#pragma mark - Action
//点击搜索
- (void)onSearch:(UIBarButtonItem *)sender
{
    //    YHSearchViewController *vc = [[YHSearchViewController alloc] init];
    //    vc.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)onRight:(id)sender{
    //pei
    AddFansViewController *vc = [[AddFansViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    //pei
    
//    _rBtnSelected = !_rBtnSelected;
//    if (_rBtnSelected) {
//        [self showPopMenu];
//    }else{
//        [self hidePopMenuWithAnimation:YES];
//    }
}


#pragma mark - 网络请求
- (void)requestMyfriendsListLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curMyFriendsReqPage = 1;
        refreshType = YHRefreshType_LoadNew;
        [(YHRefreshTableView *)self.tableView setNoMoreData:NO];
    }
    else{
        _curMyFriendsReqPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof(self)weakSelf = self;
    [(YHRefreshTableView *)self.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] postMyFriendsCount:1000 currentPage:_curMyFriendsReqPage complete:^(BOOL success, id obj)
     {
         [(YHRefreshTableView *)weakSelf.tableView loadFinish:refreshType];
         weakSelf.lbContacters.hidden = NO;
         if (success)
         {
             NSArray *retArray  = obj[@"friends"];
             //             DDLog(@"我的好友列表:%@ \n数量%lu",retArray,(unsigned long)retArray.count);
             if (loadNew){
                 
                 weakSelf.myFriManager.allFriendsArray = [NSMutableArray arrayWithArray:retArray];
             }
             else{
                 
                 if (retArray.count) {
                     [weakSelf.myFriManager.allFriendsArray addObjectsFromArray:retArray];
                 }
                 
             }
             
             [weakSelf _setupContactersCount:weakSelf.myFriManager.allFriendsArray.count];
             //缓存方式二：文件
             //             [[YHCacheManager shareInstance] cacheMyFriendsList:weakSelf.myFriManager.allFriendsArray];
             
             //缓存方式一：DB
             [[SqliteManager sharedInstance] updateFrisListWithFriID:[YHUserInfoManager sharedInstance].userInfo.uid frislist:retArray complete:^(BOOL success, id obj) {
                 if (success) {
                     DDLog(@"更新好友列表成功");
                 }else{
                     DDLog(@"更新好友列表失败");
                 }
             }];
             
             if (retArray.count < lengthForEveryRequest)
             {
                 
                 if(loadNew){
                     
                     [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                     
                 }
                 else{
                     
                     [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                 }
                 
             }
             
             [weakSelf getSortArr:weakSelf.myFriManager.allFriendsArray];
             
             [weakSelf.tableView reloadData];
             
         }
         else
         {
             
             if (isNSDictionaryClass(obj))
             {
                 //服务器返回的错误描述
                 NSString *msg  = obj[kRetMsg];
                 
                 postTips(msg, @"获取我的好友失败");
                 
             }
             else
             {
                 //AFN请求失败的错误描述
                 postTips(obj, @"获取我的好友失败");
             }
             
         }
         
     }];
}

#pragma mark - Life
- (void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    _rBtnSelected = NO;
    [_popView hideWithAnimate:NO];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    _isSelbtnAdd = NO;
    
    [super viewWillAppear:animated];
    
    if (!self.myFriManager.allFriendsArray.count) {
        [self requestMyfriendsListLoadNew:YES];
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"YHDiscoveryView.click" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_SystemFontSize_Change object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_MyFriendsPage_Refresh object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_Logout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_TabbarBadeg_Update object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadBadgeForloginSuccess" object:nil];
    
}
/*
 * #pragma mark - Navigation
 *
 *  // In a storyboard-based application, you will often want to do a little preparation before navigation
 *  - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 *   // Get the new view controller using [segue destinationViewController].
 *   // Pass the selected object to the new view controller.
 *  }
 */

@end
