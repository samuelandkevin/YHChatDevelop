//
//  YHDynDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/6.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHDynDetailVC.h"
#import "YHRefreshTableView.h"
#import "CellForComment.h"
#import "YHIndicatorButton.h"
#import "YHWorkGroupPhotoContainer.h"
#import "IQKeyboardManager.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "YHActionSheet.h"
#import "YHNetManager.h"
#import "YHSharePresentView.h"
#import "CardDetailViewController.h"
#import "CellForLikePeople.h"
//#import "YHSocialShareManager.h"
//#import "YHTalentDetailController.h"
#import "YHDynamicForwardController.h"
#import "YHWGManager.h"
#import "ChooseMyFrisViewController.h"
#import "YHNavigationController.h"
#import "CellForWGDetail.h"
#import "CellForWGRepostDetail.h"
#import "YHWGSegmentView.h"
#import "ZJScrollPageView.h"
#import "YHWorkGroupBottomView.h"
#import "YHChatDevelop-Swift.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "Masonry.h"
#import "YHCommentKeyboard.h"

//点击按钮所属类型
typedef NS_ENUM (NSUInteger, TabType)
{
    TabType_Comment,
    TabType_Like,
    TabType_Share
};

@interface YHDynDetailVC ()<UITableViewDelegate,UITableViewDataSource,CellForWGDetailDelegate,CellForWGRepostDetailDelegate,YHWGSegmentViewDelegate,CellForCommentDelegate,CellForLikePeopleDelegate,
YHWorkGroupBottomViewDelegate,YHCommentKeyboardDelegate>{
    NSUInteger _nCurrentPageTag; //当前页
    YHWorkGroup *_currentWorkGroup;
    int _curCommentListReqPage; //当前评论列表请求页码
    int _curLikeListReqPage;    //当前点赞列表请求页码
    int _curShareListReqPage;   //当前分享列表请求页码
    BOOL _noMoreData_CommentPage;
    BOOL _noMoreData_LikePage;
    BOOL _noMoreData_SharePage;
    
    CGFloat _childOffsetY;
    CGFloat _rowHeightInSection0;
    
    NSString *_dynamicId;//动态Id
    NSIndexPath *_indexPathReply;//回复indexPath
}

@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic, strong) YHWGSegmentView *viewSegment;

/*表情相关的*/
//@property (nonatomic, strong) ChatKeyBoardView *chatKeyBoardView;
@property (nonatomic, strong) YHWorkGroupBottomView *viewBottom;
@property (nonatomic, strong) YHCommentKeyboard *keyboard;


@property(strong, nonatomic)NSArray<NSString *> *titles;
@property (nonatomic, strong) NSMutableArray *maDetail;
@property (nonatomic, strong) NSMutableArray *maShare;
@property (nonatomic, strong) NSMutableArray *maLike;
@property (nonatomic, strong) NSMutableArray <YHCommentData *>*maComment;

@end

@implementation YHDynDetailVC


//初始化方式1
- (instancetype)initWithWorkGroup:(YHWorkGroup *)workGroup
{
    if (self = [super init])
    {
        _currentWorkGroup = workGroup;
        
        if (!_currentWorkGroup)
        {
            return nil;
        }
        
        _dynamicId = _currentWorkGroup.dynamicId;
        
        //请求网络
        [self requestCommentListLoadNew:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self requestCardDetail];
        });
    }
    return self;
}

//初始化方式2
- (instancetype)initWithDynamicId:(NSString *)dynamicId{
    if (self = [super init]) {
        if (!dynamicId) {
            postTips(@"动态Id不能为nil", @"");
            return nil;
        }
        
        _dynamicId = dynamicId;
        
        //网络请求
        [self requestDynamicDetail];
        
        [self requestCommentListLoadNew:YES];
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
    //2.表情键盘
    [self setUpKeyboard];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}


#pragma mark - initUI
- (void)initUI{
    
   
    
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kTbvBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView setEnableLoadNew:YES];
    [self.tableView setEnableLoadMore:YES];
    
    
    [self.tableView registerClass:[CellForWGDetail class] forCellReuseIdentifier:NSStringFromClass([CellForWGDetail class])];
    [self.tableView registerClass:[CellForWGRepostDetail class] forCellReuseIdentifier:NSStringFromClass([CellForWGRepostDetail class])];
    [self.tableView registerClass:[CellForComment class] forCellReuseIdentifier:NSStringFromClass([CellForComment class])];
    [self.tableView registerClass:[CellForLikePeople class] forCellReuseIdentifier:NSStringFromClass([CellForLikePeople class])];
    self.view.backgroundColor = kTbvBGColor;
    
    self.title = @"动态详情";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    //右barItem
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithImgName:@"workgroup_img_more.png" target:self selector:@selector(onMore:)];
    
    //设置BottomView
    _viewBottom = [[YHWorkGroupBottomView alloc] init];
    _viewBottom.backgroundColor = [UIColor whiteColor];
    [_viewBottom.btnComment setTitle:@"评论" forState:UIControlStateNormal];
    [_viewBottom.btnLike setTitle:@"赞" forState:UIControlStateNormal];
    _viewBottom.delegate = self;
    [self.view addSubview:_viewBottom];
    
    
    CGFloat botViewH = 44.0;
    WeakSelf
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.height.mas_equalTo(SCREEN_HEIGHT-botViewH-64);
    }];
    
    [_viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.view);
        make.height.mas_equalTo(botViewH);
    }];
}

#pragma mark - Lazy Load
- (NSMutableArray *)maDetail
{
    if (!_maDetail)
    {
        _maDetail = [NSMutableArray array];
    }
    return _maDetail;
}

- (NSMutableArray *)maLike
{
    if (!_maLike)
    {
        _maLike = [NSMutableArray array];
    }
    return _maLike;
}

- (NSMutableArray *)maShare
{
    if (!_maShare)
    {
        _maShare = [NSMutableArray array];
    }
    return _maShare;
}

- (NSMutableArray *)maComment
{
    if (!_maComment)
    {
        _maComment = [NSMutableArray array];
    }
    return _maComment;
}

-(YHWGSegmentView *)viewSegment{
    if (!_viewSegment) {
        _viewSegment = [YHWGSegmentView new];
        _viewSegment.delegate = self;
    }
    return _viewSegment;
}

- (void)setUpKeyboard
{
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //表情键盘
    YHCommentKeyboard *keyboard = [[YHCommentKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;
    
}

#pragma mark - Private

- (void)updateData
{
    int commentCount = _currentWorkGroup.commentCount ? _currentWorkGroup.commentCount : 0;
    
    self.viewSegment.lbComCount.text = [NSString stringWithFormat:@"%@", @(commentCount)];
    
    int likeCount = _currentWorkGroup.likeCount ? _currentWorkGroup.likeCount : 0;
    self.viewSegment.lbLikeCount.text = [NSString stringWithFormat:@"%@", @(likeCount)];
    
    
    UIColor *colLike = _currentWorkGroup.isLike? kBlueColor:RGBCOLOR(120, 120, 120);
    [_viewBottom.btnLike setTitleColor:colLike forState:UIControlStateNormal];
    
    UIImage *imageLike = _currentWorkGroup.isLike?[UIImage imageNamed:@"workgroup_img_like_sel"]:[UIImage imageNamed:@"workgroup_img_like"];
    [_viewBottom.btnLike setImage:imageLike forState:UIControlStateNormal];
    
    if (!_currentWorkGroup.layout) {
        YHWGLayout *layout = [[YHWGLayout alloc] init];
        [layout layoutWithText:_currentWorkGroup.msgContent];
        _currentWorkGroup.layout = layout;
    }
}


- (void)_showLikeAnimationWithLikeCount:(int)likeCount complete:(void(^)(BOOL finished))complete{
    
    CGRect rect = [self.viewBottom.btnLike convertRect:self.viewBottom.btnLike.frame toView:[[UIApplication sharedApplication].delegate window]];
    
    UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(rect.origin.x - rect.size.width-6, rect.origin.y, rect.size.width, rect.size.height)];
    [btnLike setImage:[UIImage imageNamed:@"workgroup_img_like_sel"] forState:UIControlStateNormal];
    [[[UIApplication sharedApplication].delegate window] addSubview:btnLike];
    
    NSTimeInterval duration = 0.8;
    btnLike.transform = CGAffineTransformIdentity;
    WeakSelf
    [UIView animateKeyframesWithDuration:duration delay:0 options:0 animations: ^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration / 2 animations: ^{
            
            btnLike.transform = CGAffineTransformMakeScale(2, 2);
            
            [weakSelf.viewBottom.btnLike setTitleColor:kBlueColor forState:UIControlStateNormal];
//            [weakSelf.viewBottom.btnLike setTitle:[NSString stringWithFormat:@"%d",likeCount] forState:UIControlStateNormal];
            
        }];
        
        [UIView addKeyframeWithRelativeStartTime:duration/2 relativeDuration:duration/2 animations: ^{
            
            btnLike.transform = CGAffineTransformMakeScale(1, 1);
        }];
        
    } completion:^(BOOL finished){
        if (finished) {
            [btnLike removeFromSuperview];
        }
        if (complete) {
            complete(finished);
        }
    }];
}

#pragma mark - Action

- (void)showShareView{
    YHSharePresentView *shareView = [[YHSharePresentView alloc] init];
    shareView.shareType = ShareType_WorkGroup;
    [shareView show];
    [shareView dismissHandler:^(BOOL isCanceled, NSInteger index) {
        if(!isCanceled){
            
            switch (index) {
                case 2:
                {
                    YHDynamicForwardController *vc = [[YHDynamicForwardController alloc] initWithWorkGroup:_currentWorkGroup];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                    break;
                case 3:
                {
                    ChooseMyFrisViewController *vc = [[ChooseMyFrisViewController alloc] init];
                    vc.shareType = SHareType_Dyn;
                    vc.shareDynToPWFris = _currentWorkGroup;
                    YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
                    
                    [self.navigationController presentViewController:nav animated:YES completion:NULL];
                }
                    break;
                    
                case 0:
                {
                    //朋友圈
                    
//                    [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeDynamic platform:YHSharePlatform_Weixin shareObj:_currentWorkGroup];
                }
                    break;
                case 1:
                {
                    //微信好友
                    
//                    [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeDynamic platform:YHSharePlatform_WeixinSession shareObj:_currentWorkGroup];
                }
                    break;
                default:
                    break;
            }

        }

    }];
 
}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//点击更多
- (void)onMore:(UIButton *)sender
{
    
//    [self.chatKeyBoardView tapAction];
    
    NSArray *otherTitles = [NSArray new];
    
    if ([_currentWorkGroup.userInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid])
    {
        otherTitles = @[@"删除动态", @"分享",@"投诉"];
        YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:otherTitles];
        [sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
            if (!isCancel)
            {
                if (clickedIndex == 0){
                    DDLog(@"点击删除动态");
                    [self requesetDeleteDynamic];
                }else if (clickedIndex == 1){
                    
                     [self showShareView];
                }else{
                   
//                    YHComplainVC *vc = [[YHComplainVC alloc] initWithTagretID:_currentWorkGroup.dynamicId complainType:ComplainType_Dyn];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
        [sheet show];
    }
    else
    {
        otherTitles = @[@"分享",@"投诉"];
        YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:otherTitles];
        [sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
            if (!isCancel)
            {
                if (clickedIndex == 0){
                    [self showShareView];
                }else if(clickedIndex == 1){
//                    YHComplainVC *vc = [[YHComplainVC alloc] initWithTagretID:_currentWorkGroup.dynamicId complainType:ComplainType_Dyn];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
        [sheet show];
    }
}

#pragma mark - @protocol UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_indexPathReply) {
//        [_keyboard setText:@""];
    }
    _indexPathReply = nil;
    [_keyboard endEditing];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - @protocol UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if(section == 1){
        switch (_nCurrentPageTag) {
            case TabType_Comment:
                return [self.maComment count];
                break;
            case TabType_Like:
                return [self.maLike count];
                break;
            case TabType_Share:
                return [self.maShare count];
                break;
            default:
                return 0;
                break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        UITableViewCell *cell;
        //原创cell
        Class currentClass  = [CellForWGDetail class];
        YHWorkGroup *model  = _currentWorkGroup;
        //转发cell
        if (model.type == DynType_Forward) {
            currentClass = [CellForWGRepostDetail class];//第一版没有转发,因此这样稍该一下
        }
        cell  = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(currentClass)];
        
        CellForWGDetail  *cell1 = nil;//原创
        CellForWGRepostDetail *cell2 = nil;//转发
        /*******原创Cell*******/
        if ([cell isMemberOfClass:[CellForWGDetail class]]) {
            cell1 = (CellForWGDetail *)cell;
            cell1.indexPath = indexPath;
            cell1.model     = model;
            cell1.delegate  = self;
            return cell1;
            
        }
        else{
            /*****转发cell******/
            cell2 = (CellForWGRepostDetail *)cell;
            cell2.indexPath = indexPath;
            cell2.model     = model;
            cell2.delegate  = self;
            return cell2;
        }
        
    }else if(indexPath.section == 1){
        switch (_nCurrentPageTag)
        {
            case TabType_Share:
            {
                CellForComment *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForComment class])];
                if (!cell) {
                    cell = [[CellForComment alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForComment class])];
                }
                cell.indexPath = indexPath;
                return cell;
            }
                break;
                
            case TabType_Like:
            {
                CellForLikePeople *cell =
                [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForLikePeople class])];
                if (!cell) {
                   cell = [[CellForLikePeople alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForLikePeople class])];
                }
                cell.delegate = self;
                if (indexPath.row < [_maLike count])
                {
                    YHUserInfo *userInfo = _maLike[indexPath.row];
                    [cell setUserInfo:userInfo];
                }
                
                return cell;
            }
                break;
                
            case TabType_Comment:
            {
                CellForComment *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForComment class])];
                if (!cell) {
                    cell = [[CellForComment alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForComment class])];
                }
                cell.indexPath = indexPath;
                cell.delegate  = self;
                if (indexPath.row < _maComment.count)
                {
                    [cell setModel:_maComment[indexPath.row]];
                }
                return cell;
            }
                break;
                
            default:
                return kErrorCell;
                
                break;
        }
    }
    return kErrorCell;
}

#pragma mark - @protocol UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _currentWorkGroup?2:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat height = 0.0;
        //原创cell

        YHWorkGroup *model  = _currentWorkGroup;;
        
        if (!_currentWorkGroup.layout) {
            YHWGLayout *layout = [[YHWGLayout alloc] init];
            [layout layoutWithText:_currentWorkGroup.msgContent];
            _currentWorkGroup.layout = layout;
        }
        
        //转发cell
        if (model.type == DynType_Forward) {
            
            height = [CellForWGRepostDetail hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
                CellForWGRepostDetail *cell = (CellForWGRepostDetail *)sourceCell;
                cell.model = model;
            } cache:^NSDictionary *{
                return @{
                         kHYBCacheUniqueKey:model.dynamicId,
                         kHYBCacheStateKey : @(model.isOpening),
                         kHYBRecalculateForStateKey:@(NO)
                         };// 标识不用重新更新
            }];

            return height;
        }
        else{
            
           height = [CellForWGDetail hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
                CellForWGDetail *cell = (CellForWGDetail *)sourceCell;
                cell.model = model;
            } cache:^NSDictionary *{
                return @{
                         kHYBCacheUniqueKey:model.dynamicId,
                         kHYBCacheStateKey : @(model.isOpening),
                         kHYBRecalculateForStateKey:@(NO)
                         };// 标识不用重新更新
            }];
            
            return height;
            
            
        }
    }
    else if(indexPath.section == 1){
        if (_nCurrentPageTag == TabType_Comment)
        {
            return [CellForComment hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
                CellForComment *cell = (CellForComment *)sourceCell;
                if (indexPath.row < _maComment.count) {
                    [cell setModel:_maComment[indexPath.row]];
                }
            }];
            
        }
        else if (_nCurrentPageTag == TabType_Like)
        {
            return 55.0;
        }
        else if (_nCurrentPageTag == TabType_Share)
        {
            
           return [CellForComment hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {

            }];

        }
        else
        {
            return 40.0f;
        }
    }
    return 44.0f;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 44.0f;
    }
    else
    {
        return 0.01f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return self.viewSegment;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self _replyCommentAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - @protocol CellForWGRepostDetailDelegate
- (void)onAvatarInWGRepostDetailCell:(CellForWGRepostDetail *)cell{
    
}

- (void)onTapRepostViewInWGRepostDetailCell:(CellForWGRepostDetail *)cell{
    
    YHWorkGroup *forwardWG = _currentWorkGroup.forwardModel;
    YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:forwardWG];
    vc.refreshPage = RefreshPage_WorkGroup;
//    vc.refreshWorkGroupPage = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)onDeleteInWGRepostDetailCell:(CellForWGRepostDetail *)cell{
    [self requesetDeleteDynamic];
}

- (void)onMoreInWGRepostDetailCell:(CellForWGRepostDetail *)cell{
    YHWorkGroup *model = _currentWorkGroup;
    model.isOpening = !model.isOpening;
    [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
}




#pragma mark - @protocol CellForLikePeopleDelegate
- (void)onAvatarInLikeCell:(CellForLikePeople *)cell{
    if (cell.userInfo.identity == Identity_BigName)
    {
//        YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//        vc.userInfo = cell.userInfo;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
    
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:cell.userInfo];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

#pragma mark - @protocol CellForWGDetailDelegate


- (void)onAvatarInWGDetailCell:(CellForWGDetail *)cell{
    
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

- (void)onMoreInWGDetailCell:(CellForWGDetail *)cell{
    
    YHWorkGroup *model = _currentWorkGroup;
    model.isOpening = !model.isOpening;
    [self.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)onDeleteInWGDetailCell:(CellForWGDetail *)cell{
    [self requesetDeleteDynamic];
    
}

- (void)onLinkInWGDetailCell:(CellForWGDetail *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol YHWGSegmentViewDelegate
- (void)onCommentInSegView{
    DDLog(@"comment");
}

- (void)onLikeInSegView{
    DDLog(@"like");
}

- (void)onShareInSegView{
    DDLog(@"share");
}

- (void)fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    _nCurrentPageTag = toIndex;
    [self.tableView reloadData];
    
    if (fromIndex == toIndex) return;
    
    switch (_nCurrentPageTag) {
        case TabType_Comment:
        {
            if (_noMoreData_CommentPage) {
                [(YHRefreshTableView *)self.tableView setNoMoreData:YES];
            }
            else{
                [(YHRefreshTableView *)self.tableView setNoMoreData:NO];
            }
            
            if (!self.maComment.count)
            {
                
                [self requestCommentListLoadNew:YES];
            }
        }
            break;
        case TabType_Like:
        {
            if (_noMoreData_LikePage) {
                [(YHRefreshTableView *)self.tableView setNoMoreData:YES];
            }
            else
            {
                [(YHRefreshTableView *)self.tableView setNoMoreData:NO];
            }
            
            if (!self.maLike.count)
            {
                [self requestLikeListLoadNew:YES];
            }
        }
            break;
        case TabType_Share:
            
            break;
        default:
            break;
    }

}

#pragma mark - @protocol YHWorkGroupBottomViewDelegate

//点击底部的评论
- (void)onComment
{
    _indexPathReply = nil;
    _keyboard.commentType = YHCommentType_Comment;
    _keyboard.placeholder = @"评论一下";
    [_keyboard becomeFirstResponder];
}

//点击底部的点赞
- (void)onLikeInView:(YHWorkGroupBottomView *)inView
{
    
    UIButton *sender = inView.btnLike;
    BOOL isLike = !_currentWorkGroup.isLike;
    
    sender.enabled = NO;
    
    __weak typeof(self) weakSelf = self;
    
    [[NetManager sharedInstance] postLikeDynamic:_currentWorkGroup.dynamicId isLike:isLike complete:^(BOOL success, id obj) {
        sender.enabled = YES;
        
        if (success)
        {
            _currentWorkGroup.isLike = isLike;
            
            if (isLike)
            {
                _currentWorkGroup.likeCount += 1;
                
                [weakSelf.maLike addObject:[YHUserInfoManager sharedInstance].userInfo];
                [weakSelf _showLikeAnimationWithLikeCount:_currentWorkGroup.likeCount complete:^(BOOL finished) {
                    
                }];
            }
            else
            {
                _currentWorkGroup.likeCount -= 1;
                
                for (YHUserInfo *userInfo in weakSelf.maLike)
                {
                    if ([userInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid])
                    {
                        [weakSelf.maLike removeObject:userInfo];
                        break;
                    }
                    
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(self.refreshPage) userInfo:@{@"operation" : @"updateLocal"}];
            
//            if (self.refreshSearchDynPage) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:Event_SearchDynamicPage_Refresh object:self userInfo:@{@"operation" : @"updateLocal"}];
//            }
//            else if(self.refreshWorkGroupPage)
//            {
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:Event_WorkGroupDynamic_Refresh object:self userInfo:@{@"operation" : @"updateLocal"}];
//            }
//            else if(self.refreshMyDynamicPage){
//                [[NSNotificationCenter defaultCenter] postNotificationName:Event_MyDynamicPage_Refresh object:self userInfo:@{@"operation" :@"updateLocal"}];
//            }
//            else if(self.refreshSynthesisPage){
//                [[NSNotificationCenter defaultCenter] postNotificationName:Event_SynthesisPage_Refresh object:self userInfo:@{@"operation" :@"updateLocal"}];
//            }
            
            [weakSelf updateData];
            [weakSelf.tableView reloadData];
        }
        else
        {
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

//点击底部的分享
- (void)onShare
{
    [self showShareView];
}

#pragma mark - @protocol YHCommentKeyboardDelegate
//发送消息
- (void)didTapSendBtn:(NSString *)text{
    
    if (_indexPathReply) {
        [self handleReplyCommentMessage:text];
    }else{
        [self handleCommentMessage:text];
    }
    
}

//评论
- (void)handleCommentMessage:(NSString *)message{
    if (!message || !message.length)
    {
        postHUDTips(@"评论内容不能为空", self.view);
        return;
    }

    //收起键盘
    [_keyboard endEditing];
    
    WeakSelf
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"发送评论中";
    [self.view addSubview:hud];
    [hud show:YES];
   
    [[NetManager sharedInstance] postCommentDynamic:_currentWorkGroup.dynamicId content:message complete:^(BOOL success, id obj) {
        [hud hide:YES];
        if (success){
            
            postHUDTips(@"评论发布成功", self.view);
            
            _currentWorkGroup.commentCount += 1;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(self.refreshPage) userInfo:@{@"operation" : @"updateLocal"}];
            
            [weakSelf updateData];
            
            [weakSelf requestCommentListLoadNew:YES];
            
            DDLog(@"评论成功：%@", obj);
        }
        else {

            if (isNSDictionaryClass(obj)){
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                postTips(msg, @"评论失败");
            }
            else{
                //AFN请求失败的错误描述
                postTips(obj, @"评论失败");
            }
            
        }
    }];
}

//回复评论
- (void)handleReplyCommentMessage:(NSString *)message{
    if (!message || !message.length)
    {
        postHUDTips(@"回复评论内容不能为空", self.view);
        return;
    }
    NSString *commentId = nil;
    NSString *replyUid  = nil;
    if (_indexPathReply.row < _maComment.count) {
        YHCommentData *model = _maComment[_indexPathReply.row];
        commentId = model.commentId;
        replyUid  = model.authorInfo.uid;
    }
    
    //收起键盘
    [_keyboard endEditing];
    
    WeakSelf
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"回复评论中";
    [self.view addSubview:hud];
    [hud show:YES];
    
    [[NetManager sharedInstance] postReplyCommentWithContent:message dynamicId:_currentWorkGroup.dynamicId commentId:commentId replyUid:replyUid complete:^(BOOL success, id obj) {
        [hud hide:YES];
        
        if (success){
            postHUDTips(@"回复成功", self.view);
            [weakSelf updateData];
            [weakSelf requestCommentListLoadNew:YES];
        }
        else{
            
            if (isNSDictionaryClass(obj)){
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                postTips(msg, @"回复评论失败");
                
            }
            else{
                //AFN请求失败的错误描述
                postTips(obj, @"回复评论失败");
            }
        }
    }];
}

#pragma mark - @protocol CellForCommentDelegate

- (void)onTapAvatar:(CellForComment *)cell
{
    
    if (cell.model.authorInfo.identity == Identity_BigName)
    {
//        YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//        vc.userInfo = cell.model.authorInfo;
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:cell.model.authorInfo];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    
}

- (void)longPressInCell:(CellForComment *)cell{
    NSArray *titles = @[@"复制",@"投诉",@"回复"];
    if([cell.model.authorInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]){
             titles = @[@"复制",@"投诉",@"回复",@"删除评论"];
    }
    
    YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:titles];
    [sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
        if (!isCancel){
            
            WeakSelf
            if (clickedIndex == 0) {
                [weakSelf _copyComment:cell];
            }else if (clickedIndex == 1){
                [weakSelf _complainComment:cell];
            }else if (clickedIndex == 2){
                [weakSelf _replyCommentAtIndexPath:cell.indexPath];
            }else if (clickedIndex == 3){
                [weakSelf _deleteComment:cell];
            }
        
        }
    }];
    [sheet show];

}

- (void)_copyComment:(CellForComment *)cell{
    YHCommentData *model = cell.model;
    NSString *comment = model.commentContent.string;
    if (comment) {
        [UIPasteboard generalPasteboard].string = comment;
    }
    
}

- (void)_complainComment:(CellForComment *)cell{
    YHCommentData *model = cell.model;
//    YHComplainVC *vc = [[YHComplainVC alloc] initWithTagretID:model.authorInfo.uid complainType:ComplainType_User];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_replyCommentAtIndexPath:(NSIndexPath *)indexPath{
    _indexPathReply = nil;
    if (indexPath.section == 1 && indexPath.row < [self.maComment count] && _nCurrentPageTag == TabType_Comment) {
        _indexPathReply = indexPath;
        YHCommentData *model = self.maComment[indexPath.row];
        
        NSString *userName = model.authorInfo.userName;
        if (!userName.length) {
            userName = @"";
        }
        NSString *placeholder = [NSString stringWithFormat:@"回复@%@:",userName];
        _keyboard.commentType = YHCommentType_Reply;
        _keyboard.placeholder = placeholder;
        [_keyboard becomeFirstResponder];
    }

}

- (void)_deleteComment:(CellForComment *)cell{

    __weak typeof (self)weakSelf = self;
    [[NetManager sharedInstance] postDeleteDynamicCommentWithId:cell.model.commentId dynamicId:_currentWorkGroup.dynamicId complete:^(BOOL success, id obj) {
        if (success) {
            
            [weakSelf.maComment enumerateObjectsUsingBlock:^(YHCommentData *model, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([model.commentId isEqualToString:cell.model.commentId]) {
                    [weakSelf.maComment removeObject:model];
                    
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    _currentWorkGroup.commentCount -= 1;
                    [weakSelf updateData];
                    [weakSelf.tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(self.refreshPage) userInfo:@{@"operation" : @"updateLocal"}];
                    
                    
                    *stop = YES;
                }
                
            }];
            
            
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"删除评论失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"删除评论失败");
            }
            
        }
    }];

}

- (void)onReplyUserInCell:(CellForComment *)cell{
    YHUserInfo *replyUserInfo = cell.model.toReplyCommentData.authorInfo;
    
    if (replyUserInfo.identity == Identity_BigName)
    {
        
//        YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//        vc.userInfo = replyUserInfo;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//        
    }
    else
    {
        
        CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:replyUserInfo];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (void)onLinkInCommentCell:(CellForComment *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText] loadCache:NO];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    switch (_nCurrentPageTag)
    {
        case TabType_Comment:
        {
            [self requestCommentListLoadNew:YES];
        }
            
            break;
            
        case TabType_Like:
        {
            [self requestLikeListLoadNew:YES];
        }
            break;
            
        case TabType_Share:
        {
            [self requestShareListLoadNew:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    switch (_nCurrentPageTag)
    {
        case TabType_Comment:
        {
            [self requestCommentListLoadNew:NO];
        }
            
            break;
            
        case TabType_Like:
        {
            [self requestLikeListLoadNew:NO];
        }
            break;
            
        case TabType_Share:
        {
            [self requestShareListLoadNew:NO];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 网络请求
//请求评论列表
- (void)requestCommentListLoadNew:(BOOL)loadNew
{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curCommentListReqPage = 1;
        refreshType = YHRefreshType_LoadNew;
    }
    else{
        _curCommentListReqPage ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof(self) weakSelf = self;
    [(YHRefreshTableView *)self.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] getDynamicCommentListWithId:_dynamicId count:lengthForEveryRequest currentPage:_curCommentListReqPage complete:^(BOOL success, id obj) {
        
        [(YHRefreshTableView *)weakSelf.tableView loadFinish:refreshType];
        
        if (success)
        {
            NSArray *retArray = obj;
            
            if (loadNew)
            {
                weakSelf.maComment = [NSMutableArray arrayWithArray:retArray];
            }
            else
            {
                if (weakSelf.maComment)
                {
                    [weakSelf.maComment addObjectsFromArray:retArray];
                }
            }
            
            if (retArray.count < lengthForEveryRequest)
            {
                
                
                if(loadNew)
                {
                    if(!retArray.count){
                        DDLog(@"下拉刷新总数据条数为0");
                        
                    }
                    [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                    _noMoreData_CommentPage = YES;
                }
                else
                {
                    
                    [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                    _noMoreData_CommentPage = YES;
                }
                
            }
            else
            {
                _noMoreData_CommentPage = NO;
            }
            
            [weakSelf updateData];
            [weakSelf.tableView reloadData];
        }
        else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取评论失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取评论失败");
            }
            
        }
    }];
}

//请求点赞列表
- (void)requestLikeListLoadNew:(BOOL)loadNew
{
    
    YHRefreshType refreshType;
    if (loadNew)
    {
        _curLikeListReqPage = 1;
        refreshType = YHRefreshType_LoadNew;
    }
    else
    {
        _curLikeListReqPage++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    
    __weak typeof(self) weakSelf = self;
    
    [(YHRefreshTableView *)weakSelf.tableView loadBegin:refreshType];
    [[NetManager sharedInstance] postDynamicLikeListWithId:_currentWorkGroup.dynamicId count:lengthForEveryRequest currentPage:_curLikeListReqPage complete:^(BOOL success, id obj)
     {
         
         [(YHRefreshTableView *)weakSelf.tableView loadFinish:refreshType];
         
         
         if (success)
         {
             NSArray *retArray = obj;
             
             if (loadNew)
             {
                 weakSelf.maLike = [NSMutableArray arrayWithArray:retArray];
             }
             else
             {
                 if (retArray.count)
                 {
                     [weakSelf.maLike addObjectsFromArray:retArray];
                 }
             }
             
             if (retArray.count < lengthForEveryRequest)
             {
                 
                 if(loadNew)
                 {
                     if(!retArray.count){
                         DDLog(@"下拉刷新总数据条数为0");
                         
                     }
                     [(YHRefreshTableView *)weakSelf.tableView setNoMoreData:YES];
                     _noMoreData_LikePage = YES;
                 }
                 else
                 {
                     [(YHRefreshTableView *)self.tableView setNoMoreData:YES];
                     _noMoreData_LikePage = YES;
                 }
                 
             }
             else{
                 _noMoreData_LikePage = NO;
             }
             
             
             [weakSelf.tableView reloadData];
         }
         else
         {
             
             if (isNSDictionaryClass(obj))
             {
                 //服务器返回的错误描述
                 NSString *msg  = obj[kRetMsg];
                 
                 postTips(msg, @"获取点赞用户列表失败");
                 
             }
             else
             {
                 //AFN请求失败的错误描述
                 postTips(obj, @"获取点赞用户列表失败");
             }
             
         }
     }];
}

//请求分享列表
- (void)requestShareListLoadNew:(BOOL)loadNew
{
    [(YHRefreshTableView *)self.tableView setNoMoreData:NO];
    
    if (loadNew)
    {
        _curShareListReqPage = 1;
    }
    else
    {
        _curShareListReqPage++;
    }
    
    __weak typeof(self) weakSelf = self;
    

}

//请求删除动态
- (void)requesetDeleteDynamic
{
    __weak typeof(self) weakSelf = self;
    
    [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.labelText = @"正在删除中";
            [self.view addSubview:hud];
            [hud show:YES];
            
            [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:_currentWorkGroup.dynamicId complete:^(BOOL success, id obj) {
                if (success)
                {
                    [hud hide:YES];
                    postHUDTips(@"删除成功", self.view);
                    
                    //我的动态页删除并刷新
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(self.refreshPage) userInfo:@{@"operation" : @"delete"}];
                    
                    //公共动态页只刷新
                    int dynTag = _currentWorkGroup.dynTag;
                    if (_currentWorkGroup.isRepost) {
                        dynTag = 0;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew"}];
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                    
                }
                else
                {
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
    
    
//    [HHUtils showAlertWithTitle:@"删除动态" message:@"您确定要删除此动态?" okTitle:@"确定" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes)
//     {
//         if (resultYes)
//         {
//             
//             MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//             hud.labelText = @"正在删除中";
//             [self.view addSubview:hud];
//             [hud show:YES];
//             
//             [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:_currentWorkGroup.dynamicId complete:^(BOOL success, id obj) {
//                 if (success)
//                 {
//                     [hud hide:YES];
//                     postHUDTips(@"删除成功", self.view);
//                     
//                     //我的动态页删除并刷新
//                     [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(self.refreshPage) userInfo:@{@"operation" : @"delete"}];
//
//                    //公共动态页只刷新
//                     int dynTag = _currentWorkGroup.dynTag;
//                     if (_currentWorkGroup.isRepost) {
//                         dynTag = 0;
//                     }
//                     
//                     [[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew"}];
//
//                     
//                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                         [weakSelf.navigationController popViewControllerAnimated:YES];
//                     });
//                     
//                 }
//                 else
//                 {
//                     if (isNSDictionaryClass(obj))
//                     {
//                         //服务器返回的错误描述
//                         NSString *msg  = obj[kRetMsg];
//                         
//                         postTips(msg, @"删除动态失败");
//                         
//                     }
//                     else
//                     {
//                         //AFN请求失败的错误描述
//                         postTips(obj, @"删除动态失败");
//                     }
//                     
//                 }
//             }];
//         }
//     }];
}

- (void)requestCardDetail{
    [[NetManager sharedInstance] getVisitCardDetailWithTargetUid:_currentWorkGroup.userInfo.uid complete:^(BOOL success, id obj) {
        if (success)
        {
            DDLog(@"获取名片详情成功:%@", obj);
            _currentWorkGroup.userInfo = obj;
            
        }
        else
        {
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取名片详情失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取名片详情失败");
            }
            
        }
    }];
    
}

//根据动态Id获取动态详情
- (void)requestDynamicDetail{
    
    __weak typeof(self)weakSelf = self;
    [[NetManager sharedInstance] postDynamicDetailWithId:_dynamicId complete:^(BOOL success, id obj) {
        if (success)
        {
            
            DDLog(@"获取动态详情页成功:%@",obj);
            _currentWorkGroup = obj;
            [weakSelf updateData];
            
            [self.tableView reloadData];
        }
        else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取动态详情页失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取动态详情页失败");
            }
            
        }
    }];
    
    
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
