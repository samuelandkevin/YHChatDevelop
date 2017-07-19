//
//  MyVisitorsViewController.m
//  samuelandkevin
//
//  Created by 许samuelandkevin on 16/4/13.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "MyVisitorsViewController.h"
#import "VistorCell.h"
#import "CardDetailViewController.h"
#import "YHUICommon.h"
#import "YHNetManager.h"
#import "YHRefreshTableView.h"
//#import "MyDetailEditViewController.h"
#import "YHSqliteManager.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "YHChatDevelop-Swift.h"

@interface MyVisitorsViewController ()<UITableViewDelegate,UITableViewDataSource,VistorCellDelegate>{
    int _curVistorListReqPage;
    BOOL _noMoreDataInDB;      //数据库无更多数据
    YHUserInfo *_lastDataInDB;//上一条在数据库的动态
}

@property(nonatomic,strong) YHRefreshTableView * tableView;
@property(nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation MyVisitorsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    [self initUI];
    
  
    //缓存方式二：
//    NSArray *cacheMyVisitors = [[YHCacheManager shareInstance] getCacheMyVisitorsList];
//    if (cacheMyVisitors.count) {
//        self.dataArray = [cacheMyVisitors mutableCopy];
//        [self.tableView reloadData];
//    }
//
//    [self requestGetMyVistorListLoadNew:YES];
    
    //缓存方式一:
    [self _loadFromDBWithLastData:nil loadNew:YES];
    

}

- (void)initUI{
    self.title = @"我的访客";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[YHRefreshTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight  = 90.0f;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.tableView setEnableLoadNew:YES];
    [self.tableView setEnableLoadMore:YES];
    self.view.backgroundColor = kTbvBGColor;
    UINib *nib = [UINib nibWithNibName:@"VistorCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"VistorCell"];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
         _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - Life

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private
//从数据库加载动态,loadNew:是否加载最新的数据
- (void)_loadFromDBWithLastData:(YHUserInfo *)lastData loadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        refreshType = YHRefreshType_LoadNew;
        [self.tableView setNoMoreData:NO];
    }
    else{
        refreshType = YHRefreshType_LoadMore;
    }
    
    WeakSelf
    [self.tableView loadBegin:refreshType];
    [[SqliteManager sharedInstance] queryMyVisitorsTableWithLastData:lastData length:lengthForEveryRequest complete:^(BOOL success, id obj) {
        
        [weakSelf.tableView loadFinish:refreshType];
        
        if (success) {
            
            NSArray *cacheList = obj;
            if (cacheList.count) {
                
                if (loadNew) {
                   weakSelf.dataArray = [cacheList mutableCopy];
                }else{
                    [weakSelf.dataArray addObjectsFromArray:cacheList];
                }
                
                
                if (cacheList.count < lengthForEveryRequest) {
                    //数据库无更多数据
                    _noMoreDataInDB = YES;
                }else{
                    //数据库还有更多
                    _noMoreDataInDB = NO;
                }
                
                //获取当前页
                _lastDataInDB        = cacheList.lastObject;
                _curVistorListReqPage  = _lastDataInDB.curReqPage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
                
                if (loadNew) {
                    [weakSelf requestGetMyVistorListLoadNew:YES];
                }
            }else{
                _noMoreDataInDB = YES;
                if (loadNew) {
                    [weakSelf requestGetMyVistorListLoadNew:YES];
                }
            }
        }else{
            _noMoreDataInDB = YES;
            if (loadNew) {
                [weakSelf requestGetMyVistorListLoadNew:YES];
            }
        }
        
    }];
    
    
}



#pragma mark - VistorCellDelegate
//加好友
- (void)onAddFriendInCell:(VistorCell *)cell{
    
    if (![[YHUserInfoManager sharedInstance] hasCompleteUserInfo])
    {
        
        [YHAlertView showWithTitle:@"请完善个人职业信息再添加好友" message:nil cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
//                MyDetailEditViewController *VC = [[MyDetailEditViewController alloc] init];
//                [self.navigationController pushViewController:VC animated:YES];
                
            }
            
        }];
        
//        [HHUtils showAlertWithTitle:@"请完善个人职业信息再添加好友" message:@"" okTitle:@"确定" cancelTitle:@"取消" dismiss:^(BOOL resultYes) {
//            
//            if (resultYes) {
//                MyDetailEditViewController *VC = [[MyDetailEditViewController alloc] init];
//                [self.navigationController pushViewController:VC animated:YES];
//            }
//        }];
        return;
    }

    __weak typeof(self)weakSelf = self;

    __block MBProgressHUD *hud = showHUDWithText(@"", [UIApplication sharedApplication].keyWindow.rootViewController.view);
    [[NetManager sharedInstance] postAddFriendwithFriendId:cell.userInfo.uid complete:^(BOOL success, id obj)
    {
        [hud hide:YES];
        if (success) {
            
            if (cell.indexPath.row < weakSelf.dataArray.count) {
               YHUserInfo *userInfo   = weakSelf.dataArray[cell.indexPath.row];
                userInfo.addFriStatus = AddFriendStatus_IAddOtherPerson;
            }
           
            cell.addFriendBtn.hidden  = YES;
            cell.imgvAddFriend.hidden = YES;
            
            
            NSString *userName = cell.userInfo.userName.length?cell.userInfo.userName:@"TA";
            NSString *tips = [NSString stringWithFormat:@"您已申请添加%@为好友",userName];
            postHUDTipsWithHideDelay(tips, self.view, 3);
             [weakSelf.tableView reloadData];
            
//            [[YHCacheManager shareInstance] cacheMyVisitorsList:weakSelf.dataArray];
           
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"申请加好友失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"申请加好友失败");
            }
         
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"VistorCell";
    VistorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        UINib *nib = [UINib nibWithNibName:@"VistorCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    if (indexPath.row < [_dataArray count]) {
        [cell setUserInfo:_dataArray[indexPath.row]];
         cell.delegate = self;
         cell.indexPath = indexPath;
    }
   

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.row < [_dataArray count]) {
        YHUserInfo *userInfo =  _dataArray[indexPath.row];
        CardDetailViewController *cardDetailVC = [[CardDetailViewController alloc]initWithUserInfo:userInfo];
        [self.navigationController pushViewController:cardDetailVC animated:YES];
    }

  
}

#pragma mark 数组时间排序(未实现)
- (void)sortDataArray
{
    [self.dataArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedAscending;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
- (void)requestGetMyVistorListLoadNew:(BOOL)loadNew{
    
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curVistorListReqPage = 1;
        refreshType = YHRefreshType_LoadNew;
        [self.tableView setNoMoreData:NO];
    }
    else{
        _curVistorListReqPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof(self)weakSelf = self;
    [self.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] getMyVistorsCount:lengthForEveryRequest currentPage:_curVistorListReqPage Complete:^(BOOL success, id obj)
    {
        [weakSelf.tableView loadFinish:refreshType];
        
        if (success)
        {
            
            NSArray *retArray = obj[@"visitors"];
            if (loadNew)
            {
        
                 weakSelf.dataArray = [NSMutableArray arrayWithArray:retArray];
                
//                [[YHCacheManager shareInstance]cacheMyVisitorsList:weakSelf.dataArray];
            }
            else
            {
                if (retArray.count) {
                     [weakSelf.dataArray addObjectsFromArray:retArray];
                }
               
            }
            
            
            if (retArray.count < lengthForEveryRequest)
            {
                
                if(loadNew)
                {
                    if(!retArray.count){
                        [weakSelf.tableView setNoData:YES withText:@"暂无访客"];
                    }
                    else{
                        [weakSelf.tableView setNoMoreData:YES];
                    }
                    
                }
                else
                {
                    
                   [weakSelf.tableView setNoMoreData:YES];
                   
                }
                
            }else{
                [weakSelf.tableView setEnableLoadMore:YES];
            }

            
            [self.tableView reloadData];
            
            [[SqliteManager sharedInstance] updateMyVisitorsList:retArray complete:^(BOOL success, id obj) {
                if (success) {
                    DDLog(@"更新我的访客DB成功,%@",obj);
                }else{
                    DDLog(@"更新我的访客DB失败,%@",obj);
                }
            }];
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取我的访客失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取我的访客失败");
            }
        }
    }];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestGetMyVistorListLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    
    if (_noMoreDataInDB) {
        [self requestGetMyVistorListLoadNew:NO];
    }else{
        [self _loadFromDBWithLastData:_lastDataInDB loadNew:NO];
    }
}

@end
