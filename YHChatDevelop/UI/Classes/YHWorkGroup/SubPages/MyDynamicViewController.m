//
//  MyDynamicViewController.m
//  PikeWay
//
//  Created by kun on 16/5/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyDynamicViewController.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "CellForWorkGroup.h"
#import "CellForWorkGroupRepost.h"
#import "YHDynamicForwardController.h"
#import "YHNavigationController.h"
#import "HHUtils.h"
#import "YHRefreshTableView.h"
#import "YHSharePresentView.h"
//#import "YHSocialShareManager.h"
#import "YHDynDetailVC.h"
#import "YHUserInfoManager.h"
#import "YHMyDynManager.h"
#import "ChooseMyFrisViewController.h"
#import "YHWGTouchModel.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHSqliteManager.h"
//#import "YHGlobalSearchController.h"
#import "YHWebViewController.h"
#import "YHChatDevelop-Swift.h"

#define kSearchBarH 44
@interface MyDynamicViewController ()<UITableViewDelegate,UITableViewDataSource,CellForWorkGroupDelegate,CellForWorkGroupRepostDelegate,UISearchBarDelegate>{
    int _curDynListReqPage;
    NSString *_currentUserId;//用户Id
    BOOL _noMoreDataInDB;     //数据库无更多数据
    YHWorkGroup *_lastDataInDB;//上一条在数据库的动态
    BOOL _isSelfPage;
}

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) YHUserInfo *currentUserInfo;
@property (nonatomic,strong) NSMutableDictionary *heightDict;
@property (nonatomic,strong) NSMutableArray *friDynArray;
@end

@implementation MyDynamicViewController

- (instancetype)initWithUserInfo:(YHUserInfo *)userInfo{
    if (self = [super init]) {
        if (!userInfo) {
            postTips(@"用户信息为nil", @"");
            return  nil;
        }
        if (!userInfo.uid) {
            postTips(@"用户Id为nil", @"");
            return nil;
        }
        self.currentUserInfo = userInfo;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSelfPage = [_currentUserInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]? YES:NO;
    [self initUI];
    
    if (_isSelfPage){
       
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:Event_RefreshDynPage object:nil];
        
        //缓存方式二:
        //先加载本地缓存数据
//        NSArray *cacheList = [[YHCacheManager shareInstance] getCacheMyDynamiList];
//        
//        if (cacheList.count) {
//            [YHMyDynManager shareInstance].dataArray = [cacheList mutableCopy];
//            [self.tableView reloadData];
//        }
    
    }

    
    //缓存方式一:DB
    [self _loadFromDBWithLastData:nil loadNew:YES];
 
    

    
}

#pragma mark - Lazy Load
- (NSMutableDictionary *)heightDict{
    if (!_heightDict) {
        _heightDict = [NSMutableDictionary new];
    }
    return _heightDict;
}

- (NSMutableArray *)friDynArray{
    if (!_friDynArray) {
        _friDynArray = [NSMutableArray new];
    }
    return _friDynArray;
}

#pragma mark - initUI
- (void)initUI{
    
    if (_isSelfPage) {
          self.title = @"我的动态";
    }
    else
    {
          self.title = @"动态列表";
    }
  
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    
    //searchBar
    if(self.showSearchBar){
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchBarH)];
        searchBar.placeholder = @"搜索";
        searchBar.layer.borderWidth = 1;
        searchBar.layer.borderColor = RGBCOLOR(240, 240, 240).CGColor;
        searchBar.barTintColor = RGBCOLOR(240, 240, 240);
        searchBar.tintColor = [UIColor blueColor];
        searchBar.delegate = self;
        [self.view addSubview:searchBar];
        _searchBar =searchBar;
    }
    
    //tableView
//    if (self.showSearchBar) {
//        self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44) style:UITableViewStylePlain];
//    }else{
//        self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
//    }
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kTbvBGColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView setEnableLoadNew:YES];
    [self.tableView setEnableLoadMore:YES];
    
    [self.tableView registerClass:[CellForWorkGroup class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
    [self.tableView registerClass:[CellForWorkGroupRepost class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
    
}

#pragma mark - ZJScrollPageViewChildVcDelegate


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //进入搜索
//    YHGlobalSearchController *vc = [[YHGlobalSearchController alloc] init];
//    YHNavigationController *nav  = [[YHNavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:NULL];
    return NO;
}


#pragma mark - UITableViewDelegate
//头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0.1;
    }
    return 10;
}


//修改行高度的位置
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if ((indexPath.row < [YHMyDynManager shareInstance].dataArray.count && _isSelfPage )|| (indexPath.row < self.friDynArray.count && !_isSelfPage )) {
        
        CGFloat height;
        //原创cell
        Class currentClass  = [CellForWorkGroup class];
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[indexPath.row];
        }else{
            model = self.friDynArray[indexPath.row];
        }
        
        //取缓存高度
        NSDictionary *dict =  self.heightDict[model.dynamicId];
        if (dict) {
            if (model.isOpening) {
                height = [dict[@"open"] floatValue];
            }else{
                height = [dict[@"normal"] floatValue];
            }
            if (height) {
                return height;
            }
        }
        
        //转发cell
        if (model.type == DynType_Forward) {
            currentClass = [CellForWorkGroupRepost class];//第一版没有转发,因此这样稍该一下
            
            /*******使用HYBMasonryAutoCell*******/
            height = [CellForWorkGroupRepost hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                CellForWorkGroupRepost *cell = (CellForWorkGroupRepost *)sourceCell;
                
                cell.model = model;
                
            }];
        }
        else{
            /*******使用FDTemplateLayoutCell*******/

            /*******使用HYBMasonryAutoCell*******/
            height = [CellForWorkGroup hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                CellForWorkGroup *cell = (CellForWorkGroup *)sourceCell;
                
                cell.model = model;
                
            }];

            
        }
        
        //缓存高度
        if (model.dynamicId) {
            NSMutableDictionary *aDict = [NSMutableDictionary new];
            if (model.isOpening) {
                [aDict setObject:@(height) forKey:@"open"];
            }else{
                [aDict setObject:@(height) forKey:@"normal"];
            }
            [self.heightDict setObject:aDict forKey:model.dynamicId];
        }
        
        return height;

    }
    else{
        return 44.0f;
    }

    
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSelfPage) {
        return [[YHMyDynManager shareInstance].dataArray count];
    }else{
        return self.friDynArray.count;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || ( indexPath.row < self.friDynArray.count && !_isSelfPage)) {
        
        UITableViewCell *cell;
        //原创cell
        Class currentClass  = [CellForWorkGroup class];
        
        YHWorkGroup *model;
        if (_isSelfPage) {
           model = [YHMyDynManager shareInstance].dataArray[indexPath.row];
        }else{
            model = self.friDynArray[indexPath.row];
        }
        
        
        //转发cell
        if (model.type == DynType_Forward) {
            currentClass = [CellForWorkGroupRepost class];//第一版没有转发,因此这样稍该一下
        }
        cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(currentClass)];
        CellForWorkGroup  *cell1 = nil;//原创
        CellForWorkGroupRepost *cell2 = nil;//转发
        /*******原创Cell*******/
        if ([cell isMemberOfClass:[CellForWorkGroup class]]) {
            cell1 = (CellForWorkGroup *)cell;
            cell1.indexPath = indexPath;
            cell1.model = model;
            cell1.delegate = self;
            cell1.touchModel = [YHWGTouchModel registerForPreviewInVC:self sourceView:cell1 model:model];
            return cell1;
            
        }
        else{
            /*****转发cell******/
            cell2 = (CellForWorkGroupRepost *)cell;
            cell2.indexPath = indexPath;
            cell2.model = model;
            cell2.delegate = self;
            cell2.touchModel = [YHWGTouchModel registerForPreviewInVC:self sourceView:cell2 model:model];
            return cell2;
        }

        
    }
    else
        return kErrorCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ((indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || ( indexPath.row < self.friDynArray.count && !_isSelfPage)) {
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[indexPath.row];
        }else{
            model = self.friDynArray[indexPath.row];
        }
        
        YHDynDetailVC *vc = [[YHDynDetailVC alloc] initWithWorkGroup:model];
        if (_isSelfPage) {
            vc.refreshPage = RefreshPage_MyDyn;
            [YHMyDynManager shareInstance].selIndexPath = indexPath;
        }
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  获取动态列表
 */
- (void)requestGetMyDynamcisLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curDynListReqPage = 1;
        refreshType = YHRefreshType_LoadNew;
        [self.tableView setNoMoreData:NO];
    }
    else{
        _curDynListReqPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [self.tableView loadBegin:refreshType];
    
    if (_isSelfPage) {
        [[NetManager sharedInstance] getUserDynamicListWithUseId:_currentUserInfo.uid count:lengthForEveryRequest currentPage:_curDynListReqPage complete:^(BOOL success, id obj) {
            [weakSelf.tableView loadFinish:refreshType];
            [weakSelf handleCallBackIsOk:success obj:obj loadNew:loadNew];
           
        }];

    }
    else
    {
        [[NetManager sharedInstance] getFriDynmaicListWithfriId:_currentUserInfo.uid count:lengthForEveryRequest currentPage:_curDynListReqPage complete:^(BOOL success, id obj) {
            [weakSelf.tableView loadFinish:refreshType];
            [weakSelf handleCallBackIsOk:success obj:obj loadNew:loadNew];
        }];
    }
    
    
    
}

- (void)handleCallBackIsOk:(BOOL)success obj:(id)obj loadNew:(BOOL)loadNew {
    
    __weak typeof(self)weakSelf = self;
    if(success)
    {
        NSArray *retArray = obj[@"dynamics"];
        if (loadNew){
            
            if (_isSelfPage) {
                [YHMyDynManager shareInstance].dataArray =  [NSMutableArray arrayWithArray:retArray];
            }else{
                self.friDynArray = [NSMutableArray arrayWithArray:retArray];
            }
            
            
            [[SqliteManager sharedInstance] updateDynWithTag:-1 userID:_currentUserInfo.uid dynList:retArray complete:^(BOOL success, id obj) {
                if (success) {
                    DDLog(@"更新我的动态DB成功,%@",obj);
                }else{
                    DDLog(@"更新我的动态DB失败,%@",obj);
                }
            }];
            
            
        }else
        {
            if (retArray.count) {
                if (_isSelfPage) {
                    [[YHMyDynManager shareInstance].dataArray addObjectsFromArray:retArray];
                }else{
                    [self.friDynArray addObjectsFromArray:retArray];
                }
                
            }
            
        }
        
        if (retArray.count < lengthForEveryRequest)
        {
            
            if(loadNew)
            {
                if(!retArray.count){
                    [weakSelf.tableView setNoData:YES withText:@"暂无动态"];
                }
                
                [weakSelf.tableView setNoMoreData:YES];
                
                
            }
            else
            {
                
                [weakSelf.tableView setNoMoreData:YES];
                
            }
            
        }
        
        if (_isSelfPage) {
            [weakSelf _textLayoutWithModels:[YHMyDynManager shareInstance].dataArray];
        }else{
            [weakSelf _textLayoutWithModels:self.friDynArray];
        }
        
        
        [self.tableView reloadData];
        
    }
    else
    {
        if (isNSDictionaryClass(obj))
        {
            //服务器返回的错误描述
            NSString *msg  = obj[kRetMsg];
            
            postTips(msg, @"获取用户动态列表失败");
            
        }
        else
        {
            //AFN请求失败的错误描述
            postTips(obj, @"获取用户动态列表失败");
        }
        
    }
    
    
}



#pragma mark - CellForWorkGroupDelegate
- (void)onAvatarInCell:(CellForWorkGroup *)cell{

}

- (void)onMoreInCell:(CellForWorkGroup *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage) ) {
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[cell.indexPath.row];
        }else{
            model = self.friDynArray[cell.indexPath.row];
        }
        
        model.isOpening = !model.isOpening;
        [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onDeleteInCell:(CellForWorkGroup *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage))
    {
        [self _deleteDynAtIndexPath:cell.indexPath dynamicId:cell.model.dynamicId dynTag:cell.model.dynTag];
    }
    
}


- (void)onCommentInCell:(CellForWorkGroup *)cell{

    [self _commentWithCell:cell];
}


- (void)onLikeInCell:(CellForWorkGroup *)cell{
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage)) {
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[cell.indexPath.row];
        }else{
            model = self.friDynArray[cell.indexPath.row];
        }
        
        __weak typeof(self)weakSelf = self;
        BOOL isLike = !model.isLike;
        cell.viewBottom.btnLike.enabled = NO;
        [[NetManager sharedInstance] postLikeDynamic:model.dynamicId isLike:isLike complete:^(BOOL success, id obj) {
            cell.viewBottom.btnLike.enabled = YES;
            if (success)
            {
                
                //更新本地数据源
                model.isLike = isLike;
                if (isLike) {
                    model.likeCount += 1;
                    [cell showLikeAnimationWithLikeCount:model.likeCount complete:^(BOOL finished) {
                        if (finished) {
                            
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
                }else{
                    model.likeCount -= 1;
                    [cell.viewBottom.btnLike setTitleColor:RGBCOLOR(151, 161, 173) forState:UIControlStateNormal];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                
                if (_isSelfPage) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation":@"loadNew",@"subIndex":@(model.dynTag)}];
                }
               
            }
            else{
                
                if (isNSDictionaryClass(obj))
                {
                    //服务器返回的错误描述
                    NSString *msg  = obj[kRetMsg];
                    
                    postTips(msg, @"点赞失败");
                    
                    
                }
                else
                {
                    //AFN请求失败的错误描述
                    postTips(obj, @"点赞失败");
                }

            }
        }];
        
    }

}

- (void)onShareInCell:(CellForWorkGroup *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage)){
        [self _shareWithCell:cell];
    }

}

- (void)onLinkInCell:(CellForWorkGroup *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - CellForWorkGroupRepostDelegate

- (void)onMoreInRespostCell:(CellForWorkGroupRepost *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage)) {
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[cell.indexPath.row];
        }else{
            model = self.friDynArray[cell.indexPath.row];
        }
       
        model.isOpening = !model.isOpening;
        [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onTapRepostViewInCell:(CellForWorkGroupRepost *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage))
    {
        
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[cell.indexPath.row];
        }else{
            model = self.friDynArray[cell.indexPath.row];
        }
        
        YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:model.forwardModel];
        if (_isSelfPage) {
            vc.refreshPage = RefreshPage_MyDyn;
            [YHMyDynManager shareInstance].selIndexPath = cell.indexPath;
        }
        
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (void)onDeleteInRepostCell:(CellForWorkGroupRepost *)cell{
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage))
    {
        [self _deleteDynAtIndexPath:cell.indexPath dynamicId:cell.model.dynamicId dynTag:cell.model.dynTag];
    }
}

- (void)onCommentInRepostCell:(CellForWorkGroupRepost *)cell{
    [self _commentWithCell:cell];
}

- (void)onLikeInRepostCell:(CellForWorkGroup *)cell{
    
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage)) {
        YHWorkGroup *model;
        if (_isSelfPage) {
            model = [YHMyDynManager shareInstance].dataArray[cell.indexPath.row];
        }else{
            model = self.friDynArray[cell.indexPath.row];
        }
        
        __weak typeof(self)weakSelf = self;
        BOOL isLike = !model.isLike;
        cell.viewBottom.btnLike.enabled = NO;
        [[NetManager sharedInstance] postLikeDynamic:model.dynamicId isLike:isLike complete:^(BOOL success, id obj) {
            cell.viewBottom.btnLike.enabled = YES;
            if (success)
            {
                
                //更新本地数据源
                model.isLike = isLike;
                if (isLike) {
                    model.likeCount += 1;
                    [cell showLikeAnimationWithLikeCount:model.likeCount complete:^(BOOL finished) {
                        if (finished) {
                            
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
                }else{
                    model.likeCount -= 1;
                    [cell.viewBottom.btnLike setTitleColor:RGBCOLOR(151, 161, 173) forState:UIControlStateNormal];
                     [weakSelf.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
               
                if (_isSelfPage) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation":@"loadNew",@"subIndex":@(model.dynTag)}];
                }
                
            }
            else{
                if (isNSDictionaryClass(obj))
                {
                    //服务器返回的错误描述
                    NSString *msg  = obj[kRetMsg];
                    postTips(msg, @"点赞失败");
                    
                }
                else
                {
                    //AFN请求失败的错误描述
                    postTips(obj, @"点赞失败");
                }
                
            }
        }];
        
    }
    
}

- (void)onShareInRepostCell:(CellForWorkGroupRepost *)cell{
    if ((cell.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cell.indexPath.row < [self.friDynArray count] && !_isSelfPage)){
        [self _shareWithCell:cell];
    }
}

- (void)onAvatarInRepostCell:(CellForWorkGroupRepost *)cell{

}

- (void)onLinkInRepostCell:(CellForWorkGroupRepost *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Private

- (NSArray<YHWorkGroup *> *)_textLayoutWithModels:(NSArray<YHWorkGroup *>*)models{
    for (YHWorkGroup *model in models) {
        YHWGLayout *layout = [[YHWGLayout alloc] init];
        [layout layoutWithText:model.msgContent];
        model.layout = layout;
    }
    return models;
}

- (void)_deleteDynAtIndexPath:(NSIndexPath *)indexPath dynamicId:(NSString *)dynamicId dynTag:(int)dynTag{
    
     __weak typeof(self)weakSelf = self;
    [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:dynamicId complete:^(BOOL success, id obj) {
                if (success)
                {
                    YHWorkGroup *model;
                    if (_isSelfPage) {
                        model = [YHMyDynManager shareInstance].dataArray[indexPath.row];
                        [[YHMyDynManager shareInstance].dataArray removeObjectAtIndex:indexPath.row];
                    }else{
                        model = self.friDynArray[indexPath.row];
                        [self.friDynArray removeObjectAtIndex:indexPath.row];
                    }
                    
                    
                    
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [weakSelf.tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
                    
                    if (_isSelfPage){
                        
                        //删除缓存方式二：文件
                        //                        [[YHCacheManager shareInstance] cacheMyDynamciList:[YHMyDynManager shareInstance].dataArray];
                        
                        //删除缓存方式一：DB
                        [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:-1 complete:^(BOOL success, id obj) {
                            if (success) {
                                DDLog(@"删除DB某一动态成功:%@",obj);
                            }else{
                                DDLog(@"删除DB某一动态失败:%@",obj);
                            }
                        }];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew",@"subIndex":@(dynTag)}];
                        
                    }
                    
                    
                    
                    
                }
                else{
                    
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg  = obj[kRetMsg];
                        
                        postTips(msg, @"删除动态失败");
                        
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"删除动态失败");
                    }
                }
                
            }];
        }
    }];
//    [HHUtils showAlertWithTitle:@"删除动态" message:@"您确定要删除此动态?" okTitle:@"确定" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
//        
//        if (resultYes)
//        {
//            [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:dynamicId complete:^(BOOL success, id obj) {
//                if (success)
//                {
//                    YHWorkGroup *model;
//                    if (_isSelfPage) {
//                       model = [YHMyDynManager shareInstance].dataArray[indexPath.row];
//                        [[YHMyDynManager shareInstance].dataArray removeObjectAtIndex:indexPath.row];
//                    }else{
//                        model = self.friDynArray[indexPath.row];
//                        [self.friDynArray removeObjectAtIndex:indexPath.row];
//                    }
//                    
//                    
//                   
//                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//                    [weakSelf.tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
//                    
//                    if (_isSelfPage){
//                        
//                        //删除缓存方式二：文件
////                        [[YHCacheManager shareInstance] cacheMyDynamciList:[YHMyDynManager shareInstance].dataArray];
//                        
//                        //删除缓存方式一：DB
//                        [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:-1 complete:^(BOOL success, id obj) {
//                            if (success) {
//                                DDLog(@"删除DB某一动态成功:%@",obj);
//                            }else{
//                                DDLog(@"删除DB某一动态失败:%@",obj);
//                            }
//                        }];
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew",@"subIndex":@(dynTag)}];
//                        
//                    }
//                    
//                    
//
//                    
//                }
//                else{
//                    
//                    if (isNSDictionaryClass(obj))
//                    {
//                        //服务器返回的错误描述
//                        NSString *msg  = obj[kRetMsg];
//                        
//                        postTips(msg, @"删除动态失败");
//                        
//                    }
//                    else
//                    {
//                        //AFN请求失败的错误描述
//                        postTips(obj, @"删除动态失败");
//                    }
//                }
//                
//            }];
//            
//        }
//    }];
    
}



- (void)_commentWithCell:(UITableViewCell *)cell{
    
    CellForWorkGroup  *cellOri    = nil;
    CellForWorkGroupRepost *cellRepost = nil;
    
    if ([cell isKindOfClass:[CellForWorkGroup class]]) {
        cellOri = (CellForWorkGroup *)cell;
        [self.tableView deselectRowAtIndexPath:cellOri.indexPath
                                      animated:YES];
        
        if ((cellOri.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cellOri.indexPath.row < [self.friDynArray count] && !_isSelfPage)) {
            YHWorkGroup *model;
            if (_isSelfPage) {
                model = [YHMyDynManager shareInstance].dataArray[cellOri.indexPath.row];
            }else{
                model = self.friDynArray[cellOri.indexPath.row];
            }
        
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:model];
            if (_isSelfPage) {
                vc.refreshPage = RefreshPage_MyDyn;
                [YHMyDynManager shareInstance].selIndexPath = cellOri.indexPath;
            }
           
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if ([cell isKindOfClass:[CellForWorkGroupRepost class]]) {
        cellRepost = (CellForWorkGroupRepost *)cell;
        [self.tableView deselectRowAtIndexPath:cellRepost.indexPath
                                      animated:YES];
        
        if ((cellRepost.indexPath.row < [[YHMyDynManager shareInstance].dataArray count] && _isSelfPage) || (cellRepost.indexPath.row < [self.friDynArray count] && !_isSelfPage)) {
            YHWorkGroup *model;
            if (_isSelfPage) {
                model = [YHMyDynManager shareInstance].dataArray[cellRepost.indexPath.row];
            }else{
                model = self.friDynArray[cellRepost.indexPath.row];
            }
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:model];
            if (_isSelfPage) {
                vc.refreshPage = RefreshPage_MyDyn;
                [YHMyDynManager shareInstance].selIndexPath = cellOri.indexPath;
            }
            
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
        return;
    
}

- (void)_shareWithCell:(UITableViewCell *)cell{
    
    CellForWorkGroup *cellOri     = nil;
    CellForWorkGroupRepost *cellRepost = nil;
    BOOL isRepost = NO;
    if ([cell isKindOfClass:[CellForWorkGroup class]]) {
        cellOri = (CellForWorkGroup *)cell;
    }
    else if ([cell isKindOfClass:[CellForWorkGroupRepost class]]) {
        cellRepost = (CellForWorkGroupRepost *)cell;
        isRepost   = YES;
    }
    else
        return;
    
    
    YHWorkGroup *model = [[YHWorkGroup alloc] init];
    if (isRepost) {
        model = cellRepost.model.forwardModel;
    }
    else{
        model = cellOri.model;
    }
    
    YHSharePresentView *shareView = [[YHSharePresentView alloc] init];
    shareView.shareType = ShareType_WorkGroup;
    [shareView show];
    [shareView dismissHandler:^(BOOL isCanceled, NSInteger index) {
        if (!isCanceled) {
            switch (index)
            {
                case 2:
                {
                    YHDynamicForwardController *vc = [[YHDynamicForwardController alloc] initWithWorkGroup:model];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    ChooseMyFrisViewController *vc = [[ChooseMyFrisViewController alloc] init];
                    vc.shareDynToPWFris = model;
                    vc.shareType = SHareType_Dyn;
                    YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
                    
                    [self.navigationController presentViewController:nav animated:YES completion:NULL];
                }
                    break;
                    
                case 0:
                {
                    //朋友圈
                    DDLog(@"朋友圈");
                    
//                    [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeDynamic platform:YHSharePlatform_Weixin shareObj:model];
                }
                    break;
                case 1:
                {
                    //微信好友
                    DDLog(@"微信好友");
//                    [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeDynamic platform:YHSharePlatform_WeixinSession shareObj:model];
                }
                    break;
                default:
                    break;
            }
        }
    }];
    
    
}


//从数据库加载动态,loadNew:是否加载最新的数据
- (void)_loadFromDBWithLastData:(YHWorkGroup *)lastData loadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        refreshType = YHRefreshType_LoadNew;
        [self.tableView setNoMoreData:NO];
    }
    else{
        refreshType = YHRefreshType_LoadMore;
    }
    
    WeakSelf
    NSString *uid = _currentUserInfo.uid;
    [[SqliteManager sharedInstance] queryDynTableWithTag:-1 userID:uid lastDyn:lastData length:lengthForEveryRequest complete:^(BOOL success, id obj) {
        
        [weakSelf.tableView loadFinish:refreshType];
        
        if (success) {
        
            NSArray *cacheList = obj;
            if (cacheList.count) {
                
                if (loadNew) {
                    if (_isSelfPage) {
                        [YHMyDynManager shareInstance].dataArray = [cacheList mutableCopy];
                    }else{
                        self.friDynArray = [cacheList mutableCopy];
                    }
                    
                }else{
                    if (_isSelfPage) {
                        [[YHMyDynManager shareInstance].dataArray addObjectsFromArray:cacheList];
                    }else{
                        [self.friDynArray addObjectsFromArray:cacheList];
                    }
                    
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
                _curDynListReqPage  = _lastDataInDB.curReqPage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
                
                if (loadNew) {
                    [weakSelf requestGetMyDynamcisLoadNew:YES];
                }
            }else{
                _noMoreDataInDB = YES;
                if (loadNew) {
                    [weakSelf requestGetMyDynamcisLoadNew:YES];
                }
            }
        }else{
            _noMoreDataInDB = YES;
            if (loadNew) {
                [weakSelf requestGetMyDynamcisLoadNew:YES];
            }
        }
        
    }];
    
    
}


#pragma mark - Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestGetMyDynamcisLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    
    if (_noMoreDataInDB) {
        [self requestGetMyDynamcisLoadNew:NO];
    }else{
        [self _loadFromDBWithLastData:_lastDataInDB loadNew:NO];
    }
    
}


#pragma mark - NSNotification
- (void)refreshData:(NSNotification *)aNotification{
    
    if (!_isSelfPage)return;
    //接收 Event_WorkGroupDynamic_Refresh 通知
    NSDictionary *dict  = aNotification.userInfo;
    if (dict) {
        
        NSString *operation = dict[@"operation"];
        if ([operation isEqualToString:@"delete"])
        {
            
            if ([YHMyDynManager shareInstance].selIndexPath.row < [YHMyDynManager shareInstance].dataArray.count && [YHMyDynManager shareInstance].selIndexPath ) {
                
                YHWorkGroup *model = [YHMyDynManager shareInstance].dataArray[[YHMyDynManager shareInstance].selIndexPath.row];
                [[YHMyDynManager shareInstance].dataArray removeObjectAtIndex:[YHMyDynManager shareInstance].selIndexPath.row];
                //删除缓存方式二:文件
//                [[YHCacheManager shareInstance] cacheMyDynamciList:[YHMyDynManager shareInstance].dataArray];
                
                //删除缓存方式一:
                [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:-1 complete:^(BOOL success, id obj) {
                    if (success) {
                        DDLog(@"删除DB我的动态成功:%@",obj);
                    }else{
                        DDLog(@"删除DB我的动态失败:%@",obj);
                    }
                }];
                [self.tableView reloadData];
            }
            
        }
        else if([operation isEqualToString:@"updateLocal"])
        {
            
            if([YHMyDynManager shareInstance].selIndexPath.row < [YHMyDynManager shareInstance].dataArray.count && [YHMyDynManager shareInstance].selIndexPath){
                [self.tableView reloadRowsAtIndexPaths:@[[YHMyDynManager shareInstance].selIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else if ([operation isEqualToString:@"loadNew"])
        {
            //从服务器重新加载
            [self requestGetMyDynamcisLoadNew:YES];
        }
    }
    
}

#pragma mark - Life

- (void)viewDidLayoutSubviews{
   
    if (self.showSearchBar) {
        //44:动态标签栏高度
        self.tableView.frame = CGRectMake(0,kSearchBarH, SCREEN_WIDTH, SCREEN_HEIGHT-64-kSearchBarH-44);
    }else{
        self.tableView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

