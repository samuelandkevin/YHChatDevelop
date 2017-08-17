//
//  YHGlobalSearchController.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHGlobalSearchController.h"
#import "YHSearchConnectionsController.h"
#import "YHSearchDynamicViewController.h"
#import "CellForWorkGroup.h"
#import "CellForWorkGroupRepost.h"
#import "YHSynthesisSearch.h"
#import "YHDynDetailVC.h"
#import "YHNetManager.h"
//#import "YHTalentDetailController.h"
#import "CardDetailViewController.h"
#import "YHNetManager.h"
#import "YHRefreshTableView.h"
#import "ConnectionSearchCell.h"
#import "YHSearchDynamicViewController.h"
#import "YHSharePresentView.h"
//#import "YHSocialShareManager.h"
#import "YHDynamicForwardController.h"
#import "YHNavigationController.h"
#import "ChooseMyFrisViewController.h"
#import "CellForWGDetail.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

typedef NS_ENUM(int,Section){
    Section_Dynamic = 0,   //动态
    Seciton_Fri,           //好友
};

//更多类型
typedef NS_ENUM(NSInteger,MoreType){
    MoreType_Dyn = 1001,//更多动态
    MoreType_Fri        //更多好友
};

#define kHeaderH 40
#define kFooterH 55
#define kAlpha   0.8
@interface YHGlobalSearchController ()<UITextFieldDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,
CellForWorkGroupDelegate,CellForWorkGroupRepostDelegate>{
    int _currentRequestPage;
}

@property(nonatomic,strong) UITextField * textField;
@property(nonatomic,strong) UIImageView * glass;
@property(nonatomic,strong) UIScrollView * scrollView;
@property(nonatomic,strong) YHRefreshTableView *tableView;
@property(nonatomic,strong) YHSynthesisSearch *manager;
@property(nonatomic,strong) UIView  *dynHeaderInSection;
@property(nonatomic,strong) UIView  *friHeaderInSection;
@property(nonatomic,strong) UIView  *dynFooterInSection;
@property(nonatomic,strong) UIView  *friFooterInSection;
@property(nonatomic,strong) UIView  *zeroHeightViewInSection;
@end

@implementation YHGlobalSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [YHSynthesisSearch shareInstance];

    [self setUpNavigationBar];
    [self setUpScrollView];
    [self setUpTableView];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:Event_RefreshDynPage object:nil];
}

- (void)setUpNavigationBar{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    UIView *background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    background.backgroundColor = [UIColor whiteColor];
    background.layer.cornerRadius = 5;
    self.glass = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchbtngray"]];
    self.glass.frame = CGRectMake(9, 9, 16, 16);

    self.textField = [[UITextField alloc]init];
    self.textField.backgroundColor    = [UIColor whiteColor];
    self.textField.layer.cornerRadius = 5;
    self.textField.font        = [UIFont systemFontOfSize:16];
    self.textField.textColor   = [UIColor colorWithWhite:0.188 alpha:1.000];
    self.textField.placeholder = @"请输入搜索内容";
    self.textField.delegate    = self;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.returnKeyType   = UIReturnKeySearch;
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
}

- (void)setUpScrollView{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    [self.view addSubview:self.scrollView];


    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH   , SCREEN_HEIGHT - 64+1);
    self.scrollView.delegate = self;

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 30)];
    UIView *lineLeft = [[UIView alloc]init];
    lineLeft.backgroundColor = [UIColor grayColor];
    UIView *lineRight = [[UIView alloc]init];
    lineRight.backgroundColor = [UIColor grayColor];

    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"在这里可以搜到";
    lab.font = [UIFont systemFontOfSize:12];

    lab.textColor = [UIColor colorWithRed:0.376 green:0.376 blue:0.380 alpha:1.000];
    [view addSubview:lineLeft];
    [view addSubview:lineRight];
    [view addSubview:lab];

    [lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.centerY.equalTo(view);
        make.height.mas_equalTo(0.5);

    }];

    [lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.right.equalTo(view);
        make.height.mas_equalTo(0.5);
        make.width.equalTo(lineLeft);
    }];

    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.left.equalTo(lineLeft.mas_right).offset(15);
        make.right.equalTo(lineRight.mas_left).offset(-15);
    }];

    [self.scrollView addSubview:view];

    UIView *dynamicView = [[UIView alloc] init];
    dynamicView.backgroundColor = [UIColor clearColor];

    UIView *connectionView = [[UIView alloc] init];
    connectionView.backgroundColor = [UIColor clearColor];

    UIImageView *dynamicImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_img_dynamic"]];
    dynamicImageView.frame = CGRectMake(0, 0, 66, 66);
    [dynamicView addSubview:dynamicImageView];

    UILabel *dynamicLab = [[UILabel alloc]init];
    dynamicLab.textAlignment = NSTextAlignmentCenter;
    dynamicLab.font = [UIFont systemFontOfSize:12];
    dynamicLab.text = @"动态";
    dynamicLab.textColor = [UIColor colorWithRed:0.376 green:0.376 blue:0.380 alpha:1.000];
    [dynamicView addSubview:dynamicLab];
    [dynamicLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(dynamicView);
        make.centerX.equalTo(dynamicView);
    }];


    UIImageView *connectionImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_img_connections"]];
    connectionImageView.frame = CGRectMake(0, 0, 66, 66);
    [connectionView addSubview:connectionImageView];

    UILabel *connectionLab = [[UILabel alloc]init];
    connectionLab.textAlignment = NSTextAlignmentCenter;
    connectionLab.font = [UIFont systemFontOfSize:12];
    connectionLab.text = @"人脉";
    connectionLab.textColor = [UIColor colorWithRed:0.376 green:0.376 blue:0.380 alpha:1.000];
    [connectionView addSubview:connectionLab];
    [connectionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(connectionView);
        make.centerX.equalTo(connectionView);
    }];

    [self.scrollView addSubview:dynamicView];
    [self.scrollView addSubview:connectionView];

    CGFloat margin = (SCREEN_WIDTH - (66*3))/4;

    WeakSelf
    [dynamicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.scrollView);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(99);
        make.top.equalTo(view.mas_bottom).offset(margin);
    }];

    [connectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dynamicView);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(99);
        make.right.equalTo(dynamicView.mas_left).offset(-margin);
    }];


    UIButton *dynamicBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    dynamicBtn.backgroundColor = [UIColor clearColor];
    [dynamicView addSubview:dynamicBtn];
    [dynamicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [dynamicBtn addTarget:self action:@selector(searchDynamic:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *connectionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    connectionBtn.backgroundColor = [UIColor clearColor];
    [connectionView addSubview:connectionBtn];
    [connectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [connectionBtn addTarget:self action:@selector(searchConnection:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setUpTableView{
    YHRefreshTableView *tbv = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    tbv.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    tbv.delegate   = self;
    tbv.dataSource = self;
    tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:tbv belowSubview:self.scrollView];
    self.tableView = tbv;
    self.tableView.hidden = YES;
    [self.tableView registerClass:[ConnectionSearchCell class] forCellReuseIdentifier:@"ConnectionSearchCell"];

    [self.tableView registerClass:[CellForWorkGroup class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroup class])];
    [self.tableView registerClass:[CellForWorkGroupRepost class] forCellReuseIdentifier:NSStringFromClass([CellForWorkGroupRepost class])];
}

#pragma mark button method
-(void)searchDynamic:(id)sender
{
    YHSearchDynamicViewController *vc = [[YHSearchDynamicViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Lazy Load
- (UIView *)dynHeaderInSection{
    if (!_dynHeaderInSection) {

       _dynHeaderInSection = [UIView new];
      [self setUpheaderViewInSection:_dynHeaderInSection title:@"动态"];

    }
    return _dynHeaderInSection;
}

- (UIView *)dynFooterInSection{
    if (!_dynFooterInSection) {
        _dynFooterInSection = [UIView new];
        [self setUpfooterViewInSection:_dynFooterInSection title:@"查看更多动态" moreBtnTag:MoreType_Dyn];
    }
    return _dynFooterInSection;
}

- (UIView *)friHeaderInSection{
    if (!_friHeaderInSection) {
        _friHeaderInSection = [UIView new];
        [self setUpheaderViewInSection:_friHeaderInSection title:@"人脉"];

    }
    return _friHeaderInSection;
}

-  (UIView *)friFooterInSection{
    if (!_friFooterInSection) {
        _friFooterInSection = [UIView new];
        [self setUpfooterViewInSection:_friFooterInSection title:@"查看更多人脉" moreBtnTag:MoreType_Fri];
    }
    return _friFooterInSection;

}

- (UIView *)zeroHeightViewInSection{
    if (!_zeroHeightViewInSection) {
        _zeroHeightViewInSection = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _zeroHeightViewInSection;
}

- (void)setUpheaderViewInSection:(UIView *)headerView title:(NSString *)title{
    CGFloat contentH = 40.0f;
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:kAlpha];

    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, contentH)];
    titleL.font = [UIFont systemFontOfSize:14.0f];
    titleL.text = title;
    [headerView addSubview:titleL];

    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderH-0.5, SCREEN_WIDTH, 0.5)];
    botLine.backgroundColor = kSeparatorLineColor;
    [headerView addSubview:botLine];

}

- (void)setUpfooterViewInSection:(UIView *)footerView title:(NSString *)title moreBtnTag:(NSInteger)moreBtnTag{

    CGFloat contentH = 40.0f;
    footerView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:kAlpha];

    UIImageView *icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"searchbtngray"]];
    icon.frame =CGRectMake(10, (contentH-16)/2.0, 16, 16);
    [footerView addSubview:icon];

    UILabel *moreTips = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame)+2, 0, 100, contentH)];
    moreTips.font = [UIFont systemFontOfSize:14.0f];
    moreTips.textColor = RGBCOLOR(63, 96, 155);
    moreTips.text = title;
    [footerView addSubview:moreTips];


    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 25, (contentH-14)/2, 14, 14)];
    rightArrow.image = [UIImage imageNamed:@"common_img_smallRightArrow"];
    [footerView addSubview:rightArrow];

    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(0, kFooterH-0.5, SCREEN_WIDTH, 0.5)];
    botLine.backgroundColor = kSeparatorLineColor;
    [footerView addSubview:botLine];

    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, contentH, SCREEN_WIDTH, 15)];
    sepView.backgroundColor = [kTbvBGColor colorWithAlphaComponent:kAlpha];
    [footerView addSubview:sepView];

    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kFooterH)];
    moreBtn.tag = moreBtnTag;
    [moreBtn addTarget:self action:@selector(onMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:moreBtn];

}



-(void)searchConnection:(id)sender
{
    YHSearchConnectionsController *vc = [[YHSearchConnectionsController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [self.textField resignFirstResponder];
        [self requestSynthesisSearchLoadNew:YES];
    }
    return YES;
}

- (void)textFiledEditChanged:(NSNotification *)aNotifi{
    if (!self.textField.text.length) {
        self.scrollView.hidden = NO;
        self.tableView.hidden  = YES;

        [self.tableView setEnableLoadNew:NO];

        //resetData
        self.manager.dynArray  = nil;
        self.manager.conArray  = nil;
        [self.tableView reloadData];
    }
    else{
        self.scrollView.hidden = YES;
        self.tableView.hidden  = NO;

        [self.tableView setNoDataInAllSections:YES noData:NO withText:@""];
        [self.tableView setEnableLoadNew:YES];
    }

}

#pragma mark - Action
-(void)cancel:(id)sender
{
    [self.textField resignFirstResponder];
    self.manager.dynArray  = nil;
    self.manager.conArray  = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMoreBtn:(UIButton *)sender{
    switch (sender.tag) {
        case MoreType_Dyn:
        {
            YHSearchDynamicViewController *vc = [[YHSearchDynamicViewController alloc]init];
            vc.keyWord = self.textField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MoreType_Fri:
        {
            YHSearchConnectionsController *vc = [[YHSearchConnectionsController alloc] init];
            vc.keyWord = self.textField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case Section_Dynamic:
        {
            if (self.manager.dynArray.count) {
                return kHeaderH;
            }
            return 0;
        }
            break;
        case  Seciton_Fri:
        {
            if(self.manager.conArray.count){
                return kHeaderH;
            }
            return 0;
        }
            break;
        default:
            return 0;
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case Section_Dynamic:
        {
            if (self.manager.dynArray.count) {
                return kFooterH;
            }
            return 0;
        }
            break;
        case  Seciton_Fri:
        {
            if(self.manager.conArray.count){
                return kFooterH;
            }
            return 0;
        }
            break;
        default:
            return 0;
            break;
    }

}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case Section_Dynamic:
            return self.dynHeaderInSection;
            break;
        case Seciton_Fri:
            return self.friHeaderInSection;
            break;
        default:
            return nil;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    switch (section) {
        case Section_Dynamic:
            return self.dynFooterInSection;
            break;
        case Seciton_Fri:
            return self.friFooterInSection;
            break;
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {

        case Section_Dynamic:
        {

            if (indexPath.row < self.manager.dynArray.count) {

                //原创cell
                Class currentClass  = [CellForWorkGroup class];
                YHWorkGroup *model  = self.manager.dynArray[indexPath.row];

                CGFloat height = 0.0;

                //转发cell
                if (model.type == DynType_Forward) {
                    currentClass = [CellForWorkGroupRepost class];//第一版没有转发,因此这样稍该一下


                    height = [CellForWorkGroupRepost hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                        CellForWorkGroupRepost *cell = (CellForWorkGroupRepost *)sourceCell;

                        cell.model = model;

                    } cache:^NSDictionary *{
                        return @{
                                 kHYBCacheUniqueKey:model.dynamicId,
                                 kHYBCacheStateKey : @(model.isOpening),
                                 kHYBRecalculateForStateKey:@(NO)
                                 };// 标识不用重新更新
                    }];

                }
                else{

                    height = [CellForWorkGroup hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                        CellForWorkGroup *cell = (CellForWorkGroup *)sourceCell;

                        cell.model = model;

                    } cache:^NSDictionary *{
                        return @{
                                 kHYBCacheUniqueKey:model.dynamicId,
                                 kHYBCacheStateKey : @(model.isOpening),
                                 kHYBRecalculateForStateKey:@(NO)
                                 };// 标识不用重新更新
                    }];
                }

                return height;
            }
            else{
                return 44.0f;
            }

        }
            break;
        case Seciton_Fri:
        {
            return 50.0f;
        }
            break;

        default:
        {
            return 44.0f;
        }
            break;
    }


}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    if (tableView == self.tableView) {

        switch (indexPath.section)
        {
            case Section_Dynamic:
            {
                if (indexPath.row < [self.manager.dynArray count]) {

                    self.manager.selIndexPath = indexPath;
                    YHWorkGroup *workGroup = self.manager.dynArray[indexPath.row];

                    YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup];
//                    vc.refreshSynthesisPage = YES;
                    vc.refreshPage = RefreshPage_Synthesis;
                    [self.navigationController pushViewController:vc animated:YES];
                }

            }
                break;
            case Seciton_Fri:
            {
                if (indexPath.row < self.manager.conArray.count) {
                    YHUserInfo *userInfo = self.manager.conArray[indexPath.row];
                    CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }


}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    switch (section) {

        case Section_Dynamic:
             return self.manager.dynArray.count;
            break;
        case Seciton_Fri:
            return self.manager.conArray.count;
            break;
        default:
            return 0;
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    switch (indexPath.section) {

        case Section_Dynamic:
        {

            if (indexPath.row < [self.manager.dynArray count])
            {

                UITableViewCell *cell;
                //原创cell
                Class currentClass  = [CellForWorkGroup class];
                YHWorkGroup *model  = self.manager.dynArray[indexPath.row];
                model.hiddenBotLine = YES;
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
            {
                return kErrorCell;
            }

        }
            break;
        case Seciton_Fri:
        {
           ConnectionSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionSearchCell" forIndexPath:indexPath];
            if (indexPath.row < self.manager.conArray.count) {
                cell.userInfo = self.manager.conArray[indexPath.row];
            }
            return cell;
        }
            break;
        default:
            return kErrorCell;
            break;
    }

}


#pragma mark - CellForWorkGroupRepostDelegate

- (void)onMoreInRespostCell:(CellForWorkGroupRepost *)cell{

    if (cell.indexPath.row < [self.manager.dynArray count]) {
        YHWorkGroup *model = self.manager.dynArray[cell.indexPath.row];
        model.isOpening = !model.isOpening;
        [self.tableView reloadData];
    }
}

- (void)onTapRepostViewInCell:(CellForWorkGroupRepost *)cell{

    if (cell.indexPath.row < [self.manager.dynArray count]) {
        YHWorkGroup *workGroup = self.manager.dynArray[cell.indexPath.row];
        YHDynDetailVC *vc =[[YHDynDetailVC alloc] initWithWorkGroup:workGroup.forwardModel];
//        vc.refreshWorkGroupPage = YES;
        vc.refreshPage = RefreshPage_WorkGroup;
        self.manager.selIndexPath = cell.indexPath;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onCommentInRepostCell:(CellForWorkGroupRepost *)cell{
    [self _commentAtIndexPath:cell.indexPath tableView:self.tableView dataArray:self.manager.dynArray type:cell.model.type];
}

- (void)onLikeInRepostCell:(CellForWorkGroupRepost *)cell{

    [self _likeWithRepostCell:cell tableView:self.tableView dataArray:self.manager.dynArray];
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

    if (cell.indexPath.row < [self.manager.dynArray count]) {
        YHWorkGroup *model = self.manager.dynArray[cell.indexPath.row];
        model.isOpening = !model.isOpening;
        [self.tableView reloadData];
    }
}

- (void)onDeleteInCell:(CellForWorkGroup *)cell{

    if (cell.indexPath.row < [self.manager.dynArray count]) {
        __weak typeof(self)weakSelf = self;

        [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:cell.model.dynamicId complete:^(BOOL success, id obj) {
                    if (success)
                    {
                        [weakSelf.manager.dynArray removeObjectAtIndex:cell.indexPath.row];
                        [weakSelf.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [weakSelf.tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
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

        [YHAlertView showWithTitle:@"删除动态" message:@"您确定要删除此动态?" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                [[NetManager sharedInstance] postDeleteDynamcicWithDynamicId:cell.model.dynamicId complete:^(BOOL success, id obj) {
                    if (success)
                    {
                        [weakSelf.manager.dynArray removeObjectAtIndex:cell.indexPath.row];
                        [weakSelf.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [weakSelf.tableView performSelector:@selector(reloadData) withObject:weakSelf afterDelay:0.5];
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

    }

}


- (void)onCommentInCell:(CellForWorkGroup *)cell{
    [self _commentAtIndexPath:cell.indexPath tableView:self.tableView dataArray:self.manager.dynArray type:cell.model.type];
}

- (void)onLikeInCell:(CellForWorkGroup *)cell{

    [self _likeWithOriCell:cell tableView:self.tableView dataArray:self.manager.dynArray];

}

- (void)onShareInCell:(CellForWorkGroup *)cell{

    [self _shareWithCell:cell];

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



#pragma mark - 网络请求
- (void)requestSynthesisSearchLoadNew:(BOOL)loadNew{

    YHRefreshType refreshType;
    if (loadNew) {
        _currentRequestPage = 1;
        refreshType = YHRefreshType_LoadNew;
    }
    else{
        _currentRequestPage ++;
        refreshType = YHRefreshType_LoadMore;
    }

    __weak typeof (self)weakSelf = self;
    [self.tableView loadBegin:refreshType];

    [[NetManager sharedInstance] getSynthesisSearchWithKeyWord:self.textField.text complete:^(BOOL success, id obj)
    {
        [weakSelf.tableView loadFinish:refreshType];

        if (success) {

            NSDictionary *dictRet = obj;
            NSArray *dynArray     = dictRet[@"dynamics"];
            NSArray *conArray     = dictRet[@"accounts"];

            if (loadNew)
            {
                 weakSelf.manager.dynArray = [NSMutableArray arrayWithArray:dynArray];
                 weakSelf.manager.conArray = [NSMutableArray arrayWithArray:conArray];
            }



            if (loadNew)
            {
                if (!dynArray.count && !conArray.count)
                {
                    [weakSelf.tableView setNoDataInAllSections:YES noData:YES withText:@"没有符合条件的搜索结果"];
                }
                else
                {
                    [weakSelf.tableView setNoDataInAllSections:YES noData:NO withText:@""];
                }
            }

            [weakSelf _textLayoutWithModels:weakSelf.manager.dynArray];
            [weakSelf.tableView reloadData];

        }
        else{


            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                postTips(msg, @"综合搜索失败");
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"综合搜索失败");
            }

        }
    }];

}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestSynthesisSearchLoadNew:YES];
}


#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     DDLog(@"%s vc dealloc",__FUNCTION__);

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotification
- (void)refreshData:(NSNotification *)aNotifi{

    [self refreshDataAtIndexPath:self.manager.selIndexPath dataArray:self.manager.dynArray aNotification:aNotifi tableView:self.tableView];


    YHWorkGroup *modelInTimePage = nil;
    if (self.manager.selIndexPath.row < self.manager.dynArray.count) {
        modelInTimePage = self.manager.dynArray[self.manager.selIndexPath.row];
    }

    for (int i=0; i< self.manager.dynArray.count; i++)
    {
        YHWorkGroup *modelInHotPage = self.manager.dynArray[i];
        if (modelInTimePage.dynamicId) {
            if ([modelInHotPage.dynamicId isEqualToString:modelInTimePage.dynamicId])
            {

                modelInHotPage.commentCount = modelInTimePage.commentCount;
                modelInHotPage.isLike       = modelInTimePage.isLike;
                break;
            }
        }
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
