//
//  AddFansViewController.m
//  MyProject
//
//  Created by YHIOS002 on 16/4/12.
//  Copyright © 2016年 kun. All rights reserved.
//

#import "AddFansViewController.h"
//#import "AddABViewController.h"
#import "YHAddressBook.h"
#import "HHUtils.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "YHUserInfo.h"
#import "CardDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YHRefreshTableView.h"
#import "ConnectionSearchCell.h"
//#import "YHTalentDetailController.h"
#import <AVFoundation/AVFoundation.h>
#import "YHChatDevelop-Swift.h"


@interface AddFansViewController ()
<UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{
    int _currentRequestPage;//当前请求页码
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *conArray;//人脉搜索Array
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) YHRefreshTableView *tableView;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation AddFansViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[self initUI];
	[self initData];
    
}

- (NSMutableArray *)dataArray
{
	if (!_dataArray)
	{
		_dataArray = [NSMutableArray array];
	}
	return _dataArray;
}

-(NSMutableArray *)conArray{
    if (!_conArray) {
        _conArray = [NSMutableArray array];
    }
    return _conArray;
}

- (void)initUI
{
	self.title = @"添加好友";

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
	self.view.backgroundColor = kViewBGColor;
	self.isSearching = NO;
	//tableview
	self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH
		, SCREEN_HEIGHT-64-44) style:UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
	self.tableView.backgroundColor = kViewBGColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ConnectionSearchCell class] forCellReuseIdentifier:@"ConnectionSearchCell"];
    [self.tableView registerClass:[CellForBase1 class] forCellReuseIdentifier:NSStringFromClass([CellForBase1 class])];
    
	//searchBar
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	[self.view addSubview:self.searchBar];
	self.searchBar.delegate = self;
	self.searchBar.enablesReturnKeyAutomatically = NO;
	self.searchBar.placeholder = @"姓名/公司/职位/税道号";
	_searchBar.layer.borderWidth = 1;
	_searchBar.layer.borderColor = RGBCOLOR(240, 240, 240).CGColor;
	_searchBar.barTintColor = RGBCOLOR(240, 240, 240);

	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)initData
{
	//2.数据初始化
	NSDictionary *dictData = [NSMutableDictionary dictionaryWithCapacity:3];

	for (int i = 0; i < 3; i++)
	{
		switch (i)
		{
			case 0:
				dictData = @{
					@"icon" : @"connections_img_addressBook",
					@"title" : @"手机联系人"
				};
				break;

			case 1:
				dictData = @{
					@"icon" : @"connections_img_QRCode",
					@"title" : @"二维码添加好友"
				};
				break;

			case 2:
				dictData = @{
					@"icon" : @"b_menu_msg",
					@"title" : @"从二度人脉添加好友"
				};
				break;

			default:
				break;
		}
		[self.dataArray addObject:dictData];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
- (void)requestSearchConnectionLoadNew:(BOOL)loadNew{
    
    if(!self.searchBar.text.length){
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
        }
        else{
            _currentRequestPage ++;
            refreshType = YHRefreshType_LoadMore;
        }
        
        [self.tableView loadBegin:refreshType];
        __weak typeof(self) weakSelf = self;
        [[NetManager sharedInstance] getSearchConnectionWithKeyWord:self.searchBar.text count:lengthForEveryRequest currentPage:_currentRequestPage complete:^(BOOL success, id obj) {
            [weakSelf.tableView loadFinish:refreshType];
            
            if (success) {
                DDLog(@"搜索人脉成功:%@",obj);
                NSArray *retArray = obj;
                
                if (loadNew) {
                    self.conArray = [retArray mutableCopy];
                }
                else{
                    [self.conArray addObjectsFromArray:retArray];
                }
                
                if (retArray.count < lengthForEveryRequest) {
                    if (loadNew) {
                        if(!retArray.count){
                            [weakSelf.tableView setNoDataInAllSections:YES noData:YES withText:@"没有符合条件的搜索结果"];
                           
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.isSearching ? [self.conArray count] : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isSearching)
	{
        
        ConnectionSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionSearchCell" forIndexPath:indexPath];
        
        if (indexPath.row < self.conArray.count) {
            cell.userInfo = self.conArray[indexPath.row];
        }
        
        return cell;

	}
	else
	{
        CellForBase1 *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForBase1 class])];

		if (indexPath.row < self.dataArray.count)
		{
			NSDictionary *dict = self.dataArray[indexPath.row];
            cell.dictData = dict;
		}

		return cell;
	}
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isSearching){
        return 50;
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (self.isSearching)
    {
        if (indexPath.row < self.conArray.count) {
            
            YHUserInfo *userInfo = self.conArray[indexPath.row];
            
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
    else
    {
        switch (indexPath.row)
        {
            case 0:
            {
                if (checkABGranted())
                {
//                    AddABViewController *vc = [[AddABViewController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    //2.引导用户打开隐私中-通讯录-权限
                    postTips(@"税道APP没有权限访问您的通讯录，请在设置中开启税道访问通讯录的权限", nil);
                    return;
                }
            }
                break;
                
            case 1:
            {
                
                NSString *mediaType = AVMediaTypeVideo;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                
                if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
                    postTips(@"税道APP没有权限访问您的相机，请在设置中开启税道访问相机的权限", nil);
                    return;
                }
                
                //二维码添加好友
//                YHScanVC *vc = [[YHScanVC alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            case 2:
                
                break;
                
            default:
                break;
        }

    }
	

}

#pragma mark - UISearchBarDelegate
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0)
//{
//    if(range.location != 0){
//        self.isSearching = YES;
//    }else{
//        self.userInfo = nil;
//        self.isSearching = NO;
//        ROLOAD_MYTABLEVIEW
//    }
//	return YES;
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length == 0) {
        self.isSearching = NO;
        [self.tableView setEnableLoadNew:NO];
//        [self.tableView reloadData];
    }else{
        self.isSearching = YES;
        [self.tableView setEnableLoadNew:YES];
    }
   
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar endEditing:YES];

	if (searchBar.text.length == 0)
	{
		return;
	}

    [self requestSearchConnectionLoadNew:YES];
    
}


#pragma mark - Life
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

#pragma mark - Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

#pragma mark - YHRefreshTableViewDelegate
- (void)refreshTableViewLoadNew:(YHRefreshTableView*)view{
    [self requestSearchConnectionLoadNew:YES];
}

- (void)refreshTableViewLoadmore:(YHRefreshTableView*)view{
    [self requestSearchConnectionLoadNew:NO];
}

/*
 * #pragma mark - Navigation
 *
 *  // In a storyboard-based application, you will often want to do a little preparation before navigation
 *  - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 *   // Get the new view controller using [segue destinationViewController].
 *   // Pass the selected object to the new view controller.
 *  }
 */

@end
