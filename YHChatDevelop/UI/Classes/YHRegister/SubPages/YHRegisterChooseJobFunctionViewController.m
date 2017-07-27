//
//  YHRegisterChooseJobFunctionViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/20.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHRegisterChooseJobFunctionViewController.h"
#import "CellForJobType.h"
#import "CellForJobDetail.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import "YHRegisterCompleteInfoViewController.h"
#import "YHCacheManager.h"
#import "MBProgressHUD.h"

@interface YHRegisterChooseJobFunctionViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSString *_strSelIndustry;  //选择的行业
    NSString *_strSelJob;       //选择的职业
}

@property (weak, nonatomic) IBOutlet UIView *viewForTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cstTbvTop;
@property (weak, nonatomic) IBOutlet UITableView *tbvJobType;
@property (weak, nonatomic) IBOutlet UITableView *tbvJobDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnSure; //确定按钮,（在没有导航栏情况下的“确定”按钮）

@property (copy,nonatomic) NSMutableArray *maAllData;
@property (copy,nonatomic) NSMutableArray *arrayIndustry;  //行业
@property (copy,nonatomic) NSMutableArray *arrayJob;       //具体职位
@property (copy,nonatomic) void(^selectedJobBlock)(NSString *jobType,NSString *jobDetail);
@property (strong,nonatomic) UIButton *btnRightItem;//确定按钮,(在有导航栏情况下的“确定”按钮)
@property (nonatomic,assign) BOOL onSurePushToNextVC; //点击“确定”按钮push到下一个控制器
@property (nonatomic,strong) MBProgressHUD *loading;
@end

@implementation YHRegisterChooseJobFunctionViewController

- (instancetype)initWithSelectedJobBlock:(void(^)(NSString *jobType,NSString *jobDetail))selectedJobBlock{
    if (self = [super init]) {
        
        if (selectedJobBlock) {
             _selectedJobBlock = selectedJobBlock;
        }
       
    }
    return self;
}

- (instancetype)initWithSureToPushNextController:(BOOL)surePushToNextVC{
    if (self = [super init]) {
        _onSurePushToNextVC = surePushToNextVC;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
    

    NSArray *cacheIndustryList = [[YHCacheManager shareInstance] getCacheIndustryList];
    if (cacheIndustryList.count && ![[YHCacheManager shareInstance] needUpdateIndustryList])
    {
        self.maAllData = [cacheIndustryList mutableCopy];
        for (NSDictionary *dict in self.maAllData) {
            [self.arrayIndustry  addObject:dict[@"industry"]];
        }
        [self.tbvJobType reloadData];
    }
    else
    {
        [self requestIndustryList];
    }

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MBProgressHUD *)loading{
    if (!_loading) {
         _loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _loading.labelText = @"保存中...";
        [self.navigationController.view addSubview:_loading];
    }
    return _loading;
}

#pragma mark - initUI
- (void)initUI{
    if (self.navigationController.navigationBar.hidden) {
        _viewForTitle.hidden = NO;
        _cstTbvTop.constant  = 64;
    }
    else{
        //1.有导航栏,隐藏自定义titleView
        _viewForTitle.hidden = YES;
        _cstTbvTop.constant  = 0;
        self.title = @"行业职能";
        
        //2.rightBarItem
        self.btnRightItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self.btnRightItem setTitle:@"确定" forState:UIControlStateNormal];
        
        [self.btnRightItem addTarget:self action:@selector(onSure:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnRightItem];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        
        self.btnRightItem.hidden = YES;
        
    }
    
    
    //初始化UI
    self.btnSure.hidden         = YES;
    self.tbvJobType.rowHeight   = 30.0f;
    self.tbvJobDetail.rowHeight = 30.0f;
    self.tbvJobDetail.scrollsToTop = YES;
    self.tbvJobType.scrollsToTop   = NO;
    
    //边框线（宽度和颜色）
    self.tbvJobType.layer.borderWidth =
    self.tbvJobDetail.layer.borderWidth = 0.5;
    
    self.tbvJobType.layer.borderColor =
    self.tbvJobDetail.layer.borderColor =
    kSeparatorLineColor.CGColor;
    
    self.tbvJobType.layer.masksToBounds = YES;
    self.tbvJobDetail.layer.masksToBounds = YES;

}

#pragma mark - Lazy Load
- (NSMutableArray *)arrayIndustry{
    if (!_arrayIndustry) {
        _arrayIndustry   = [NSMutableArray array];
    }
    return _arrayIndustry;
}

- (NSMutableArray *)arrayJob{
    if (!_arrayJob) {
        _arrayJob = [NSMutableArray array];
    }
    return _arrayJob;
}

- (NSMutableArray *)maAllData{
    if (!_maAllData) {
        _maAllData = [NSMutableArray array];
    }
    return _maAllData;
}

#pragma mark - Action
//点击确定
- (IBAction)onSure:(id)sender {
    
    //1.回调block
    if ([NetManager sharedInstance].currentNetWorkStatus != YHNetworkStatus_NotReachable) {
        if (_selectedJobBlock) {
            _selectedJobBlock(_strSelIndustry,_strSelJob);
        }
        [YHUserInfoManager sharedInstance].userInfo.industry = [NSString stringWithFormat:@"%@|%@",_strSelIndustry,_strSelJob];
    }
    
    //2.网络请求
    NSString *industry = [NSString stringWithFormat:@"%@|%@",_strSelIndustry,_strSelJob];
    
    [self.loading show:YES];
    
    __weak typeof(self) weakSelf = self;
    YHUserInfo *userInfo = [YHUserInfo new];
    userInfo.industry = industry;
    
    [[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
        
        [weakSelf.loading hide:YES];
        if (success) {
            DDLog(@"修改行业成功 %@",obj);
            
            //2.设置单例信息
            [YHUserInfoManager sharedInstance].userInfo.industry = industry;
        }
        else{
          
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"修改行业失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"修改行业失败");
            }
        }
    
        //3.控制器的跳转
        if(_onSurePushToNextVC){
            
            YHRegisterCompleteInfoViewController *vc = [[YHRegisterCompleteInfoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [self onBack:nil];
        }

        
    }];
    
    
//    //*******kun注册调试代码,打开注释可忽略网络请求*******
//    if(_onSurePushToNextVC){
//        
//        YHRegisterCompleteInfoViewController *vc = [[YHRegisterCompleteInfoViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else{
//        [self onBack:nil];
//    }
    
 }

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tbvJobType) {

        //先清空右边选中值
        _strSelJob               = nil;
        self.btnSure.hidden      = YES;
        self.btnRightItem.hidden = YES;
        _strSelIndustry          = _arrayIndustry[indexPath.row];
        
        NSDictionary *dict       = _maAllData[indexPath.row];
         self.arrayJob           =  dict[@"jobs"];

        
       
        //刷新并且自动滚到顶部
        [UIView animateWithDuration:0.3 animations:^{
            self.tbvJobDetail.contentOffset = CGPointMake(0, 0);
        }];
        [self.tbvJobDetail reloadData];
    }
    else if(tableView == self.tbvJobDetail){
        
        _strSelJob         = _arrayJob[indexPath.row];
        
        self.btnSure.hidden      = NO;
        self.btnRightItem.hidden = NO;
        
    }
    else
        return;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tbvJobType) {
        return [_arrayIndustry count];
    }else if(tableView == self.tbvJobDetail){
        return [_arrayJob count];
    }else
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tbvJobType) {
        
        CellForJobType *cell = [CellForJobType cellWithTableView:tableView];
        if (indexPath.row < [_arrayIndustry count]) {
              cell.labelTitle.text = _arrayIndustry[indexPath.row];
        }
      
        return cell;
    }
        
    else if(tableView == self.tbvJobDetail){
        
        CellForJobDetail *cell = [CellForJobDetail cellWithTableView:tableView];
        if (indexPath.row < [_arrayJob count]) {
             cell.labelTitle.text = _arrayJob[indexPath.row];
        }
       
        return cell;
    }
    else
        return kErrorCell;

}

#pragma mark - 网络请求数据
- (void)requestIndustryList{
    [[NetManager sharedInstance] getIndustryListComplete:^(BOOL success, id obj) {
        if (success) {
            
            self.maAllData = obj;
            [[YHCacheManager shareInstance] cacheIndustryList:self.maAllData];
            for (NSDictionary *dict in obj) {
                [self.arrayIndustry  addObject:dict[@"industry"]];
            }
            
            [self.tbvJobType reloadData];
        }
        else{
            
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"获取行业列表失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"获取行业列表失败");
            }
        }
    }];
}

#pragma mark - Life
-(void)dealloc{
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
