//
//  NewFansViewController.m
//  PikeWay
//
//  Created by YHIOS002 on 16/4/19.
//  Copyright © 2016年 YHSoft. All rights reserved.
//  新加好友

#import "NewFansVC.h"
#import "CellForNewFri.h"
#import "CardDetailViewController.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "YHRefreshTableView.h"
#import "YHCacheManager.h"
#import "YHIMHandler.h"
#import "YHSqliteManager.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "MBProgressHUD.h"
#import "YHChatDevelop-Swift.h"
#import "Masonry.h"
//#import "UITableView+Extension.h"
#import "AddFansViewController.h"

@interface NewFansVC ()<UITableViewDelegate,UITableViewDataSource,CellForNewFriDelegate>{
    int _currentRequestPage;
}
@property (nonatomic,strong) CellForNewFri *testCell;
@property (nonatomic,strong) NSMutableArray <YHUserInfo *>*dataArray;
@property (nonatomic,strong) YHRefreshTableView *tableView;
@end


@implementation NewFansVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"新的朋友";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    int newFri = [YHIMHandler sharedInstance].badgeModel.newFri;
    //没有新的好友
    if (newFri <= 0){
        
        self.view.backgroundColor = kTbvBGColor;
        
        UILabel *lbTitle = [UILabel new];
        lbTitle.font = [UIFont systemFontOfSize:14.0];
        lbTitle.text = @"未有人向你发送添加好友的申请";
        [self.view addSubview:lbTitle];
        
        UILabel *lbCan = [UILabel new];
        lbCan.font = [UIFont systemFontOfSize:15.0];
        lbCan.text = @"您可以";
        [self.view addSubview:lbCan];
        
        //白色背景
        UIView *viewAddFriBG = [UIView new];
        [viewAddFriBG addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnViewAddFri:)]];
        viewAddFriBG.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:viewAddFriBG];
        
        UIImageView *imgvAdd = [UIImageView new];
        imgvAdd.image = [UIImage imageNamed:@"header_add"];
        [viewAddFriBG addSubview:imgvAdd];
        
        UILabel *lbAdd = [UILabel new];
        lbAdd.font = [UIFont systemFontOfSize:17.0];
        lbAdd.text = @"添加好友";
        [viewAddFriBG addSubview:lbAdd];
        
        WeakSelf
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.view).offset(20);
            make.centerX.equalTo(weakSelf.view.mas_centerX);
        }];
        
        [lbCan mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view).offset(15);
            make.top.equalTo(lbTitle.mas_bottom).offset(20);
        }];
        
        [viewAddFriBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf.view);
            make.top.equalTo(lbCan.mas_bottom).offset(15);
            make.height.mas_equalTo(55);
        }];
        
        [imgvAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(viewAddFriBG).offset(25);
            make.centerY.equalTo(viewAddFriBG.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [lbAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imgvAdd.mas_right).offset(20);
            make.centerY.equalTo(viewAddFriBG.mas_centerY);
        }];
        
        return;
    }
    
    
    //tableView
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kTbvBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = RGBCOLOR(160, 160, 160);
    [self.tableView registerClass:[CellForNewFri class] forCellReuseIdentifier:NSStringFromClass([CellForNewFri class])];
    [self.view addSubview:self.tableView];
    
    
    [self.tableView setEnableLoadNew:YES];
    [self.tableView setEnableLoadMore:YES];
    
    //请求数据
    
    NSArray *cacheNewFriends = [[YHCacheManager shareInstance] getCacheNewFriendsList];
    if (cacheNewFriends) {
        self.dataArray = [cacheNewFriends mutableCopy];
        [self.tableView reloadData];
    }
    
    [self requestGetNewAddFriendsLoadNew:YES];
    
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage:) name:Event_NewFriendsPage_Refresh object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<YHUserInfo *> *)dataArray{
    if (!_dataArray) {
        _dataArray =[NSMutableArray array];
    }
    return  _dataArray;
}

#pragma mark - Gesture
- (void)gestureOnViewAddFri:(UIGestureRecognizer *)aGes{
    if (aGes.state == UIGestureRecognizerStateEnded) {
        AddFansViewController *vc = [[AddFansViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CellForNewFri *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForNewFri class])];
    if (!cell) {
        cell = [[CellForNewFri alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForNewFri class])];
    }
    cell.delegate = self;
    if (indexPath.row < self.dataArray.count) {
        cell.indexPath = indexPath;
        [cell setModel:self.dataArray[indexPath.row]];
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //文本section
    if (indexPath.row < _dataArray.count) {
        YHUserInfo *model = _dataArray[indexPath.row];
        CGFloat height = 0.0f;
        height = [CellForNewFri hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            CellForNewFri *cell = (CellForNewFri *)sourceCell;
            
            cell.model = model;
            
        }];
        return height;
    }
    return 94;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //进入陌生人名片页
    if (indexPath.row < _dataArray.count)
    {
        YHUserInfo *userInfo = _dataArray[indexPath.row];
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete && _dataArray.count > indexPath.row){
        YHUserInfo *model = _dataArray[indexPath.row];
        [_dataArray removeObjectAtIndex:indexPath.row];
        [_tableView deleteRow:indexPath.row inSection:indexPath.section withRowAnimation:UITableViewRowAnimationLeft];
        
        [self requestDeleteRecordOfAddFriWithFriModel:model retryCount:3];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark -  CellForNewAddFansDelegate
- (void)onAccepetNewFriendInCell:(CellForNewFri *)cell{
    
    __weak typeof(self)weakSelf = self;
    __block MBProgressHUD *hud = showHUDWithText(@"", self.view);
    [[NetManager sharedInstance] postAcceptAddFriendRequest:cell.model.uid complete:^(BOOL success, id obj) {
        [hud hide:YES];
        if (success)
        {
            DDLog(@"接受加好友请求成功,%@",obj);
            if(cell.indexPath.row < [_dataArray count]){
                YHUserInfo *userInfo = _dataArray[cell.indexPath.row];
                userInfo.friShipStatus = FriendShipStatus_isMyFriend;
                [weakSelf.tableView reloadData];
                [YHIMHandler sharedInstance].badgeModel.newFri -= 1;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Event_MyFriendsPage_Refresh object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:Event_TabbarBadeg_Update object:@"newFri"];
                
            }
            
        }
        else{
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"接受加好友请求失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"接受加好友请求失败");
            }
        }
    }];
}

#pragma mark - 网络请求
//删除好友申请记录
- (void)requestDeleteRecordOfAddFriWithFriModel:(YHUserInfo *)friModel retryCount:(int)retryCount{
    __block int count = retryCount;
    WeakSelf
    [[NetManager sharedInstance] postDeleteRecordOfAddFriWithFriID:friModel.uid complete:^(BOOL success, id obj) {
        if (success) {
            count = 0;
            if (friModel.friShipStatus != FriendShipStatus_isMyFriend) {
                [YHIMHandler sharedInstance].badgeModel.newFri -= 1;
                [[NSNotificationCenter defaultCenter] postNotificationName:Event_TabbarBadeg_Update object:@"newFri"];
            }
            DDLog(@"删除好友申请记录成功,%@",obj);
        }else{
            if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable) {
                count = 0;
            }else{
                count --;
            }
            
            if (isNSDictionaryClass(obj)){
                postTips(obj, @"删除好友申请记录失败");
            }else{
                postTips(obj, nil);
            }
            
            if (count > 0){
                [weakSelf requestDeleteRecordOfAddFriWithFriModel:friModel retryCount:count];
            }
        }
    }];
   
    
}

- (void)requestGetNewAddFriendsLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _currentRequestPage = 1;
        refreshType = YHRefreshType_LoadNew;
        [(YHRefreshTableView *)self.tableView setNoMoreData:NO];
    }
    else{
        _currentRequestPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof (self)weakSelf = self;
    [(YHRefreshTableView *)self.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] postNewAddFriendsCount:lengthForEveryRequest currentPage:_currentRequestPage complete:^(BOOL success, id obj) {
        
        [(YHRefreshTableView *)weakSelf.tableView loadFinish:refreshType];
        
        if (success)
        {
            NSArray *retArray = obj[@"newFriends"];
            if (loadNew)
            {
                
                weakSelf.dataArray = [NSMutableArray arrayWithArray:retArray];
                
            }
            else
            {
                if (retArray.count) {
                    [weakSelf.dataArray addObjectsFromArray:retArray];
                }
                
            }
            
            [[YHCacheManager shareInstance] cacheNewFriendsList:weakSelf.dataArray];
            
            if (retArray.count < lengthForEveryRequest)
            {
                
                if(loadNew)
                {
                    if(!retArray.count){
                        DDLog(@"下拉刷新总数据条数为0");
                        [(YHRefreshTableView *)weakSelf.tableView setNoData:YES withText:@"没有新的好友"];
                    }
                    
                    [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                    
                    
                }
                else
                {
                    
                    [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                    
                }
                
            }
            
            [weakSelf.tableView reloadData];
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"接受加好友请求失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"接受加好友请求失败");
            }
            
        }
        
    }];
}


#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestGetNewAddFriendsLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    [self requestGetNewAddFriendsLoadNew:NO];
}

#pragma mark - Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSNotification
- (void)refreshPage:(NSNotification *)aNotification
{
    
    NSDictionary *dict =  aNotification.userInfo;
    YHUserInfo *userInfo  = dict[@"userInfo"];
    __weak typeof(self)weakSelf = self;
    [_dataArray enumerateObjectsUsingBlock:^(YHUserInfo *obj , NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uid isEqualToString:userInfo.uid])
        {
            //            obj = userInfo;
            [weakSelf.tableView reloadData];
            *stop = YES;
        }
    }];
    
}

#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
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
