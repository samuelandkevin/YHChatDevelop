//
//  YHSearchDynamicViewController.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHSearchDynamicViewController.h"
#import "CellForWorkGroup.h"
#import "CellForWorkGroupRepost.h"
#import "YHUserInfo.h"
#import "YHNetManager.h"
#import "YHDynDetailVC.h"
//#import "YHTalentDetailController.h"
#import "YHNetManager.h"
#import "CardDetailViewController.h"
#import "YHRefreshTableView.h"
#import "YHSharePresentView.h"
#import "YHDynamicForwardController.h"
//#import "YHSocialShareManager.h"
#import "YHSearchModel.h"
#import "ChooseMyFrisViewController.h"
#import "YHNavigationController.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

#define kSelBgColor    RGBCOLOR(130, 142, 152)
#define kSelTextColor [UIColor whiteColor]
#define kNorBgColor   [UIColor whiteColor]
#define kAnimateDuration 0.3
//点击按钮所属类型
typedef NS_ENUM (NSUInteger, TabType)
{
    TabType_Time = 101,
    TabType_Hot
};

@interface YHSearchDynamicViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,
CellForWorkGroupRepostDelegate,CellForWorkGroupDelegate>{
    NSUInteger _nCurrentPageTag; //当前页
    int       _curReqPageByTime; //按时间排序当前请求的页码
    int        _curReqPageByHot; //按热度排序当前请求的页码
    BOOL      _needRequestsearchByTime;
    BOOL      _needRequestsearchByHot;
    BOOL      _needReloadTbvTime;
    BOOL      _needReloadTbvHot;
}

@property (strong, nonatomic)  YHRefreshTableView *tbvTime;
@property (strong, nonatomic)  YHRefreshTableView *tbvHot;
@property (strong, nonatomic)  UIButton *btnTime;
@property (strong, nonatomic)  UIButton *btnHot;


@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *glass;

@property (nonatomic, strong) UIButton *btnSel;
@property (nonatomic, strong) YHSearchModel *searchModel;
@property (nonatomic, strong) NSString *searchText;

@property (nonatomic,strong) NSMutableDictionary *heightDictTime;
@property (nonatomic,strong) NSMutableDictionary *heightDictHot;
@end


@implementation YHSearchDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
    
    //notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:Event_RefreshDynPage object:nil];
    
    //initData
    self.searchModel = [YHSearchModel shareInstance];
    self.searchModel.dynByHotArray  = nil;
    self.searchModel.dynByTimeArray = nil;
    
    if (self.keyWord.length) {
        self.textField.text = self.keyWord;
        [self requestSearchLoadNew:YES];
    }
    
    
}

#pragma mark - Lazy Load

- (NSMutableDictionary *)heightDictTime{
    if (!_heightDictTime) {
        _heightDictTime = [NSMutableDictionary new];
    }
    return _heightDictTime;
}

- (NSMutableDictionary *)heightDictHot{
    if (!_heightDictHot) {
        _heightDictHot = [NSMutableDictionary new];
    }
    return _heightDictHot;
}

- (void)setBtnSel:(UIButton *)btnSel{
    _btnSel = btnSel;
    
    [UIView animateWithDuration:kAnimateDuration animations:^{
        [self _resetColor];
        [self _setSelBtn:btnSel];
    }];
    
    [self _changePageWithBtnSeleceted:btnSel];
}

#pragma mark - Guesture
- (void)_setUpGesture{
    
    UIPanGestureRecognizer *panGestureRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePage:)];
    [self.view addGestureRecognizer:panGestureRight];
    
    UIPanGestureRecognizer *panGestureLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePage:)];
    [self.view addGestureRecognizer:panGestureLeft];
    
    
}

- (void)changePage:(UIPanGestureRecognizer *)gesture{
    
    CGPoint contentOffest = [gesture translationInView:self.view];
    
    if (contentOffest.x > 50)
    {
        if (_nCurrentPageTag == TabType_Time) {
            return;
        }else{
            
            _nCurrentPageTag -= 1;
        }
        
        [self changeToPage:_nCurrentPageTag animated:YES];
    }
    else if(contentOffest.x < -50)
    {
        if (_nCurrentPageTag == TabType_Hot) {
            return;
        }else{
            _nCurrentPageTag += 1;
        }
        
        [self changeToPage:_nCurrentPageTag animated:YES];
    }
    
}

- (void)changeToPage:(NSInteger)toPage animated:(BOOL)animated{
    _nCurrentPageTag = toPage;
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            [self onTime:nil];
        }
            break;
        case TabType_Hot:
        {
            [self onHot:nil];
        }
            break;
        default:
            break;
    }
    
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
            [self.tbvTime reloadData];
            break;
        case TabType_Hot:
            [self.tbvHot reloadData];
            break;
        default:
            break;
    }
}


#pragma mark - Private
//重置标题颜色
- (void)_resetColor
{
    [_btnTime setTitleColor:kBlueColor forState:UIControlStateNormal];
    [_btnHot setTitleColor:kBlueColor forState:UIControlStateNormal];
    [_btnTime setBackgroundColor:kNorBgColor];
    [_btnHot setBackgroundColor:kNorBgColor];
}

//设置选中文本
- (void)_setSelBtn:(UIButton *)btnSelected
{
    _nCurrentPageTag = btnSelected.tag;
    
    switch (btnSelected.tag)
    {
        case TabType_Time:
        {
            [_btnTime setTitleColor:kSelTextColor forState:UIControlStateNormal];
            [_btnTime setBackgroundColor:kSelBgColor];
            
            _tbvTime.scrollsToTop = YES;
            _tbvHot.scrollsToTop  = NO;
        }
            break;
            
        case TabType_Hot:
        {
            [_btnHot setTitleColor:kSelTextColor forState:UIControlStateNormal];
            [_btnHot setBackgroundColor:kSelBgColor];
            
            _tbvTime.scrollsToTop = NO;
            _tbvHot.scrollsToTop  = YES;
        }
            break;
            
        default:
            break;
    }
}


- (void)_changePageWithBtnSeleceted:(UIButton *)btnSel{
    
    WeakSelf
    [self.tbvTime mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(-SCREEN_WIDTH * (btnSel.tag - 101));
    }];
    [UIView animateWithDuration:kAnimateDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)_deleteRowAtIndexPath:(NSIndexPath *)indexPath tableView:(YHRefreshTableView *)tableView dataArray:(NSMutableArray *)dataArray dynamicId:(NSString *)dynamicId{
    
    __weak typeof(self)weakSelf = self;
    
    [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:dynamicId complete:^(BOOL success, id obj) {
                if (success)
                {
                    [dataArray removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
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
    //                    [dataArray removeObjectAtIndex:indexPath.row];
    //                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    //                    [tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
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

- (void)_commentAtIndexPath:(NSIndexPath *)indexPath type:(DynType)type{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            [self _commentAtIndexPath:indexPath tableView:self.tbvTime dataArray:self.searchModel.dynByTimeArray type:type];
        }
            break;
        case TabType_Hot:
        {
            [self _commentAtIndexPath:indexPath tableView:self.tbvHot dataArray:self.searchModel.dynByHotArray type:type];
        }
            break;
        default:
            break;
    }
    
}

- (void)_commentAtIndexPath:(NSIndexPath *)indexPath tableView:(YHRefreshTableView *)tableView dataArray:(NSMutableArray *)dataArray  type:(DynType)type{
    
    
    if (type == DynType_Original)
    {
        
        if (indexPath.row < [dataArray count]) {
            YHWorkGroup *workGroup = dataArray[indexPath.row];
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (type == DynType_Forward)
    {
        
        if (indexPath.row < [dataArray count]) {
            YHWorkGroup *workGroup = dataArray[indexPath.row];
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
        return;
    
}

- (void)_likeWithOriCell:(CellForWorkGroup *)cell tableView:(UITableView *)tableView dataArray:(NSMutableArray *)dataArray{
    
    if (cell.indexPath.row < [dataArray count]) {
        
        YHWorkGroup *model = dataArray[cell.indexPath.row];
        
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
                }else{
                    model.likeCount -= 1;
                }
                
                [tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
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

- (void)_likeWithRepostCell:(CellForWorkGroupRepost *)cell tableView:(UITableView *)tableView dataArray:(NSMutableArray *)dataArray{
    
    if (cell.indexPath.row < [dataArray count]) {
        
        YHWorkGroup *model = dataArray[cell.indexPath.row];
        
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
                }else{
                    model.likeCount -= 1;
                }
                
                [tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
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
        if(!isCanceled){
            
            switch (index)
            {
                case 2:
                {
                    YHDynamicForwardController *vc = [[YHDynamicForwardController alloc] initWithWorkGroup:model];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    ChooseMyFrisViewController *vc = [[ChooseMyFrisViewController alloc] init];
                    vc.shareType = SHareType_Dyn;
                    vc.shareDynToPWFris = model;
                    YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
                    
                    [self presentViewController:nav animated:YES completion:NULL];
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

#pragma mark - initUI
- (void)initUI{
    self.view.backgroundColor = kTbvBGColor;
    self.navigationController.navigationBar.translucent = NO;
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    background.backgroundColor = [UIColor whiteColor];
    background.layer.cornerRadius = 5;
    self.glass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbtngray"]];
    self.glass.frame = CGRectMake(9, 9, 16, 16);
    
    self.textField = [[UITextField alloc] init];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.layer.cornerRadius = 5;
    self.textField.font = [UIFont systemFontOfSize:16];
    self.textField.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.placeholder = @"搜索动态";
    self.textField.tintColor  = [UIColor blueColor];
    
    [background addSubview:self.glass];
    [background addSubview:self.textField];
    WeakSelf
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.glass.mas_right).offset(9);
        make.right.equalTo(background);
        make.centerY.equalTo(background);
        make.height.equalTo(background);
    }];
    
    self.navigationItem.titleView = background;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(0, 0, 21, 21);
    [cancelBtn setImage:[UIImage imageNamed:@"leftarrow"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    
    self.btnTime = [UIButton new];
    [self.btnTime setTitle:@"时间排序" forState:UIControlStateNormal];
    self.btnTime.titleLabel.font = [UIFont systemFontOfSize:14.0F];
    self.btnTime.tag = TabType_Time;
    [self.btnTime addTarget:self action:@selector(onTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnTime];
    
    self.btnHot = [UIButton new];
    [self.btnHot setTitle:@"热度排序" forState:UIControlStateNormal];
    self.btnHot.titleLabel.font = [UIFont systemFontOfSize:14.0F];
    self.btnHot.tag = TabType_Hot;
    [self.btnHot addTarget:self action:@selector(onHot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnHot];
    
    self.tbvTime = [YHRefreshTableView new];
    self.tbvTime.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tbvTime.backgroundColor = kTbvBGColor;
    self.tbvTime.delegate = self;
    self.tbvTime.dataSource = self;
    [self.view addSubview:self.tbvTime];
    
    self.tbvHot = [YHRefreshTableView new];
    self.tbvHot.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tbvHot.backgroundColor = kTbvBGColor;
    self.tbvHot.delegate = self;
    self.tbvHot.dataSource = self;
    [self.view addSubview:self.tbvHot];
    
    [self.tbvTime registerClass:[CellForWorkGroup class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
    [self.tbvTime registerClass:[CellForWorkGroupRepost class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
    [self.tbvHot registerClass:[CellForWorkGroup class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
    [self.tbvHot registerClass:[CellForWorkGroupRepost class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
    
    //设置刷新控件
    [self.tbvTime setEnableLoadNew:YES];
    [self.tbvHot  setEnableLoadNew:YES];
    
    
    [self _setUpGesture];
    
    
    //默认选中
    [_btnTime setTitleColor:kSelTextColor forState:UIControlStateNormal];
    [_btnHot setTitleColor:kBlueColor forState:UIControlStateNormal];
    [_btnTime setBackgroundColor:kSelBgColor];
    [_btnHot setBackgroundColor:kNorBgColor];
    _nCurrentPageTag = TabType_Time;
    
    [self layoutUI];
    
    //    self.tbvTime.backgroundColor = [UIColor yellowColor];
    //    self.tbvHot.backgroundColor = [UIColor greenColor];
    
}

- (void)layoutUI{
    WeakSelf
    [self.btnTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(weakSelf.view);
        make.width.equalTo(weakSelf.view).dividedBy(2);
        make.height.mas_equalTo(44);
    }];
    
    [self.btnHot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnTime.mas_right);
        make.width.equalTo(weakSelf.view).dividedBy(2);
        make.top.equalTo(weakSelf.view);
        make.width.equalTo(weakSelf.btnTime);
        make.height.equalTo(weakSelf.btnTime);
    }];
    
    [self.tbvTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.equalTo(weakSelf.btnTime.mas_bottom);
        make.bottom.equalTo(weakSelf.view);
    }];
    
    [self.tbvHot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.tbvTime.mas_right);
        make.top.equalTo(weakSelf.tbvTime);
        make.bottom.equalTo(weakSelf.tbvTime);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        //搜索内容发送变化
        if (![self.searchText isEqualToString:self.textField.text]) {
            _needRequestsearchByTime = YES;
            _needRequestsearchByHot  = YES;
            self.searchText   = self.textField.text;
        }
        else{
            _needRequestsearchByTime = NO;
            _needRequestsearchByHot  = NO;
        }
        
        [self requestSearchLoadNew:YES];
        
        [self.textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tbvTime)
    {
        if (indexPath.row < self.searchModel.dynByTimeArray.count)
        {
            
            CGFloat height = 0.0;
            //原创cell
            Class currentClass  = [CellForWorkGroup class];
            YHWorkGroup *model  = self.searchModel.dynByTimeArray[indexPath.row];
            
            
            //取缓存高度
            NSDictionary *dict =  self.heightDictTime[model.dynamicId];
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
                [self.heightDictTime setObject:aDict forKey:model.dynamicId];
            }
            
            return height;
        }
        return 44.0f;
        
        
    }
    else if(tableView == self.tbvHot)
    {
        if (indexPath.row < self.searchModel.dynByHotArray.count) {
            
            CGFloat height = 0.0f;
            Class currentClass  = [CellForWorkGroup class];
            YHWorkGroup *model  = self.searchModel.dynByHotArray[indexPath.row];
            
            //转发cell
            
            //取缓存高度
            NSDictionary *dict =  self.heightDictHot[model.dynamicId];
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
                [self.heightDictHot setObject:aDict forKey:model.dynamicId];
            }
            
            return height;
        }
        return 44.0f;
        
    }
    else
        return 44.0f;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    if (tableView == self.tbvTime) {
        if (indexPath.row < [self.searchModel.dynByTimeArray count]) {
            
            self.searchModel.indexPathInTimePage = indexPath;
            YHWorkGroup *workGroup = self.searchModel.dynByTimeArray[indexPath.row];
            
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
            vc.refreshPage = RefreshPage_SearchDyn;
            //            vc.refreshSearchDynPage = YES;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(tableView == self.tbvHot){
        if (indexPath.row < [self.searchModel.dynByHotArray count]) {
            
            self.searchModel.indexPathInHotPage = indexPath;
            
            YHWorkGroup *workGroup = self.searchModel.dynByHotArray[indexPath.row];
            
            YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
            //            vc.refreshSearchDynPage = YES;
            vc.refreshPage = RefreshPage_SearchDyn;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tbvTime) {
        return [self.searchModel.dynByTimeArray count];
    }
    else if(tableView == self.tbvHot){
        return [self.searchModel.dynByHotArray count];
    }
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tbvTime)
    {
        if (indexPath.row < [self.searchModel.dynByTimeArray count]) {
            
            UITableViewCell *cell;
            //原创cell
            Class currentClass  = [CellForWorkGroup class];
            YHWorkGroup *model  = self.searchModel.dynByTimeArray[indexPath.row];
            
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
                return cell1;
                
            }
            else{
                /*****转发cell******/
                cell2 = (CellForWorkGroupRepost *)cell;
                cell2.indexPath = indexPath;
                cell2.model = model;
                cell2.delegate = self;
                return cell2;
            }
            
            
            
        }
        else
            return kErrorCell;
    }
    else if(tableView == self.tbvHot)
    {
        if (indexPath.row < [self.searchModel.dynByHotArray count]) {
            
            UITableViewCell *cell;
            //原创cell
            Class currentClass  = [CellForWorkGroup class];
            YHWorkGroup *model  = self.searchModel.dynByHotArray[indexPath.row];
            
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
                return cell1;
                
            }
            else{
                /*****转发cell******/
                cell2 = (CellForWorkGroupRepost *)cell;
                cell2.indexPath = indexPath;
                cell2.model = model;
                cell2.delegate = self;
                return cell2;
            }
            
            
        }
        else
            return kErrorCell;
        
    }
    else
        return kErrorCell;
    
    
}


#pragma mark - Action
- (void)cancel:(id)sender
{
    [self.textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    //    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onTime:(id)sender {
    self.btnSel = self.btnTime;
    if ((!self.searchModel.dynByTimeArray.count && self.textField.text.length) || _needRequestsearchByTime) {
        [self requestSearchDynamicByTimeLoadNew:YES];
    }
    if (_needReloadTbvTime) {
        [self.tbvTime reloadData];
        _needReloadTbvTime = NO;
    }
}

- (void)onHot:(id)sender {
    self.btnSel = self.btnHot;
    if ((!self.searchModel.dynByHotArray.count && self.textField.text.length)|| _needRequestsearchByHot) {
        [self requestSearchDynamicByHotLoadNew:YES];
    }
    if(_needReloadTbvHot){
        [self.tbvHot reloadData];
        _needReloadTbvHot = NO;
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


#pragma mark - Life
- (void)dealloc{
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

#pragma mark - 网络请求
//请求搜索动态
- (void)requestSearchLoadNew:(BOOL)loadNew{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            if (self.textField.text.length) {
                [self requestSearchDynamicByTimeLoadNew:loadNew];
            }
            else{
                postTips(@"请输入搜索内容",nil);
                if(loadNew){
                    [self.tbvTime setNoData:YES withText:@""];
                    [self.tbvTime loadFinish:YHRefreshType_LoadNew];
                }
                else{
                    [self.tbvTime loadFinish:YHRefreshType_LoadMore];
                }
            }
            
        }
            break;
        case TabType_Hot:{
            if (self.textField.text.length) {
                [self requestSearchDynamicByHotLoadNew:loadNew];
            }
            else{
                postTips(@"请输入搜索内容",nil);
                if (loadNew) {
                    [self.tbvHot setNoData:YES withText:@""];
                    [self.tbvHot loadFinish:YHRefreshType_LoadNew];
                }
                else{
                    [self.tbvHot loadFinish:YHRefreshType_LoadMore];
                }
            }
        }
            break;
        default:
            break;
    }
}


//请求搜索动态（按时间排序）
- (void)requestSearchDynamicByTimeLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curReqPageByTime = 1;
        refreshType = YHRefreshType_LoadNew;
        [self.tbvTime setNoMoreData:NO];
    }
    else{
        _curReqPageByTime ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof (self)weakSelf = self;
    
    [self.tbvTime loadBegin:refreshType];
    [[NetManager sharedInstance] getSearchDynamicWithKeyWord:self.textField.text sortType:SortType_Time count:lengthForEveryRequest currentPage:_curReqPageByTime complete:^(BOOL success, id obj) {
        
        [weakSelf.tbvTime loadFinish:refreshType];
        
        if (success)
        {
            DDLog(@"按时间排序搜索动态成功:%@",obj);
            
            NSArray *retArray = obj;
            _needRequestsearchByTime = NO;
            if (loadNew)
            {
                weakSelf.searchModel.dynByTimeArray = [retArray mutableCopy];
                
            }
            else
            {
                
                [weakSelf.searchModel.dynByTimeArray addObjectsFromArray:retArray];
            }
            
            [weakSelf _textLayoutWithModels:weakSelf.searchModel.dynByTimeArray];
            
            if (retArray.count < lengthForEveryRequest)
            {
                
                if(loadNew)
                {
                    if(!retArray.count){
                        [weakSelf.tbvTime setNoData:YES withText:@"没有符合条件的搜索结果"];
                        
                    }
                    else{
                        [weakSelf.tbvTime setNoMoreData:YES];
                        
                    }
                    
                }
                else
                {
                    
                    [weakSelf.tbvTime setNoMoreData:YES];
                    
                }
                
            }
            else{
                [weakSelf.tbvTime setEnableLoadMore:YES];
                
            }
            
            [weakSelf.tbvTime reloadData];
        }
        else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"按时间排序搜索动态失败");
                
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"按时间排序搜索动态失败");
            }
            
            
        }
        
    }];
}

//请求搜索动态（按热度排序）
- (void)requestSearchDynamicByHotLoadNew:(BOOL)loadNew{
    
    YHRefreshType refreshType;
    if (loadNew) {
        _curReqPageByHot = 1;
        refreshType = YHRefreshType_LoadNew;
    }
    else{
        _curReqPageByHot ++;
        refreshType = YHRefreshType_LoadMore;
    }
    
    __weak typeof (self)weakSelf = self;
    
    [self.tbvHot loadBegin:refreshType];
    [[NetManager sharedInstance] getSearchDynamicWithKeyWord:self.textField.text sortType:SortType_Hot count:lengthForEveryRequest currentPage:_curReqPageByHot complete:^(BOOL success, id obj) {
        
        [weakSelf.tbvHot loadFinish:refreshType];
        
        DDLog(@"按热度排序搜索动态成功:%@",obj);
        if (success)
        {
            
            NSArray *retArray = obj;
            _needRequestsearchByHot = NO;
            
            if (loadNew)
            {
                
                weakSelf.searchModel.dynByHotArray = [retArray mutableCopy];
            }
            else
            {
                [weakSelf.searchModel.dynByHotArray addObjectsFromArray:retArray];
            }
            
            [weakSelf _textLayoutWithModels:weakSelf.searchModel.dynByHotArray];
            
            //刷新控件
            if (retArray.count < lengthForEveryRequest)
            {
                
                if(loadNew)
                {
                    if(!retArray.count){
                        [weakSelf.tbvHot setNoData:YES withText:@"没有符合条件的搜索结果"];
                    }
                    else{
                        [weakSelf.tbvHot setNoMoreData:YES];
                        
                    }
                    
                }
                else
                {
                    
                    [weakSelf.tbvHot setNoMoreData:YES];
                    
                }
                
            }
            else{
                
                [weakSelf.tbvHot setEnableLoadMore:YES];
            }
            
            [weakSelf.tbvHot reloadData];
        }
        else
        {
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"按热度排序搜索动态失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"按热度排序搜索动态失败");
            }
            
            
        }
        
    }];
}


#pragma mark - CellForWorkGroupRepostDelegate

- (void)onMoreInRespostCell:(CellForWorkGroupRepost *)cell{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            if (cell.indexPath.row < [self.searchModel.dynByTimeArray count]) {
                YHWorkGroup *model = self.searchModel.dynByTimeArray[cell.indexPath.row];
                model.isOpening = !model.isOpening;
                [self.tbvTime reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
        case TabType_Hot:
        {
            if (cell.indexPath.row < [self.searchModel.dynByHotArray count]) {
                YHWorkGroup *model = self.searchModel.dynByHotArray[cell.indexPath.row];
                model.isOpening = !model.isOpening;
                [self.tbvHot reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
            
        default:
            break;
    }
    
}


- (void)onTapRepostViewInCell:(CellForWorkGroupRepost *)cell{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            if (cell.indexPath.row < [self.searchModel.dynByTimeArray count]) {
                YHWorkGroup *workGroup = self.searchModel.dynByTimeArray[cell.indexPath.row];
                YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup.forwardModel];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case TabType_Hot:
        {
            if (cell.indexPath.row < [self.searchModel.dynByHotArray count]) {
                YHWorkGroup *workGroup = self.searchModel.dynByHotArray[cell.indexPath.row];
                YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup.forwardModel];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
    
}

- (void)onCommentInRepostCell:(CellForWorkGroupRepost *)cell{
    [self _commentAtIndexPath:cell.indexPath type:cell.model.type];
}


- (void)onLikeInRepostCell:(CellForWorkGroupRepost *)cell{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            [self _likeWithRepostCell:cell tableView:self.tbvTime dataArray:self.searchModel.dynByTimeArray];
        }
            break;
        case TabType_Hot:{
            [self _likeWithRepostCell:cell tableView:self.tbvHot dataArray:self.searchModel.dynByHotArray];
        }
            break;
        default:
            break;
    }
    
    
    
}

- (void)onShareInRepostCell:(CellForWorkGroupRepost *)cell{
    
    [self _shareWithCell:cell];
    
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
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            if (cell.indexPath.row < [self.searchModel.dynByTimeArray count]) {
                YHWorkGroup *model = self.searchModel.dynByTimeArray[cell.indexPath.row];
                model.isOpening = !model.isOpening;
                [self.tbvTime reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
        case TabType_Hot:
        {
            if (cell.indexPath.row < [self.searchModel.dynByHotArray count]) {
                YHWorkGroup *model = self.searchModel.dynByHotArray[cell.indexPath.row];
                model.isOpening = !model.isOpening;
                [self.tbvHot reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
            
        default:
            break;
    }
    
    
}


- (void)onDeleteInCell:(CellForWorkGroup *)cell{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            if (cell.indexPath.row < [self.searchModel.dynByTimeArray count])
            {
                [self _deleteRowAtIndexPath:cell.indexPath tableView:self.tbvTime dataArray:self.searchModel.dynByTimeArray dynamicId:cell.model.dynamicId];
            }
        }
            break;
        case TabType_Hot:
        {
            if (cell.indexPath.row < [self.searchModel.dynByHotArray count])
            {
                [self _deleteRowAtIndexPath:cell.indexPath tableView:self.tbvHot dataArray:self.searchModel.dynByHotArray dynamicId:cell.model.dynamicId];
            }
        }
            break;
        default:
            break;
    }
    
    
    
    
}

- (void)onCommentInCell:(CellForWorkGroup *)cell{
    [self _commentAtIndexPath:cell.indexPath type:cell.model.type];
}

- (void)onLikeInCell:(CellForWorkGroup *)cell{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            [self _likeWithOriCell:cell tableView:self.tbvTime dataArray:self.searchModel.dynByTimeArray];
        }
            break;
        case TabType_Hot:{
            [self _likeWithOriCell:cell tableView:self.tbvHot dataArray:self.searchModel.dynByHotArray];
        }
            break;
        default:
            break;
    }
    
}

- (void)onShareInCell:(CellForWorkGroup *)cell{
    
    [self _shareWithCell:cell];
    
}


#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestSearchLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    [self requestSearchLoadNew:NO];
}

#pragma mark - NSNotification

- (void)textFiledEditChanged:(NSNotification *)aNotifi{
    if (!self.textField.text.length) {
        self.searchModel.dynByTimeArray = nil;
        self.searchModel.dynByHotArray  = nil;
        [self.tbvTime setNoData:YES withText:@""];
        [self.tbvHot  setNoData:YES withText:@""];
        [self.tbvTime reloadData];
        [self.tbvHot reloadData];
    }
}

- (void)refreshData:(NSNotification *)aNotifi{
    
    switch (_nCurrentPageTag) {
        case TabType_Time:
        {
            //刷新按时间排序页
            [self refreshDataAtIndexPath:self.searchModel.indexPathInTimePage dataArray:self.searchModel.dynByTimeArray aNotification:aNotifi tableView:self.tbvTime];
            
            //刷新按热度排序页
            YHWorkGroup *modelInTimePage = nil;
            if (self.searchModel.indexPathInTimePage.row < self.searchModel.dynByTimeArray.count) {
                modelInTimePage = self.searchModel.dynByTimeArray[self.searchModel.indexPathInTimePage.row];
            }
            
            for (int i=0; i< self.searchModel.dynByHotArray.count; i++)
            {
                YHWorkGroup *modelInHotPage = self.searchModel.dynByHotArray[i];
                if (modelInTimePage.dynamicId) {
                    if ([modelInHotPage.dynamicId isEqualToString:modelInTimePage.dynamicId])
                    {
                        
                        modelInHotPage.commentCount = modelInTimePage.commentCount;
                        modelInHotPage.isLike       = modelInTimePage.isLike;
                        break;
                    }
                }
                
            }
            _needReloadTbvHot = YES;
        }
            break;
        case TabType_Hot:
        {
            //刷新按热度排序页
            [self refreshDataAtIndexPath:self.searchModel.indexPathInHotPage dataArray:self.searchModel.dynByHotArray aNotification:aNotifi tableView:self.tbvHot];
            
            
            //刷新按时间排序页
            YHWorkGroup *modelInHotPage = nil;
            if (self.searchModel.indexPathInHotPage.row < self.searchModel.dynByHotArray.count) {
                modelInHotPage = self.searchModel.dynByHotArray[self.searchModel.indexPathInHotPage.row];
            }
            
            for (int i=0; i< self.searchModel.dynByTimeArray.count; i++)
            {
                YHWorkGroup *modelInTimePage = self.searchModel.dynByTimeArray[i];
                if (modelInHotPage.dynamicId) {
                    if ([modelInTimePage.dynamicId isEqualToString:modelInHotPage.dynamicId])
                    {
                        
                        modelInTimePage.commentCount = modelInHotPage.commentCount;
                        modelInTimePage.isLike       = modelInHotPage.isLike;
                        break;
                    }
                }
            }
            _needReloadTbvTime = YES;
            
        }
            break;
        default:
            break;
    }
    
    
}


- (void)refreshDataAtIndexPath:(NSIndexPath *)indexPath dataArray:(NSMutableArray *)dataArray aNotification:(NSNotification *)aNotification tableView:(UITableView *)tableView{
    
    NSDictionary *dict  = aNotification.userInfo;
    if (dict) {
        
        NSString *operation = dict[@"operation"];
        if ([operation isEqualToString:@"delete"])
        {
            
            if (indexPath.row < dataArray.count && indexPath ) {
                [dataArray removeObjectAtIndex:indexPath.row];
                
                [tableView reloadData];
            }
            
        }
        else if([operation isEqualToString:@"updateLocal"])
        {
            
            if(indexPath.row < dataArray.count && indexPath){
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        else if ([operation isEqualToString:@"loadNew"])
        {
            
            
        }
    }
    
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

