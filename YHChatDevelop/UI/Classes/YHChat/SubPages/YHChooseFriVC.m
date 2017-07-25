//
//  YHChooseFriVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHChooseFriVC.h"
#import "YHRefreshTableView.h"
#import "RegexKitLite.h"
#import "pinyin.h"
#import "ChineseString.h"
//#import "YHCacheManager.h"
#import "CellForMyFri.h"
#import "YHSearchFriView.h"
#import "YHSearchFriBar.h"
#import "YHNetManager.h"
#import "YHUserInfoManager.h"
#import "YHSqliteManager.h"
#import "Masonry.h"
#import "YHChatModel.h"
#import "YHChatDevelop-Swift.h"
#import "YHGroupMember.h"
#import "MBProgressHUD.h"

static const CGFloat kheaderHeightInsection = 20; //section的header高度
static const CGFloat kSearchBarH = 44;
@interface YHChooseFriVC () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,CellForMyFriDelegate,YHSearchFriBarDelegate,YHSearchFriViewDelegate>{
    
}

@property (nonatomic, strong) YHRefreshTableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *rBarItem;
@property (nonatomic, strong) UIButton *btnRight;
@property (nonatomic, strong) YHSearchFriView *searchView;
@property (nonatomic, strong) YHSearchFriBar *searchFriBar;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *prefixLetters;
@property (nonatomic, strong) NSMutableDictionary *usersDictSort;
@property (nonatomic, strong) NSMutableArray <YHUserInfo *>*selFriArray;//选择的好友Array
@property (nonatomic, strong) NSMutableDictionary *maDictSort;         //排序后的字典
@property (nonatomic, strong) NSMutableArray *maSearchResult;

//以下属性是提供给消息转发页用
@property (nonatomic, copy) void(^selFrisBlock)(NSArray <YHChatModel *>*selFris);
@property (nonatomic, strong) NSMutableArray <YHChatModel *>*maSelFrisToSendMsg;

//以下属性是提供给邀请好友到群聊用
@property (nonatomic, strong) NSMutableArray <YHGroupMember *>*maGroupMembers;
@property (nonatomic, strong) dispatch_group_t group;
@end

@implementation YHChooseFriVC

/****Note:该控制器为三个不同页面重用,使用时以PageTypeOptions区分！！！****/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    //缓存方式二:文件
//    NSArray *cacheList = [[YHCacheManager shareInstance] getCacheMyFriendsList];
//    
//    //    [self test];
//    if (cacheList.count)
//    {
//        self.dataArray = [cacheList mutableCopy];
//        [self getSortArr:self.dataArray];
//        [self.tableView reloadData];
//    }
//    [self requestMyfriendsListLoadNew:YES];
    
    //缓存方式一:DB
    WeakSelf

    if(_pageType == PageType_AddGroupChatMember){
        //已存在于群聊中的好友不可选
        _group = dispatch_group_create();
        
        //数据库中查询
        [[SqliteManager sharedInstance] queryFrisTableWithFriID:[YHUserInfoManager sharedInstance].userInfo.uid userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
            
            if (success) {
                NSArray *cacheList = obj;
                DDLog(@"query success :%@",cacheList);
                if(cacheList.count){
                    weakSelf.dataArray = [cacheList mutableCopy];
                    [weakSelf getSortArr:weakSelf.dataArray];
                    [weakSelf.tableView reloadData];
                }
            }
            
            dispatch_group_enter(weakSelf.group);
            [self requestGroupMembers];
            dispatch_group_enter(_group);
            [self requestMyfriendsListLoadNew:YES];
            dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
                for (int i=0; i<_maGroupMembers.count; i++) {
                    YHGroupMember *groupM = _maGroupMembers[i];
                    for (int j=0; j<self.dataArray.count; j++) {
                        YHUserInfo *userInfo = self.dataArray[j];
                        if ([userInfo.uid isEqualToString:groupM.userID]) {
                            userInfo.likeCount = 1;
                            userInfo.isInMyBlackList = YES;
                            break;
                        }
                    }
                }
                [self.tableView reloadData];
            });
            
        }];
        
    
    }else{
        
        [[SqliteManager sharedInstance] queryFrisTableWithFriID:[YHUserInfoManager sharedInstance].userInfo.uid userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
            if (success) {
                NSArray *cacheList = obj;
                DDLog(@"query success :%@",cacheList);
                if(cacheList.count){
                    weakSelf.dataArray = [cacheList mutableCopy];
                    [weakSelf getSortArr:weakSelf.dataArray];
                    [weakSelf.tableView reloadData];
                }
            }
        }];
        [self requestMyfriendsListLoadNew:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initUI
{
    if (!self.barTitle.length) {
        self.title = @"发起讨论";
    }else{
        self.title = self.barTitle;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    //tableView
    CGFloat tableViewH = SCREEN_HEIGHT-64-kSearchBarH;
    if (self.pageType == PageType_RetWeetMsg) {
        tableViewH = SCREEN_HEIGHT-64-kSearchBarH - 44;//44是标签栏高度
    }
    CGRect frame = CGRectMake(0, kSearchBarH, SCREEN_WIDTH, tableViewH);
    YHRefreshTableView *tableView = [[YHRefreshTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 60;
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = RGBCOLOR(160, 160, 160);
    [tableView registerClass:[CellForMyFri class] forCellReuseIdentifier:NSStringFromClass([CellForMyFri class])];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    //headerView
    if (self.pageType == PageType_CreatGroupChat) {
        [self setUpTableViewHeaderView];
    }
    
    //1.左BarItem
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(0, 0, 40, 40);
    [cancelBtn setImage:[UIImage imageNamed:@"common_leftArrow"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    cancelBtn.titleLabel.textColor = [UIColor whiteColor];
    [cancelBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    
    //右BarItem
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    btnRight.layer.cornerRadius  = 3;
    btnRight.layer.masksToBounds = YES;
    btnRight.backgroundColor = [kTbvBGColor colorWithAlphaComponent:0.8];
    [btnRight setTitle:@"添加" forState:UIControlStateNormal];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnRight setTitleColor:kBlueColor forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(onSure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rBarItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    rBarItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rBarItem;
    _btnRight = btnRight;
    _rBarItem = rBarItem;
    
    
    //searchBar
    YHSearchFriBar *bar = [[YHSearchFriBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchBarH)];
    bar.delegate = self;
    bar.searchBar.delegate = self;
    [self.view addSubview:bar];
    _searchFriBar = bar;
    
}

- (void)setUpTableViewHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    UITapGestureRecognizer *tapHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseGroup:)];
    [headerView addGestureRecognizer:tapHeaderView];
    
    UILabel *lbChooseGroup = [UILabel new];
    lbChooseGroup.textAlignment = NSTextAlignmentLeft;
    [lbChooseGroup setTextColor:[UIColor blackColor]];
    lbChooseGroup.text = @"选择一个群";
    lbChooseGroup.font = [UIFont systemFontOfSize:14.0f];
    [headerView addSubview:lbChooseGroup];
    [lbChooseGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView).offset(15);
        make.centerY.mas_equalTo(headerView.mas_centerY);
    }];
    self.tableView.tableHeaderView = headerView;
    
}

#pragma mark - Lazy Load
- (NSMutableArray<YHGroupMember *> *)maGroupMembers{
    if (!_maGroupMembers) {
        _maGroupMembers = [NSMutableArray array];
    }
    return _maGroupMembers;
}

- (NSMutableArray<YHUserInfo *> *)selFriArray{
    if (!_selFriArray) {
        _selFriArray = [NSMutableArray array];
    }
    return _selFriArray;
}

- (YHSearchFriView *)searchView{
    if (!_searchView) {
        _searchView = [[YHSearchFriView alloc] initWithFrame:CGRectMake(0, kSearchBarH, SCREEN_WIDTH, SCREEN_HEIGHT-kSearchBarH-64)];
        _searchView.delegate = self;
        [self.view addSubview:_searchView];
    }
    return _searchView;
}

- (NSMutableArray *)maSearchResult{
    
    if (!_maSearchResult) {
        _maSearchResult = [NSMutableArray array];
    }
    return _maSearchResult;
}

- (NSMutableArray <YHChatModel *>*)maSelFrisToSendMsg{
    if (!_maSelFrisToSendMsg) {
        _maSelFrisToSendMsg = [NSMutableArray array];
    }
    return _maSelFrisToSendMsg;
}

#pragma mark - 网络请求
- (void)requestMyfriendsListLoadNew:(BOOL)loadNew
{
    __weak typeof(self) weakSelf = self;
    
    [[NetManager sharedInstance] postMyFriendsCount:300 currentPage:1 complete:^(BOOL success, id obj)
     {
         if (success){
             
             NSArray *retArray = obj[@"friends"];
             DDLog(@"我的好友列表:%@ \n数量%lu", retArray, (unsigned long)retArray.count);
             
             if (loadNew){
                 
                 weakSelf.dataArray = [NSMutableArray arrayWithArray:retArray];
             }
             else{
                 
                 if (retArray.count){
                     [weakSelf.dataArray addObjectsFromArray:retArray];
                 }
             }

             
             if (retArray.count < lengthForEveryRequest){
 
                 if (loadNew){
                     
                     if (!retArray.count){
                         
                         [(YHRefreshTableView *) weakSelf.tableView setNoData:YES withText:@"暂无朋友"];
                     }
                 }
                 
                 
             }
             [weakSelf getSortArr:weakSelf.dataArray];
             
             [weakSelf.tableView reloadData];
         }
         else{
             
             if (isNSDictionaryClass(obj)){
                 
                 //服务器返回的错误描述
                 NSString *msg = obj[kRetMsg];
                 
                 postTips(msg, @"获取我的好友失败");
             }else{
                 //AFN请求失败的错误描述
                 postTips(obj, @"获取我的好友失败");
             }
         }
         if (weakSelf.group) {
              dispatch_group_leave(weakSelf.group);
         }
        
     }];
}

//发起群聊
- (void)requestCreatGroupChat{
    
    [MBProgressHUD showHUDAddedTo:KEYWINDOW animated:YES];
    WeakSelf
    [[NetManager sharedInstance] postCreatGroupChatWithUserArray:self.selFriArray complete:^(BOOL success, id obj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:KEYWINDOW animated:YES];
            if (success) {
                
                DDLog(@"creat group chat success:%@",obj);
                //           NSString *groupName = [obj valueForKey:@"groupName"];
                NSString *groupId = [obj valueForKey:@"id"];
                
                NSString *path = [YHProtocol share].pathGroupChat;
                path = [NSString stringWithFormat:@"%@/%@?accessToken=%@",path,groupId,[YHUserInfoManager sharedInstance].userInfo.accessToken];
                
//                YHChatVC *vc = [[YHChatVC alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:path] loadCache:YES];
//                vc.pageType = 1;  
//                vc.sessionID = groupId;
//                
//                //设置群名
//                NSString *groupName = [obj valueForKey:@"groupName"];
//                if (!groupName.length) {
//                    groupName = @"群聊";
//                }
//                vc.title = groupName;
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];

                
            }else{
                DDLog(@"fail creat group chat :%@",obj);
                if (isNSDictionaryClass(obj))
                {
                    //服务器返回的错误描述
                    NSString *msg  = obj[kRetMsg];
                    
                    postTips(msg, @"发起群聊失败");
                }
                else
                {
                    //AFN请求失败的错误描述
                    postTips(obj, @"发起群聊失败");
                }
                
                
            }
        });
        
    }];
}

//邀请好友进入群聊
- (void)requestAddGroupMember{
    WeakSelf
    [MBProgressHUD showHUDAddedTo:KEYWINDOW animated:YES];
    [[NetManager sharedInstance] postAddGroupMemberWithGroupId:self.groupId userArray:self.selFriArray complete:^(BOOL success, id obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:KEYWINDOW animated:YES];
            
            if(success){
                
                //返回到群设置页
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:Event_GroupSettingPage_Refresh object:nil];
            }else{
                DDLog(@"fail add group member :%@",obj);
                if (isNSDictionaryClass(obj))
                {
                    //服务器返回的错误描述
                    NSString *msg  = obj[kRetMsg];
                    
                    postTips(msg, @"邀请好友失败");
                }
                else
                {
                    //AFN请求失败的错误描述
                    postTips(obj, @"邀请好友失败");
                }
            }
        });
    }];
}


//获取群成员
- (void)requestGroupMembers{
    WeakSelf
    [[NetManager sharedInstance] getGroupMemebersWithGroupID:_groupId complete:^(BOOL success, id obj) {
        dispatch_group_leave(weakSelf.group);
        if (success) {
            weakSelf.maGroupMembers = obj;
        }else{
            DDLog(@"获取群成员失败,%@",obj);
        }
    }];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = self.prefixLetters[section];
    NSArray *arrayNick = self.usersDictSort[key];
    
    return arrayNick.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellForMyFri *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForMyFri class])];
    
    NSString *key = [self.prefixLetters objectAtIndex:indexPath.section];
    NSArray *arrayNick = self.usersDictSort[key];
    if (_pageType == PageType_AddGroupChatMember) {
        cell.isInviteFrisToGroupChat = YES;
    }else{
         cell.isInviteFrisToGroupChat = NO;
    }
    if (indexPath.row < arrayNick.count)
    {
        cell.model = [arrayNick objectAtIndex:indexPath.row];
        cell.delegate = self;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.prefixLetters.count;
}

//点击索引栏滚动到指定位置
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    
    // 让table滚动到对应的indexPath位置
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return [self.usersDictSort allKeys].count;
}

//索引栏数组
- (NSArray <NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *maIndex = [NSMutableArray array];
    
    if (self.prefixLetters && self.prefixLetters)
    {
        maIndex = [self.prefixLetters mutableCopy];
    }
    return maIndex;
}

//自定义headerInSectionView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerId = @"headFoot";
    UITableViewHeaderFooterView *hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
    
    if (!hf)
    {
        hf = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerId];
        hf.contentView.backgroundColor = kTbvBGColor;
        
        //首字母
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, kheaderHeightInsection)];
        labelTitle.tag = 101;
        labelTitle.font = [UIFont systemFontOfSize:14.0f];
        labelTitle.textColor = RGBCOLOR(160, 160, 160);
        [hf addSubview:labelTitle];
    }
    
    //设置section标题
    UILabel *labelTitle = (UILabel *)[hf viewWithTag:101];
    NSString *preLetter = [self.prefixLetters objectAtIndex:section];
    labelTitle.text = preLetter;
    return hf;
}

//headerInSection 行高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kheaderHeightInsection;
}

//选中某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *preLetter = [self.prefixLetters objectAtIndex:indexPath.section];
    NSArray *userListInpreLetter = self.usersDictSort[preLetter];
    
    if (indexPath.row < userListInpreLetter.count)
    {
        
        
    }
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if(!searchBar.text.length){
        self.searchView.hidden = NO;
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
    for (int i= 0; i < self.prefixLetters.count; i++)
    {
        if (i < self.prefixLetters.count)
        {
            if (!self.prefixLetters[i]) {
                continue;
            }
            
            NSArray *arrayNick      = [self.usersDictSort valueForKey:self.prefixLetters[i]];
            
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
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


#pragma mark - CellForMyFriDelegate
- (void)didSelectOneFriend:(BOOL)didSel inCell:(CellForMyFri *)cell{
    
    [self _setUpSearchBarAndSearchView:didSel userInfo:cell.model];
}

- (void)_setUpSearchBarAndSearchView:(BOOL)didSel userInfo:(YHUserInfo *)userInfo{
    if (didSel) {
        [self.selFriArray addObject:userInfo];
    }else{
        [self.selFriArray removeObject:userInfo];
    }
    
    self.searchFriBar.selFriArray = self.selFriArray;
    [self.searchFriBar setupScrollViewDidSel:didSel userInfo:userInfo];
    
    
    
    //设置导航栏右按钮
    if (self.selFriArray.count) {
        self.btnRight.backgroundColor = kTbvBGColor;
        [self.btnRight setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selFriArray.count] forState:UIControlStateNormal];
        _rBarItem.enabled = YES;
    }else{
        self.btnRight.backgroundColor = [kTbvBGColor colorWithAlphaComponent:0.8];
        [self.btnRight setTitle:[NSString stringWithFormat:@"添加"] forState:UIControlStateNormal];
        _rBarItem.enabled = NO;
    }
    
    
    //消息转发页用
    if (self.pageType == PageType_RetWeetMsg && self.selFrisBlock) {
        if (didSel) {
            YHChatModel *model = [YHChatModel new];
            model.chatType = 0;
            model.audienceId = userInfo.uid;
            [self.maSelFrisToSendMsg addObject:model];
        }else{
            for (YHChatModel *model  in self.maSelFrisToSendMsg) {
                if([model.audienceId isEqualToString:userInfo.uid]){
                    [self.maSelFrisToSendMsg removeObject:model];
                    break;
                }
            }
        }
        if(self.selFrisBlock){
            self.selFrisBlock(self.maSelFrisToSendMsg);
        }
    }
    
}


#pragma mark - YHSearchFriBarDelegate
//取消选中图像
- (void)deSelectAvatarWithUserInfo:(YHUserInfo *)userInfo{
    
    [self _setUpSearchBarAndSearchView:NO userInfo:userInfo];
    [self.tableView reloadData];
    
}

#pragma mark - YHSearchFriViewDelegate
- (void)didSelSearchFri:(BOOL)didSel userArray:(NSArray *)userArray{
    
    [self _setUpSearchBarAndSearchView:didSel userInfo:userArray[0]];
    
    self.searchView.hidden = YES;
    [self.tableView reloadData];
    
    self.searchFriBar.searchBar.text = @"";
    [self.searchFriBar.searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging{
    [self.view endEditing:YES];
    if (!self.searchFriBar.searchBar.text.length) {
        self.searchView.hidden = YES;
    }
}


#pragma mark - Private

/**
 *  获取排序后的好友数组
 *
 *  @param arrToSort 待排序的数组
 *
 *  @return 排序成功的数组
 */
- (NSMutableArray *)getSortArr:(NSMutableArray *)arrToSort
{
    [arrToSort sortUsingComparator:^NSComparisonResult (YHUserInfo *obj1, YHUserInfo *obj2) {
        return [obj1.userName localizedCaseInsensitiveCompare:obj2.userName];
    }];
    
    NSMutableDictionary *dictSourceData = [NSMutableDictionary dictionary];
    
    for (YHUserInfo *info in arrToSort)
    {
        if (!info.userName.length)
        {
            info.userName = @"匿名用户";
        }
        
        NSString *key = [NSString string];
        BOOL isEn = [info.userName isMatchedByRegex:@"^[a-zA-Z]+"];
        
        if (isEn)
        {
            //首位为字母开头
            key = [[info.userName substringToIndex:1] uppercaseString];
        }
        else
        {
            char a = pinyinFirstLetter([info.userName characterAtIndex:0]);
            key = [[NSString stringWithFormat:@"%c", a] uppercaseString];
        }
        
        NSMutableArray *nickByLetter = dictSourceData[key];
        
        if (!nickByLetter)
        {
            nickByLetter = [NSMutableArray array];
            [dictSourceData setObject:nickByLetter forKey:key];
        }
        [nickByLetter addObject:info];
    }
    
    NSArray *tempKeySort = [[dictSourceData allKeys] sortedArrayUsingComparator:^NSComparisonResult (NSString *obj1, NSString *obj2) {
        char a1 = [obj1 characterAtIndex:0];
        char a2 = [obj2 characterAtIndex:0];
        
        if (a1 > a2)
        {
            return NSOrderedDescending;
        }
        else if (a1 == a2)
        {
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    NSMutableArray *maResultKeySort = [NSMutableArray arrayWithArray:tempKeySort];
    
    if (maResultKeySort.count)
    {
        if ([tempKeySort[0] isEqualToString:@"#"])
        {
            //交换首尾位置
            [maResultKeySort removeObject:@"#"];
            [maResultKeySort addObject:@"#"];
        }
        self.prefixLetters = maResultKeySort;
        self.usersDictSort = dictSourceData;
    }
    else
    {
        self.prefixLetters = nil;
        self.usersDictSort = nil;
    }
    
    return arrToSort;
}

#pragma mark - Action
- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSure:(id)sender{
    DDLog(@"确定");
    if (self.pageType == PageType_CreatGroupChat) {
        [self requestCreatGroupChat];
    }else{
        [self requestAddGroupMember];
    }
    
}

//选择一个群
- (void)onChooseGroup:(id)sender{
    DDLog(@"选择一个群");
    
//    NSString *path = [YHProtocol share].pathGroupList;
//    path = [path stringByAppendingString:[NSString stringWithFormat:@"?accessToken=%@",[YHUserInfoManager sharedInstance].userInfo.accessToken]];
//    YHGroupListVC *vc = [[YHGroupListVC alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:path] loadCache:YES];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    
    YHGroupListViewController *vc = [[YHGroupListViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Public
- (void)selectFrisComplete:(void(^)(NSArray <YHChatModel *>*selFris))complete{
    _selFrisBlock = complete;
}

#pragma mark - Life
- (void)dealloc
{
    DDLog(@"%s vc dealloc", __FUNCTION__);
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
