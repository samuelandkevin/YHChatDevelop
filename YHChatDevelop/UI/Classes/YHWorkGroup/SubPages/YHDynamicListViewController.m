//
//  YHDynamicListViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/8/12.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHDynamicListViewController.h"
#import "CellForWorkGroup.h"
#import "CellForWorkGroupRepost.h"
#import "YHWorkGroup.h"
#import "YHWorkGroupPhotoContainer.h"
#import "YHDynDetailVC.h"
#import "YHUserInfoManager.h"
#import "YHDynamicPublishOController.h"
#import "YHNavigationController.h"
#import "YHNetManager.h"
//#import "YHGlobalSearchController.h"
#import "YHDynamicForwardController.h"
#import "YHUserInfoManager.h"
#import "YHRefreshTableView.h"
#import "YHSharePresentView.h"
//#import "YHSocialShareManager.h"
#import "YHCacheManager.h"
//#import "YHTalentDetailController.h"
#import "CardDetailViewController.h"

#import "YHWGManager.h"
//#import "YHSearchDynamicViewController.h"
#import "ChooseMyFrisViewController.h"
#import "YHWebViewController.h"
#import "YHWGTouchModel.h"
#import "YHMyDynManager.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "SqliteManager+Dynamic.h"
//#import "YHGlobalSearchController.h"
#import "SDImageCache.h"
#import "YHWGLayout.h"
#import "YHChatDevelop-Swift.h"

@interface YHDynamicListViewController ()<UITableViewDelegate,UITableViewDataSource,CellForWorkGroupDelegate,YHRefreshTableViewDelegate,CellForWorkGroupRepostDelegate,
    CellForWorkGroupDelegate,UIViewControllerPreviewingDelegate,
UISearchBarDelegate>{
         int _currentRequestPage; //当前请求页面
        BOOL _noMoreDataInDB;     //数据库无更多数据
        YHWorkGroup *_lastDataInDB;//上一条在数据库的动态
}
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic)        NSIndexPath  *selIndexPath;
@property (nonatomic,strong) YHWGManager *wgManager;
@property (nonatomic,assign) NSInteger curPageIndex;
@property (nonatomic,strong) NSMutableDictionary *heightDict;
@end

@implementation YHDynamicListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:Event_RefreshDynPage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFont:) name:Event_SystemFontSize_Change object:nil];
    
}


#pragma mark - initUI
- (void)initUI{
    
    
    self.navigationController.navigationBar.translucent = NO;
    
    //searchBar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.layer.borderWidth = 1;
    searchBar.layer.borderColor = RGBCOLOR(240, 240, 240).CGColor;
    searchBar.barTintColor = RGBCOLOR(240, 240, 240);
    searchBar.tintColor = [UIColor blueColor];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar =searchBar;
    
    
    //tableView
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44-44) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kTbvBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView setEnableLoadNew:YES];
    [self.tableView setEnableLoadMore:YES];
    
    [self.tableView registerClass:[CellForWorkGroup class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
    [self.tableView registerClass:[CellForWorkGroupRepost class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
   
    self.view.backgroundColor = kTbvBGColor;
    
//    _fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(10, 50, 100, 30)];
//    [_fpsLabel sizeToFit];
//    [self.view addSubview:_fpsLabel];
  
}

#pragma mark - ZJScrollPageViewChildVcDelegate

- (void)zj_viewWillAppearForIndex:(NSInteger)index{
    DDLog(@"%ld ---将要出现",index);
    
    _curPageIndex = index;
    
    //1.检查待刷新的页面是否当前页
    for (NSNotification *aNotifi in [YHWGManager shareInstance].anotherPageNeedRefresh) {
        
        if (aNotifi){
            NSDictionary *dict = aNotifi.userInfo;
            if ([dict[@"subIndex"] intValue] == _curPageIndex && dict[@"subIndex"]) {
                [self refreshData:aNotifi];
                [[YHWGManager shareInstance].anotherPageNeedRefresh removeObject:aNotifi];
                break;
            }
            
        }
    }
    
    
    
    //2.加载数据
    if (!self.dataArray.count) {
        
        //先加载缓存数据
        self.wgManager = [YHWGManager shareInstance];
        

        //取出缓存方式一：DB
        [self _loadFromDBWithLastData:nil loadNew:YES];
        
        //取出缓存方式二：文件
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSArray *cacheList = [[YHCacheManager shareInstance] getCacheWorkGroupDynamiListWithDynamicType:index];
//            
//            if (cacheList.count) {
//                
//                weakSelf.dataArray = [cacheList mutableCopy];
//                [weakSelf.wgManager.workGroupDict setValue:cacheList forKey:[NSString stringWithFormat:@"dynList%ld",(long)index]];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.tableView reloadData];
//                });
//                
//                
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf requestDynamicListLoadNew:YES];
//            });
//            
//            
//        });
        
        
    }
   
}

#pragma mark - Lazy Load
- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableDictionary *)heightDict{
    if (!_heightDict) {
        _heightDict = [NSMutableDictionary new];
    }
    return _heightDict;
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //进入搜索
//    YHGlobalSearchController *vc = [[YHGlobalSearchController alloc] init];
//    YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:NULL];
    return NO;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < self.dataArray.count) {
        
        CGFloat height = 0.0;
        
       
        //原创cell
        Class currentClass  = [CellForWorkGroup class];
        YHWorkGroup *model  = self.dataArray[indexPath.row];
        
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

            height = [CellForWorkGroupRepost hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                CellForWorkGroupRepost *cell = (CellForWorkGroupRepost *)sourceCell;
                
                cell.model = model;
  
            }];

        }
        else{

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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.row < [self.dataArray count]) {
        YHWorkGroup *workGroup = self.dataArray[indexPath.row];
        
        [self.wgManager.selIndexPathDict setValue:indexPath forKey:[NSString stringWithFormat:@"dynList%ld",(long)index]];
        self.selIndexPath = indexPath;
        
        YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
        vc.refreshPage = RefreshPage_WorkGroup;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < [self.dataArray count]) {
        
        YHWorkGroup *model  = self.dataArray[indexPath.row];
        
        if (model.type == DynType_Forward) {
            //转发cell
            CellForWorkGroupRepost *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
            if (!cell) {
                cell = [[CellForWorkGroupRepost alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
            }
            cell.indexPath = indexPath;
            cell.model = model;
            cell.delegate = self;
            cell.touchModel = [YHWGTouchModel registerForPreviewInVC:self sourceView:cell model:model];
            return cell;
        }else{
             //原创cell
            CellForWorkGroup *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForWorkGroup class])];
            if (!cell) {
                cell = [[CellForWorkGroup alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
            }
            cell.indexPath = indexPath;
            cell.model = model;
            cell.delegate = self;
            cell.touchModel = [YHWGTouchModel registerForPreviewInVC:self sourceView:cell model:model];
            return cell;
        }
        
        
    }
    else
        return kErrorCell;
    
    
    
}


#pragma mark - CellForWorkGroupRepostDelegate

- (void)onAvatarInRepostCell:(CellForWorkGroupRepost *)cell{
    if (cell.model.userInfo.identity == Identity_BigName)
    {
        
//        YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//        vc.userInfo = cell.model.userInfo;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else
    {
        
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:cell.model.userInfo];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }

}

- (void)onTapRepostViewInCell:(CellForWorkGroupRepost *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        YHWorkGroup *workGroup = self.dataArray[cell.indexPath.row];
        YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup.forwardModel];
//        vc.refreshWorkGroupPage = YES;
        vc.refreshPage = RefreshPage_WorkGroup;
        [self.wgManager.selIndexPathDict setValue:cell.indexPath forKey:[NSString stringWithFormat:@"dynList%ld",(long)index]];
        self.selIndexPath = cell.indexPath;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onCommentInRepostCell:(CellForWorkGroupRepost *)cell{
    [self _commentWithCell:cell];
}

- (void)onLikeInRepostCell:(CellForWorkGroupRepost *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        YHWorkGroup *model = self.dataArray[cell.indexPath.row];
        
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
                    [cell.viewBottom.btnLike setTitleColor:kBlueColor forState:UIControlStateNormal];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                
                
                //刷新我的动态页
                if ([model.userInfo.uid isEqualToString: [YHUserInfoManager sharedInstance].userInfo.uid]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_MyDyn) userInfo:@{@"operation":@"loadNew"}];
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
    
    if (cell.indexPath.row < [self.dataArray count]){
        [self _shareWithCell:cell];
    }
}

- (void)onDeleteInRepostCell:(CellForWorkGroupRepost *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        
        [self _deleteDynAtIndexPath:cell.indexPath dynamicId:cell.model.dynamicId];
    }
    
}

- (void)onMoreInRespostCell:(CellForWorkGroupRepost *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        YHWorkGroup *model = self.dataArray[cell.indexPath.row];
        model.isOpening = !model.isOpening;
        [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onLinkInRepostCell:(CellForWorkGroupRepost *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - CellForWorkGroupDelegate

- (void)onAvatarInCell:(CellForWorkGroup *)cell{
    
    if (cell.model.userInfo.identity == Identity_BigName)
    {
        
//        YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//        vc.userInfo = cell.model.userInfo;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else
    {
        
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:cell.model.userInfo];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (void)onMoreInCell:(CellForWorkGroup *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        YHWorkGroup *model = self.dataArray[cell.indexPath.row];
        model.isOpening = !model.isOpening;
        [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onDeleteInCell:(CellForWorkGroup *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        [self _deleteDynAtIndexPath:cell.indexPath dynamicId:cell.model.dynamicId];
    }
    
}


- (void)onCommentInCell:(CellForWorkGroup *)cell{
    [self _commentWithCell:cell];
}

- (void)onLikeInCell:(CellForWorkGroup *)cell{
    
    if (cell.indexPath.row < [self.dataArray count]) {
        YHWorkGroup *model = self.dataArray[cell.indexPath.row];
        
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
                
                
                
                //刷新我的动态页
                if ([model.userInfo.uid isEqualToString: [YHUserInfoManager sharedInstance].userInfo.uid]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_MyDyn) userInfo:@{@"operation":@"loadNew"}];
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
    
    if (cell.indexPath.row < [self.dataArray count]){
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

#pragma mark - Private

- (void)_commentWithCell:(UITableViewCell *)cell{
    
    CellForWorkGroup  *cellOri    = nil;
    CellForWorkGroupRepost *cellRepost = nil;
    
    if ([cell isKindOfClass:[CellForWorkGroup class]]) {
        cellOri = (CellForWorkGroup *)cell;
        [self.tableView deselectRowAtIndexPath:cellOri.indexPath
                                      animated:YES];
        
        if (cellOri.indexPath.row < [self.dataArray count]) {
            YHWorkGroup *workGroup = self.dataArray[cellOri.indexPath.row];
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
//            vc.refreshWorkGroupPage = YES;
            vc.refreshPage = RefreshPage_WorkGroup;
            [self.wgManager.selIndexPathDict setValue:cellOri.indexPath forKey:[NSString stringWithFormat:@"dynList%ld",(long)index]];
            self.selIndexPath = cellOri.indexPath;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if ([cell isKindOfClass:[CellForWorkGroupRepost class]]) {
        cellRepost = (CellForWorkGroupRepost *)cell;
        [self.tableView deselectRowAtIndexPath:cellRepost.indexPath
                                      animated:YES];
        
        if (cellOri.indexPath.row < [self.dataArray count]) {
            YHWorkGroup *workGroup = self.dataArray[cellRepost.indexPath.row];
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
//            vc.refreshWorkGroupPage = YES;
            vc.refreshPage = RefreshPage_WorkGroup;
            [self.wgManager.selIndexPathDict setValue:cellOri.indexPath forKey:[NSString stringWithFormat:@"dynList%ld",(long)index]];
            self.selIndexPath = cellOri.indexPath;
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
    
    
    YHWorkGroup *model = [YHWorkGroup new];
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
                    vc.shareType = SHareType_Dyn;
                    vc.shareDynToPWFris = model;
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

- (void)_deleteDynAtIndexPath:(NSIndexPath *)indexPath dynamicId:(NSString *)dynamicId{
    
    __weak typeof(self)weakSelf = self;
    
    [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:dynamicId complete:^(BOOL success, id obj) {
                if (success)
                {
                    DDLog(@"delete row is %ld",(long)indexPath.row);
                    
                    YHWorkGroup *model = _dataArray[indexPath.row];
                    [_dataArray removeObjectAtIndex:indexPath.row];
                    
                    
                    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];//这方法可能会令cpu 99%.
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_MyDyn) userInfo:@{@"operation":@"loadNew"}];
                    
                    //删除缓存方式二：
                    //                   [[YHCacheManager shareInstance] cacheWorkGroupDynamicList:weakSelf.dataArray dynamicType:_curPageIndex];
                    
                    //删除缓存方式一：
                    [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:(int)_curPageIndex complete:^(BOOL success, id obj) {
                        if (success) {
                            DDLog(@"删除DB某一动态成功:%@",obj);
                        }else{
                            DDLog(@"删除DB某一动态失败:%@",obj);
                        }
                    }];
                    
                    
                    
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
//                    DDLog(@"delete row is %ld",(long)indexPath.row);
//                    
//                    YHWorkGroup *model = _dataArray[indexPath.row];
//                    [_dataArray removeObjectAtIndex:indexPath.row];
//                    
//                    
//                    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];//这方法可能会令cpu 99%.
//                    
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [weakSelf.tableView reloadData];
//                    });
//                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_MyDyn) userInfo:@{@"operation":@"loadNew"}];
//                    
//                   //删除缓存方式二：
////                   [[YHCacheManager shareInstance] cacheWorkGroupDynamicList:weakSelf.dataArray dynamicType:_curPageIndex];
//                    
//                    //删除缓存方式一：
//                    [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:(int)_curPageIndex complete:^(BOOL success, id obj) {
//                        if (success) {
//                            DDLog(@"删除DB某一动态成功:%@",obj);
//                        }else{
//                            DDLog(@"删除DB某一动态失败:%@",obj);
//                        }
//                    }];
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
    NSString *uid = [YHUserInfoManager sharedInstance].userInfo.uid;
    int dynTag    = (int)_curPageIndex;
    [[SqliteManager sharedInstance] queryDynTableWithTag:dynTag userID:uid lastDyn:lastData length:lengthForEveryRequest complete:^(BOOL success, id obj) {
        
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
                _currentRequestPage = _lastDataInDB.curReqPage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                
                });
                if (loadNew) {
                    [weakSelf requestDynamicListLoadNew:YES];
                }
                
            }else{
                _noMoreDataInDB = YES;
                
                if (loadNew) {
                    [weakSelf requestDynamicListLoadNew:YES];
                }
            }
        }else{
            _noMoreDataInDB = YES;
            if (loadNew) {
                [weakSelf requestDynamicListLoadNew:YES];
            }
        }
        
    }];


}


- (NSArray<YHWorkGroup *> *)_textLayoutWithModels:(NSArray<YHWorkGroup *>*)models{
    for (YHWorkGroup *model in models) {
        YHWGLayout *layout = [[YHWGLayout alloc] init];
        [layout layoutWithText:model.msgContent];
        model.layout = layout;
    }
    return models;
}

#pragma mark - 网络请求

//获取工作圈动态列表
- (void)requestDynamicListLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _currentRequestPage = 1;
        refreshType = YHRefreshType_LoadNew;
        [self.tableView setNoMoreData:NO];
    }
    else{
        _currentRequestPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof (self)weakSelf = self;
    
    [self.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] postWorkGroupDynamicsCount:lengthForEveryRequest currentPage:_currentRequestPage dynamicType:(int)_curPageIndex complete:^(BOOL success, id obj) {
        
        [weakSelf.tableView loadFinish:refreshType];
        if (success)
        {
            
            NSArray *retArray = obj;
            
            if (loadNew)
            {
                
                weakSelf.dataArray = [NSMutableArray arrayWithArray:retArray];
                
                //缓存方式二：
//                [[YHCacheManager shareInstance] cacheWorkGroupDynamicList:weakSelf.dataArray dynamicType:_curPageIndex];
                
            }
            else
            {
                if (retArray.count) {
                    [weakSelf.dataArray addObjectsFromArray:retArray];
                }
                
            }
            [weakSelf _textLayoutWithModels:weakSelf.dataArray];
           
            if (retArray.count < lengthForEveryRequest)
            {
                
                if(loadNew)
                {
                    if(!retArray.count){
                        DDLog(@"下拉刷新总数据条数为0");
                    }
                    else{
                        [weakSelf.tableView setNoMoreData:YES];
                    }
                    
                    
                }
                else
                {
                    
                    [weakSelf.tableView setNoMoreData:YES];
                    
                }
                
            }
            
            [weakSelf.tableView reloadData];
            
            
            //缓存方式一：
            NSString *uid = [YHUserInfoManager sharedInstance].userInfo.uid;
            [[SqliteManager sharedInstance] updateDynWithTag:(int)_curPageIndex userID:uid dynList:retArray complete:^(BOOL success, id obj) {
                if (success) {
                    DDLog(@"更新动态DB成功,%@",obj);
                }else{
                    DDLog(@"更新动态DB失败,%@",obj);
                }
            }];
        }
        else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取工作圈列表失败");
                
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取工作圈列表失败");
            }
            
            
        }
        
    }];
}


#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}


#pragma mark - NSNotification

- (void)refreshData:(NSNotification *)aNotification{
    
    
    RefreshPage page    = (RefreshPage)[aNotification.object intValue];
    
    if (page == RefreshPage_WorkGroup) {
        
        NSDictionary *dict  = aNotification.userInfo;
        
        if (self.curPageIndex == self.wgManager.currentPage)
        {
            
            if (dict) {
                
                NSString *operation = dict[@"operation"];
                if ([operation isEqualToString:@"delete"]){
                    
                    if (self.selIndexPath.row < self.dataArray.count && self.selIndexPath ) {
                        YHWorkGroup *model = self.dataArray[self.selIndexPath.row];
                        [self.dataArray removeObjectAtIndex:self.selIndexPath.row];
                        //删除缓存方式二:
//                        [[YHCacheManager shareInstance] cacheWorkGroupDynamicList:self.dataArray dynamicType:_curPageIndex];
                        
                        //删除缓存方式一:
                        [[SqliteManager sharedInstance] deleteOneDyn:model dynTag:(int)_curPageIndex complete:^(BOOL success, id obj) {
                            if (success) {
                                DDLog(@"删除DB某一动态成功:%@",obj);
                            }else{
                                DDLog(@"删除DB某一动态失败:%@",obj);
                            }
                        }];
                        [self.tableView reloadData];
                    }
                    
                }else if([operation isEqualToString:@"updateLocal"]){
                    
                    if(self.selIndexPath.row < self.dataArray.count && self.selIndexPath){
                        [self.tableView reloadRowsAtIndexPaths:@[self.selIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }else if ([operation isEqualToString:@"loadNew"]){
                    //从服务器重新加载
                    [self requestDynamicListLoadNew:YES];
                }
            }
            
        }else{
            
            //待刷新的页面是否已存在
            BOOL bFind = NO;
            for (NSNotification *notifi in [YHWGManager shareInstance].anotherPageNeedRefresh) {
                NSDictionary *adict = notifi.userInfo;
                int subIndex = [adict[@"subIndex"] intValue];
                if (subIndex == [dict[@"subIndex"] intValue]){
                    bFind = YES;
                    break;
                }
            }
            if (!bFind) {
                [[YHWGManager shareInstance].anotherPageNeedRefresh addObject:aNotification];
            }
            
           
        }

    }

}

- (void)updateFont:(NSNotification *)aNotifi{
    [self.tableView removeFromSuperview];
    [self initUI];
    [self.tableView reloadData];
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestDynamicListLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    if (_noMoreDataInDB) {
        [self requestDynamicListLoadNew:NO];
    }else{
        [self _loadFromDBWithLastData:_lastDataInDB loadNew:NO];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
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
