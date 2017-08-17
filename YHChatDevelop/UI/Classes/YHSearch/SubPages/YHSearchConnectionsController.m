//
//  YHSearchConnectionsController.m
//  YHChatDevelop
//
//  Created by YHIOS002 on 2017/8/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHSearchConnectionsController.h"
#import "ConnectionSearchCell.h"
#import "YHUserInfo.h"
#import "CardDetailViewController.h"
#import "UIView+Extension.h"
#import "YHNetManager.h"
#import "YHRefreshTableView.h"
#import "YHUICommon.h"
#import "Masonry.h"

@interface YHSearchConnectionsController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    int _currentRequestPage;//当前请求页码
}

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIImageView *glass;

@property (nonatomic, strong) YHRefreshTableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation YHSearchConnectionsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpNavigationBar];
    [self setUpTableView];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.textField];
    if (self.keyWord.length) {
        self.textField.text = self.keyWord;
        [self requestSearchConnectionLoadNew:YES];
    }
    
}

#pragma mark - Lazy Load
- (NSMutableArray *)dataArray
{
    if (!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - init
- (void)setUpNavigationBar{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 34)];
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
    self.textField.tintColor  = [UIColor blueColor];
    self.textField.placeholder = @"姓名/公司/职位/税道号";
    self.textField.clearButtonMode = UITextFieldViewModeAlways;

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

- (void)setUpTableView{
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    self.tableView.tableHeaderView = view;
    [self.tableView registerClass:[ConnectionSearchCell class] forCellReuseIdentifier:@"ConnectionSearchCell"];

    [self.tableView setEnableLoadNew:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [self.textField resignFirstResponder];
        [self.dataArray removeAllObjects];
        [self requestSearchConnectionLoadNew:YES];
    }
    return YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        if (indexPath.row < self.dataArray.count) {

            YHUserInfo *userInfo = self.dataArray[indexPath.row];

            if (userInfo.identity == Identity_BigName)
            {

//                YHTalentDetailController *vc = [[YHTalentDetailController alloc] init];
//                vc.userInfo = userInfo;
//                [self.navigationController pushViewController:vc animated:YES];

            }
            else
            {

                CardDetailViewController *vc = [[CardDetailViewController alloc] initWithUserInfo:userInfo];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];

            }

        }

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.dataArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ConnectionSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionSearchCell" forIndexPath:indexPath];

    if (indexPath.row < self.dataArray.count) {
        cell.userInfo = self.dataArray[indexPath.row];
    }

    return cell;

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}

#pragma mark - Action
- (void)cancel:(id)sender
{
    [self.textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSNotification

- (void)textFiledEditChanged:(NSNotification *)aNotifi{
    if (!self.textField.text.length) {
        [self.dataArray removeAllObjects];
        [self.tableView setNoData:YES withText:@""];
        [self.tableView reloadData];
    }
}


#pragma mark - 网络请求
- (void)requestSearchConnectionLoadNew:(BOOL)loadNew{

    if(!self.textField.text.length){
        postTips(@"请输入搜索内容",nil);
        if(loadNew){
            [self.tableView setNoData:YES withText:@""];
            [self.tableView loadFinish:YHRefreshType_LoadNew];
        }
        else{
            [self.tableView loadFinish:YHRefreshType_LoadMore];
        }
    }
    else
    {

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

        [self.tableView loadBegin:refreshType];
        __weak typeof(self) weakSelf = self;
        [[NetManager sharedInstance] getSearchConnectionWithKeyWord:self.textField.text count:lengthForEveryRequest currentPage:_currentRequestPage complete:^(BOOL success, id obj) {
            [weakSelf.tableView loadFinish:refreshType];

            if (success) {
                DDLog(@"搜索人脉成功:%@",obj);
                NSArray *retArray = obj;

                if (loadNew) {
                    self.dataArray = [retArray mutableCopy];
                }
                else{
                    [self.dataArray addObjectsFromArray:retArray];
                }

                if (retArray.count < lengthForEveryRequest) {
                    if (loadNew) {
                        if(!retArray.count){
                            [weakSelf.tableView setNoData:YES withText:@"没有符合条件的搜索结果"];
                        }
                        else{
                            [weakSelf.tableView setNoMoreData:YES];
                        }
                    }
                    else{
                        [weakSelf.tableView setNoMoreData:YES];
                    }
                }

                [weakSelf.tableView reloadData];


            }
            else{
                if(isNSDictionaryClass(obj)){
                    NSString *msg  = obj[kRetMsg];
                    postTips(msg,@"搜索人脉失败");
                }
                else{
                    postTips(obj,@"搜索人脉失败");
                }
            }
        }];

    }
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestSearchConnectionLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    [self requestSearchConnectionLoadNew:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
