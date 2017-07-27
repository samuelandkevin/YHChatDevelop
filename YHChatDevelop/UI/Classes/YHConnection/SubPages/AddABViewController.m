//
//  AddABViewController.m
//  MyProject
//
//  Created by samuelandkevin on 16/4/12.
//  Copyright © 2016年 kun. All rights reserved.
//  

#import "AddABViewController.h"
#import "YHChatDevelop-Swift.h"
#import "YHAddressBook.h"
#import "YHUserInfo.h"
#import "RegexKitLite.h"
#include "pinyin.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "YHNetManager.h"
#import "YHUserInfoManager.h"


static const CGFloat kheaderHeightInsection   = 20;//section的header高度

typedef NS_ENUM(int,SearchState){
    SearchState_Off = 0,//搜索关闭
    SearchState_On      //搜索中
};

@interface AddABViewController ()<UISearchBarDelegate,MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,CellForABDelegate>{
    

    __weak IBOutlet NSLayoutConstraint *_cstSearchBarTop;
    //控件
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UILabel     *_labelSectionIndex;
    __weak IBOutlet UIView      *_viewShowSectionIndex;
    
    SearchState _searchState;
}

@property (nonatomic,strong)NSMutableArray *maAllFans;          //所有好友数组(未排序)
@property (nonatomic,strong)NSMutableArray *maSectionHeadsKeys; //section表头的标题数组
@property (nonatomic,strong)NSMutableDictionary *maDictSort;         //排序后的字典


@property (nonatomic,strong) NSMutableArray <YHABUserInfo*>*maABFansAll;       //通讯录用户数组

@property (nonatomic,strong)NSArray *registerUserPhones;

@property (nonatomic,copy) NSMutableArray *maAllPhones;      //所有的手机号码

@property (nonatomic,weak) IBOutlet UITableView *tableViewList;
@property (nonatomic,strong) NSMutableArray *maSearchResult;
@end

@implementation AddABViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //1.initUI
    [self initUI];
   
    //2.initData
    [self getABFansData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)maSearchResult{

    if (!_maSearchResult) {
        _maSearchResult = [NSMutableArray array];
    }
    return _maSearchResult;
}

- (NSArray *)registerUserPhones
{
    if (!_registerUserPhones) {
        _registerUserPhones = [NSMutableArray array];
    }
    return _registerUserPhones;
}

- (void)initUI
{
    self.title = @"手机通讯录";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    
    self.tableViewList.rowHeight    = 60;
   
    //双击置顶
    self.tableViewList.scrollsToTop = NO;
    
    self.tableViewList.backgroundColor = kTbvBGColor;
    self.tableViewList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableViewList.sectionIndexColor = RGBCOLOR(160, 160, 160);
    [self.tableViewList registerClass:[CellForAB class] forCellReuseIdentifier:NSStringFromClass([CellForAB class])];
    
    //当searchBar置顶,设置状态栏背景颜色
    self.view.backgroundColor = RGBCOLOR(240, 240, 240);
    //去边框线
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = RGBCOLOR(240, 240, 240).CGColor;
    _searchBar.tintColor = [UIColor blueColor];
  
}


#pragma mark - Lazy Load

- (NSMutableArray *)maAllPhones{
    if (!_maAllPhones) {
        _maAllPhones = [NSMutableArray array];
    }
    return _maAllPhones;
}

- (NSMutableArray *)maABFansAll{
    if (!_maABFansAll) {
        _maABFansAll = [NSMutableArray array];
    }
    return _maABFansAll;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (_searchState) {
        case SearchState_On:
            return [self.maSearchResult count];
            break;
        case SearchState_Off:
        {
            NSString *key       = self.maSectionHeadsKeys[section];
            NSArray  *arrayNick = self.maDictSort[key];
            return arrayNick.count;
        }
            break;
        default:
            return 0;
            break;
    }

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    switch (_searchState) {
        case SearchState_On:
        {
            CellForAB *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForAB class])];
            cell.delegate = self;
            if (indexPath.row < [self.maSearchResult count]) {
                cell.userInfo   = [self.maSearchResult objectAtIndex:indexPath.row];
            }
            return cell;
        }
            break;
        case SearchState_Off:
        {
            CellForAB *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForAB class])];
            cell.delegate      = self;
            NSString *key      = [self.maSectionHeadsKeys objectAtIndex:indexPath.section];
            NSArray *arrayNick = self.maDictSort[key];
            cell.indexPath = indexPath;
            [cell resetCell];
            if (indexPath.row < arrayNick.count) {
                cell.userInfo   = [arrayNick objectAtIndex:indexPath.row];
            }
            
            return cell;
        }
            break;
            
        default:
            return kErrorCell;
            break;
    }
    
    
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    switch (_searchState) {
        case SearchState_On:
        {
            return 1;
        }
            break;
        case SearchState_Off:
        {
            return self.maSectionHeadsKeys.count;
        }
            break;

        default:
            return 0;
            break;
    }

}

//点击索引栏滚动到指定位置
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    
    switch (_searchState) {
        case SearchState_On:
        {
            return 0;
        }
            break;
        case SearchState_Off:
        {
            // 获取所点目录对应的indexPath值
            NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
            
            // 让table滚动到对应的indexPath位置
            [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            return [self.maDictSort allKeys].count;
        }
            break;
            
        default:
            return 0;
            break;
    }


}


- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    switch (_searchState) {
        case SearchState_On:
        {
            return nil;
        }
            break;
        case SearchState_Off:
        {
            return self.maSectionHeadsKeys;
        }
            break;
        default:
            return nil;
            break;
    }
   
    
}

//自定义headerInSectionView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    switch (_searchState) {
        case SearchState_On:
        {
            return nil;
        }
            break;
        case SearchState_Off:
        {
            static NSString *headerId = @"headFoot";
            UITableViewHeaderFooterView * hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
            if (!hf) {
                hf = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerId];
                hf.contentView.backgroundColor = kTbvBGColor;
                
                //首字母
                UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, kheaderHeightInsection)];
                labelTitle.tag  = 101;
                labelTitle.font = [UIFont systemFontOfSize:14.0f];
                labelTitle.textColor = RGBCOLOR(160, 160, 160);
                [hf addSubview:labelTitle];
            }
            
            //设置section标题
            UILabel *labelTitle = (UILabel *)[hf viewWithTag:101];
            NSString *key = [self.maSectionHeadsKeys objectAtIndex:section];
            labelTitle.text = key;
            return hf;

        }
            break;
        default:
             return nil;
            break;
    }
   
    
    
}

//headerInSection 行高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    switch (_searchState) {
        case SearchState_On:
            return 0;
            break;
        case SearchState_Off:
            return kheaderHeightInsection;
            break;
        default:
            return 0;
            break;
    }
    
    
}

#pragma mark - CellForABDelegate
- (void)onBtnInvitedInCell:(CellForAB * _Nonnull)cell{
    
    BOOL isRegister    = cell.userInfo.isRegister;
    NSString *relation = cell.userInfo.relation;
    NSString *addFriStatus = cell.userInfo.addFriStatus;
    if (isRegister)
    {
        //已注册
        if(!relation.length)
        {
            //至今没有申请过加好友
            
            __block MBProgressHUD *hud = showHUDWithText(@"", [UIApplication sharedApplication].keyWindow.rootViewController.view);
            [[NetManager sharedInstance] postAddFriendwithFriendId:cell.userInfo.uid complete:^(BOOL success, id obj)
             {
                 [hud hide:YES];
                 if (success)
                 {
                     
                     NSString *userName = cell.userInfo.userName.length?cell.userInfo.userName:@"TA";
                     NSString *tips = [NSString stringWithFormat:@"您已申请添加%@为好友",userName];
                     postHUDTipsWithHideDelay(tips, self.view, 3);
                     
                     //更新数据
                     NSString *key = self.maSectionHeadsKeys[cell.indexPath.section];
                     NSArray *arrayNick = self.maDictSort[key];
                     YHABUserInfo *userInfo =  arrayNick[cell.indexPath.row];
                     userInfo.addFriStatus = @"1";
                     [self.tableViewList reloadData];
                 }
                 else
                 {
                     
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
        else
        {
            switch ([relation intValue])
            {
                case 0:
                {
                    //不是好友关系
                    
                    //判断加好友状态
                    if (!addFriStatus)
                    {
                        
                        
                    }
                    else
                    {
                        switch ([addFriStatus intValue])
                        {
                            case 0:
                            {
                                //对方添加我为好友
                                __block MBProgressHUD *hud = showHUDWithText(@"", [UIApplication sharedApplication].keyWindow.rootViewController.view);
                                [[NetManager sharedInstance] postAcceptAddFriendRequest:cell.userInfo.uid complete:^(BOOL success, id obj) {
                                    [hud hide:YES];
                                    if (success)
                                    {
                                        postHUDTips(@"验证通过",self.view);
                                        
                                        for (NSString *key in _maSectionHeadsKeys)
                                        {
                                            NSArray *userNick =  _maDictSort[key];
                                            [userNick enumerateObjectsUsingBlock:^(YHABUserInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                
                                                if ([obj.uid isEqualToString:cell.userInfo.uid])
                                                {
                                                    obj.relation = @"1";
                                                    *stop = YES;
                                                }
                                                
                                            }];
                                        }
                                        [self.tableViewList reloadData];
                                        
                                    }
                                    else
                                    {
                                        if (isNSDictionaryClass(obj))
                                        {
                                            //服务器返回的错误描述
                                            NSString *msg  = obj[kRetMsg];
                                            
                                            postTips(msg, @"接受加好友请求失败");
                                            
                                        }
                                        else
                                        {
                                            //AFN请求失败的错误描述
                                            postTips(obj, @"接受加好友请求失败");
                                        }
                                        
                                    }
                                }];
                                
                            }
                                break;
                            case 1:
                            {
                                
                                //已申请加好友,等待对方通过验证
                                
                                
                            }
                                break;
                            default:
                                break;
                        }
                    }
                    
                }
                    break;
                case 1:
                {
                    //已经是好友关系
                    
                }
                    break;
                default:
                    break;
            }
        }
        
    }
    else
    {
        NSString *userName = [YHUserInfoManager sharedInstance].userInfo.userName;
        NSString *companyWeb = [YHUserInfoManager sharedInstance].companyWeb;
        if (!companyWeb.length) {
            companyWeb = @"www.samuelandkevin.com";
        }
        NSString *message = [NSString stringWithFormat:@"【APP】您的好友%@邀请您加入税道人脉圈，一个集财税行业人脉的平台，找人办事不再难，财税大咖云集，快点行动吧下载地址：%@",userName,companyWeb];
        if(cell.userInfo.mobilephone)
        {
            [self showMessageView:@[cell.userInfo.mobilephone] title:@"新消息" body:message];
        }
        
    }
}


#pragma mark - Private

/**
 *  获取排序后的数组
 *
 *  @param arrToSort 待排序的数组
 *
 *  @return 排序成功的数组
 */
- (NSMutableArray *)getSortArr:(NSMutableArray *)arrToSort
{
    
    [arrToSort sortUsingComparator:^NSComparisonResult(YHABUserInfo * obj1, YHABUserInfo * obj2) {
        
        return  [obj1.userName localizedCaseInsensitiveCompare:obj2.userName];
    }];
    
    NSMutableDictionary *dictSourceData = [NSMutableDictionary dictionary];
    for (YHABUserInfo *info in arrToSort)
    {
        NSString *key = [NSString string];
        BOOL isEn = [info.userName isMatchedByRegex:@"^[a-zA-Z]+"];
        if(isEn)
        {
            //首位为字母开头
            key = [[info.userName substringToIndex:1] uppercaseString];
        }else
        {
            char a = pinyinFirstLetter([info.userName characterAtIndex:0]);
            key = [[NSString stringWithFormat:@"%c", a] uppercaseString];
        }
        
        NSMutableArray *nickByLetter = dictSourceData[key];
        if (!nickByLetter)
        {
            nickByLetter = [NSMutableArray array];
            [dictSourceData setObject:nickByLetter forKey:key];
        }
        [nickByLetter addObject:info];
    }
    
    
    NSArray *tempKeySort = [[dictSourceData allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString  *obj1, NSString *obj2)
    {
        
        char a1 = [obj1 characterAtIndex:0];
        char a2 = [obj2 characterAtIndex:0];
        
        if (a1 > a2) {
            return NSOrderedDescending;
        }else if(a1 == a2){
            return NSOrderedSame;
        }else{
            return NSOrderedAscending;
        }
        
    }];
    
    NSMutableArray *maResultKeySort = [NSMutableArray arrayWithArray:tempKeySort];
    if ([tempKeySort[0] isEqualToString:@"#"]) {
        //交换首尾位置
        [maResultKeySort removeObject:@"#"];
        [maResultKeySort addObject:@"#"];
    }
    
    self.maSectionHeadsKeys = maResultKeySort;
    self.maDictSort = dictSourceData;
    return  arrToSort;
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchState = SearchState_On;
    [self.tableViewList reloadData];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if (!searchBar.text.length) {
        _searchState = SearchState_Off;
        [self.tableViewList reloadData];
    }
   
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    _searchState = SearchState_On;
    //空格去除
    if([searchBar.text hasPrefix:@" "]){
        searchBar.text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    
    [self.maSearchResult removeAllObjects];
    for (int i= 0; i < self.maSectionHeadsKeys.count; i++)
    {
        if (i < self.maSectionHeadsKeys.count)
        {
            NSString *key      = [self.maSectionHeadsKeys objectAtIndex:i];
            NSArray *arrayNick = self.maDictSort[key];
            
            for (YHABUserInfo *userInfo in arrayNick)
            {
                
                
                if ([userInfo.mobilephone containsString:searchBar.text] )
                {
                    [self.maSearchResult addObject:userInfo];
                    continue;
                }
                else if([userInfo.userName containsString:searchBar.text]){
                    [self.maSearchResult addObject:userInfo];
                    continue;
                }
                
                
            }
        }
    }
    [self.tableViewList reloadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
    
   
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
   
}

#pragma mark - 网络请求

/**
 *  请求通讯录好友数据
 */
- (void)getABFansData{
    //1.获取通讯录所有好友
    self.maABFansAll = [getAddressBookContacts() mutableCopy]; //--> 数组元素是YHABUserInfo
    
    NSMutableArray *allphones = [NSMutableArray arrayWithCapacity:self.maABFansAll.count];
    DDLog(@"获取到了%zi条通讯录信息",_maABFansAll.count);
    NSMutableArray *noPhone = [NSMutableArray array];
    for (int i = 0; i < _maABFansAll.count; i++)
    {
        //1-1.获取所有联系人名字
        YHABUserInfo* person1 = [_maABFansAll objectAtIndex:i];
        
        //1-2.所有联系人电话
        if (person1.mobilephone) {
            [allphones addObject:person1.mobilephone];
        }
        else {
            // 没电话的删除
            [noPhone addObject:person1];
        }
    }
    
     self.maAllPhones = [allphones mutableCopy];
    
    [self.maABFansAll removeObjectsInArray:noPhone];
    
    if (!self.maAllPhones.count)
    {
        return ;
    }
    
    [[NetManager sharedInstance] postVerifyPhonesAreRegistered:self.maAllPhones complete:^(BOOL success, id obj) {
        if (success)
        {
            
            NSArray *registerUserIds    = obj[@"id"];
            self.registerUserPhones     = obj[@"mobile"];
            
            if (!registerUserIds.count) {
                return;
            }
            
            [[NetManager sharedInstance] postGetRelationAboutMeWithUserIds:registerUserIds complete:^(BOOL success, id obj)
            {
                
                if (success)
                {
                    
                    //status : 0 已申请 1 已添加
                    NSArray *releationArray = obj;
                    
                    DDLog(@"其他用户与我关系查询成功:%@",obj);
                    
                    for (int i = 0; i < self.registerUserPhones.count; i++)
                    {
                        NSString * phoneRegister = self.registerUserPhones[i];
                        
                        //本地查找出已注册的手机号码
                        for (NSString *key in self.maSectionHeadsKeys)
                        {
                            
                                for (YHABUserInfo *userInfo in self.maDictSort[key])
                                {
                                    if ([userInfo.mobilephone isEqualToString:phoneRegister])
                                    {
                                        
                                        
                                        //status :0 已申请 1 已添加
                                        
                                        if (i < releationArray.count)
                                        {
                                            
                                           NSDictionary *dictRelation =  releationArray[i];
                                            NSString  *status =  dictRelation[@"status"];
                                            userInfo.uid = dictRelation[@"uId"];
                                            userInfo.relation = status;
                                            userInfo.addFriStatus = dictRelation[@"is_sqf"];
                                            userInfo.isRegister = YES;
                                            DDLog(@"手机号码 %@ 与我的关系状态是 %@",phoneRegister , status);
                                        }
                                        
                                        
                                    }
                                     
                                    
                                }
                            
                            
                           
                        }
                       
                        
                    }
                    [self.tableViewList reloadData];
                    
                }
                else
                {

                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg  = obj[kRetMsg];
                        postTips(msg, @"其他用户与我关系查询失败");
                        
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"其他用户与我关系查询失败");
                    }
                }
            }];
            
            DDLog(@"批量验证手机号成功--已经注册的用户是:%@",obj);
        }
        else{
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                postTips(msg, @"批量验证手机号失败");
       
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"批量验证手机号失败");
            }
        }
    }];
    
  
    if(self.maABFansAll.count)
    {
        self.maABFansAll = [self getSortArr:self.maABFansAll];
    }
    [self.tableViewList reloadData];
}


#pragma mark - Action
- (void)onCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLog(@"%s vc dealloc",__FUNCTION__);
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    _cellForSelInvited.btnInvite.userInteractionEnabled = YES;
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}

- (void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
        [[[[controller viewControllers] lastObject] navigationItem] setRightBarButtonItem:rightItem];
    }
    else
    {
        [YHAlertView showWithTitle:@"该设备不支持短信功能" message:nil cancelButtonTitle:nil otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            
        }];
//        [HHUtils showAlertWithTitle:@"该设备不支持短信功能" message:nil dismiss:^(BOOL resultYes) {
//            
//        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
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
