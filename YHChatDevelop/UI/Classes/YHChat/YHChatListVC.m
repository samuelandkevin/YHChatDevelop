//
//  YHChatListVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatListVC.h"
#import "YHRefreshTableView.h"
#import "YHChatDetailVC.h"
#import "NetManager+Chat.h"
#import "CellChatList.h"
#import "UIImage+Extension.h"
#import "TestData.h"
#import "UIBarButtonItem+Custom.h"
#import "YHUserInfoManager.h"
#import "YHLoginInputViewController.h"
#import "YHNavigationController.h"
#import "NetManager+Login.h"
#import "YHChatDevelop-Swift.h"
#import "YHUICommon.h"
#import "SqliteManager.h"
#import "SqliteManager+Chat.h"
#import "YHVisitorChatDetailVC.h"

@interface YHChatListVC ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) YHPopMenu *popView;
@property (nonatomic,assign) BOOL rBtnSelected;

@end

@implementation YHChatListVC

#pragma mark - Life

- (void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    _rBtnSelected = NO;
    [_popView hideWithAnimate:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_isVisitor) {
        [self requestChatList];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.translucent = NO;
    [self initUI];
    
    if (!_isVisitor) {
        WeakSelf
        //数据库查找聊天列表
        [[SqliteManager sharedInstance] queryChatListTableWithUserInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
            if (success) {
                DDLog(@"%@",obj);
                NSArray *retObj = obj;
                if (retObj.count) {
                    weakSelf.dataArray = obj;
                    [weakSelf.tableView reloadData];
                }
            }
        }];
    }
    
    [self requestChatList];
    
    
    
}

#pragma mark - Lazy Load

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

#pragma mark - init
- (void)initUI{
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH
                                                                          , SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.rowHeight  = 70;
    self.tableView.backgroundColor = RGBCOLOR(244, 244, 244);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CellChatList class] forCellReuseIdentifier:NSStringFromClass([CellChatList class])];
    [self.tableView setEnableLoadNew:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(onLeft)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRight)];
}

#pragma mark - Action
- (void)onLeft{

}

- (void)onRight{
    _rBtnSelected = !_rBtnSelected;
    if (_rBtnSelected) {
        [self _showPopMenu];
    }else{
        [self _hidePopMenuWithAnimation:YES];
    }
}

- (void)onLogout{
    
    [[NetManager sharedInstance] postLogoutComplete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"退出登录成功，%@",obj);
        }else{
            DDLog(@"退出登录失败，%@",obj);
        }
    }];
    [[YHUserInfoManager sharedInstance] logout];
    
    
    YHLoginInputViewController *vc = [[YHLoginInputViewController alloc] init];
    YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = nav;
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}

#pragma mark - Private Method
- (void)_showPopMenu{
    
    //设置弹出视图的坐标，宽高
    CGFloat itemH = 50;//每个item的高度
    CGFloat w = 150;
    CGFloat h = 2*itemH;
    CGFloat r = 5;
    CGFloat x = SCREEN_WIDTH - w - r;
    CGFloat y = 10;
    
    //设置参数属性,图标和文字。
    YHPopMenu *popView = [[YHPopMenu alloc] initWithFrame:CGRectMake(x, y, w, h)];
    popView.iconNameArray = @[@"popMenu_img_groupChat",@"img1"];
    popView.itemNameArray = @[@"发起聊天",@"退出登录"];
    popView.itemH     = itemH;
    popView.fontSize  = 16.0f;
    popView.fontColor = [UIColor whiteColor];
    popView.canTouchTabbar = NO;
    [popView show];
    WeakSelf
    [popView dismissWithHandler:^(BOOL isCanceled, NSInteger row) {
        if (row == 1){
            [weakSelf onLogout];
        }
        weakSelf.rBtnSelected = NO;
    }];
    _popView = popView;
}

- (void)_hidePopMenuWithAnimation:(BOOL)animate{
    [_popView hideWithAnimate:animate];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CellChatList *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatList class])];
    if (indexPath.row < self.dataArray.count) {
        cell.model    = self.dataArray[indexPath.row];
        cell.delegate = self;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isVisitor){
        YHVisitorChatDetailVC *vc = [[YHVisitorChatDetailVC alloc] init];
        vc.model = self.dataArray[indexPath.row];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        YHChatDetailVC *vc = [[YHChatDetailVC alloc] init];
        vc.model = self.dataArray[indexPath.row];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - @protocol SWTableViewCellDelegate

// click event on left utility button
- (void)swipeableTableViewCell:(CellChatList *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
}

// click event on right utility button
- (void)swipeableTableViewCell:(CellChatList *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    YHChatListModel *selectedModel = cell.model;
    NSUInteger row = [_dataArray indexOfObject:selectedModel];
    if (!index) {
        //置顶或取消置顶
        WeakSelf
        BOOL stick = !selectedModel.isStickTop;
        if (row < weakSelf.dataArray.count) {
    
            if (stick){
                //数据置顶
                [weakSelf.dataArray removeObjectAtIndex:row];
                [weakSelf.dataArray insertObject:selectedModel atIndex:0];
                //更新UI
                [cell updateStickStatus:stick];
                [cell setContentOffest:CGPointZero animated:NO];
                [weakSelf.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [weakSelf.tableView scrollToTopAnimated:YES];
            }else{
                
                //数据取消置顶
                NSUInteger toIndex = NSNotFound;
                for (int i=0;i<weakSelf.dataArray.count;i++) {
                    YHChatListModel *aModel = weakSelf.dataArray[i];
                    if(!aModel.isStickTop && ![aModel.chatId isEqualToString:selectedModel.chatId]){
                        toIndex = i;
                        break;
                    }
                }
                
                toIndex = toIndex-1 >0 ? toIndex-1: 0;
                if (toIndex < weakSelf.dataArray.count){
                    [weakSelf.dataArray exchangeObjectAtIndex:row withObjectAtIndex:toIndex];
                    //更新UI
                    [cell updateStickStatus:stick];
                    [cell setContentOffest:CGPointZero animated:NO];
                    [weakSelf.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toIndex inSection:0]];
                }
                
                
            }
            
        }

        [self requestMsgStickWithModel:selectedModel retryCount:3 complete:^(BOOL success, id obj) {
            if (success) {
                selectedModel.isStickTop = !selectedModel.isStickTop;
                
            }
        }];
    }else{
        //删除会话
        
        
        if (row < _dataArray.count) {
            
            WeakSelf
            YHChatListModel *model = _dataArray[row];
            [weakSelf.dataArray removeObjectAtIndex:row];
            [weakSelf.tableView deleteRow:row inSection:0 withRowAnimation:UITableViewRowAnimationLeft];
            [weakSelf requestDeleteChatSessionWithModel:model retryCount:3];
           
        }

    }
}

// utility button open/close event
- (void)swipeableTableViewCell:(CellChatList *)cell scrollingToState:(SWCellState)state{
    
}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(CellChatList *)cell{
    return YES;
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(CellChatList *)cell canSwipeToState:(SWCellState)state{
    return YES;
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestChatList];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{

}

#pragma mark - 网络请求
- (void)requestChatList{
    
    WeakSelf
    [(YHRefreshTableView *)self.tableView loadBegin:YHRefreshType_LoadNew];
    if (_isVisitor) {
        
        //模拟数据源
        self.dataArray = [NSMutableArray arrayWithArray:[TestData randomGenerateChatListModel:40]];
        if (self.dataArray.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [(YHRefreshTableView *)weakSelf.tableView loadFinish:YHRefreshType_LoadNew];
                [self.tableView reloadData];
            });
            
        }
        
    }else{
       
        [[NetManager sharedInstance] postFetchChatListWithTimestamp:nil type:QChatType_All complete:^(BOOL success, id obj) {
            [(YHRefreshTableView *)weakSelf.tableView loadFinish:YHRefreshType_LoadNew];
            if (success) {
                weakSelf.dataArray = obj;
                [weakSelf.tableView reloadData];
                
                //更新聊天列表数据库
                [[SqliteManager sharedInstance] updateChatListModelArr:obj uid:[YHUserInfoManager sharedInstance].userInfo.uid complete:^(BOOL success, id obj) {
                    if (success) {
                        DDLog(@"更新聊天列表数据库成功,%@",obj);
                    }else{
                        DDLog(@"更新聊天列表数据库失败,%@",obj);
                    }
                }];
                
            }else{
                if (isNSDictionaryClass(obj)) {
                    //服务器返回的错误描述
                    NSString *msg  = obj[kRetMsg];
                    postTips(msg, @"获取群聊列表失败");
                }else{
                    postTips(obj, @"获取群聊列表失败");
                }
              
            }
        }];
    }
    
}

//消息置顶/取消置顶
- (void)requestMsgStickWithModel:(YHChatListModel *)model retryCount:(int)retryCount complete:(NetManagerCallback)complete{
    WeakSelf
    __block int count = retryCount;
    [[NetManager sharedInstance] postMsgStick:!model.isStickTop msgID:model.chatId complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"%@成功",model.isStickTop?@"取消置顶":@"消息置顶");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(YES,model);
                }
            });
        }else{
            DDLog(@"消息置顶失败,%@",obj);
            count --;
            if (count>=0) {
                [weakSelf requestMsgStickWithModel:model retryCount:retryCount complete:complete];
            }
        }
    }];
}

//删除聊天会话
- (void)requestDeleteChatSessionWithModel:(YHChatListModel *)model retryCount:(int)retryCount{
    WeakSelf
    __block int count = retryCount;
    [[NetManager sharedInstance] postDeleteSessionWithID:model.chatId sessionUserID:model.sessionUserId complete:^(BOOL success, id obj) {
        if(success){
            
            [[SqliteManager sharedInstance] deleteOneChatListModel:model uid:[YHUserInfoManager sharedInstance].userInfo.uid complete:^(BOOL success, id obj) {
                DDLog(@"删除数据库会话%@,%@",success?@"成功":@"失败",obj);
            }];
            DDLog(@"删除会话成功,%@",obj);
        }else{
            DDLog(@"删除会话失败,%@",obj);
            count --;
            if (count>=0) {
                [weakSelf requestDeleteChatSessionWithModel:model retryCount:count];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
