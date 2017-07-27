//
//  LabelController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/13.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "LabelController.h"
#import "LxGridView.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHSqliteManager.h"
#import "YHChatDevelop-Swift.h"

@interface LabelController () <LxGridViewDataSource, LxGridViewDelegateFlowLayout, LxGridViewCellDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) LxGridView *collectionView;
@property (nonatomic, strong) LxGridViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *widthArray;
@property (nonatomic, strong) NSMutableArray *deleteArray;
@property (nonatomic, strong) NSMutableArray *insertArray;
@property (nonatomic, strong) NSMutableArray *grayInsertArray;
@property (nonatomic, strong) NSIndexPath *removeIndexPath;
@property (nonatomic, assign) LabelArrayState doInsert;
@property (nonatomic, assign) LabelArrayState doDelete;
@end

@implementation LabelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.grayInsertArray = [NSMutableArray array];
    self.insertArray = [NSMutableArray array];
    self.deleteArray = [NSMutableArray array];
    
    self.dataArray = [NSMutableArray arrayWithArray:[YHUserInfoManager sharedInstance].userInfo.jobTags];
    [self.dataArray addObject:@"+"];
    
    self.doInsert = LabelArrayNoObject;
    self.doDelete = LabelArrayNoObject;
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBar.frame = CGRectMake(0, 0, 40, 50);
    [rightBar setTitle:@"保存" forState:UIControlStateNormal];
    [rightBar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBar.titleLabel.font = [UIFont systemFontOfSize:18];
    [rightBar addTarget:self action:@selector(chilkButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBar];
    
    self.flowLayout = [[LxGridViewFlowLayout alloc] init];
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    self.flowLayout.minimumLineSpacing = 15;
    self.flowLayout.minimumInteritemSpacing = 15;
    self.flowLayout.itemSize = CGSizeMake(30, 30);
    
    self.collectionView = [[LxGridView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[LxGridViewCell class] forCellWithReuseIdentifier:@"LxGridViewCell"];
    
    self.widthArray = [NSMutableArray array];
    
    if (self.dataArray.count >= 1)
    {
        [self countCellWidth];
    }
    else
    {
        DDLog(@"没有数据计算高度");
    }
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
}

- (void)chilkButton:(UIButton *)btn
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.insertArray];
    
    if (self.grayInsertArray.count > 0)
    {
        for (NSString *string in self.grayInsertArray)
        {
            [array removeObject:string];
        }
    }
    
    if (array.count > 0)
    {
        self.doInsert = LabelArrayUpdating;
    }
    
    if (self.deleteArray.count > 0)
    {
        self.doDelete = LabelArrayUpdating;
    }
    
    if (array.count > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NetManager sharedInstance] postEditJobTags:array complete:^(BOOL success, id obj) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (success)
            {
                DDLog(@"添加成功");
                
                self.doInsert = LabelArrayUpdateFinish;
                
                for (NSString *string in array)
                {
                    [[YHUserInfoManager sharedInstance].userInfo.jobTags addObject:string];
                }
                
                [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"jobTags"] complete:^(BOOL success, id obj) {
                    
                }];
                
                if (self.doDelete == LabelArrayUpdateFinish || self.doDelete == LabelArrayNoObject)
                {
                    postTips(@"修改职业标签成功", nil);
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"jobTags"] complete:^(BOOL success, id obj) {
                        
                    }];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    
                    DISPATCH_MAIN_START
                    [ws.collectionView reloadData];
                    DISPATCH_END
                }
            }
            else
            {
                self.doInsert = LabelArrayUpdateFailure;
                
                if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable)
                {
                    postTips(obj, @"网络连接失败，请检查网络设置");
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"添加加职位标签失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"添加加职位标签失败");
                    }
                }
            }
        }];
    }
    
    if (self.deleteArray.count > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NetManager sharedInstance] deleteJobTags:self.deleteArray complete:^(BOOL success, id obj) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (success)
            {
                DDLog(@"删除成功");
                
                self.doDelete = LabelArrayUpdateFinish;
                
                for (NSString *string in self.deleteArray)
                {
                    [self.dataArray removeObject:string];
                    [[YHUserInfoManager sharedInstance].userInfo.jobTags removeObject:string];
                }
                
                if (self.doInsert == LabelArrayUpdateFinish || self.doInsert == LabelArrayNoObject)
                {
                    postTips(@"修改职业标签成功", nil);
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"jobTags"] complete:^(BOOL success, id obj) {
                        
                    }];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    
                    DISPATCH_MAIN_START
                    [ws.collectionView reloadData];
                    DISPATCH_END
                }
            }
            else
            {
                self.doDelete = LabelArrayUpdateFailure;
                
                if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable)
                {
                    postTips(obj, @"网络连接失败，请检查网络设置");
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"删除标签失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"删除标签失败");
                    }
                }
            }
        }];
    }
}

- (void)countCellWidth
{
    [self.widthArray removeAllObjects];
    
    for (NSString *string in self.dataArray)
    {
        if ([string isEqualToString:@"+"])
        {
            [self.widthArray addObject:[NSNumber numberWithFloat:30]];
            return;
        }
        
        CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
        
        CGFloat width = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14 + fontSize]} context:nil].size.width + 5;
        [self.widthArray addObject:[NSNumber numberWithFloat:width]];
    }
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LxGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LxGridViewCell" forIndexPath:indexPath];
    
    if (indexPath.item == self.dataArray.count - 1)
    {
        cell.addImage.hidden = NO;
    }
    else
    {
        cell.addImage.hidden = YES;
    }
    
    if (cell.didSelect == NO)
    {
        [cell selectOrNot];
    }
    cell.delegate = self;
    cell.editing = self.collectionView.editing;
    cell.title = self.dataArray[indexPath.item];
    
    for (NSString *string in self.deleteArray)
    {
        if ([self.dataArray[indexPath.item] isEqualToString:string])
        {
            [cell selectOrNot];
        }
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([self.widthArray[indexPath.item] floatValue], 30);
}

#pragma mark --UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDLog(@"%@%ld", indexPath, self.dataArray.count);
    
    if (indexPath.item == self.dataArray.count - 1)
    {
        //添加
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加标签" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
    else
    {
        //删除
        LxGridViewCell *cell = (LxGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell selectOrNot];
        
        
        if (cell.didSelect == NO)
        {
            if ([self.insertArray containsObject:cell.title])
            {
                [self.grayInsertArray addObject:cell.title];
                return;
            }
            [self.deleteArray addObject:self.dataArray[indexPath.item]];
        }
        else
        {
            if ([self.grayInsertArray containsObject:cell.title])
            {
                [self.grayInsertArray removeObject:cell.title];
                return;
            }
            [self.deleteArray removeObject:self.dataArray[indexPath.item]];
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0)
{
    if (buttonIndex == 1)
    {
        NSInteger count = self.dataArray.count;
        UITextField *nameTF = [alertView textFieldAtIndex:0];
        [nameTF resignFirstResponder];
        NSInteger length = nameTF.text.length;
        
        if (length > 10)
        {
            postTips(@"标签不能超过10个字", nil);
            return;
        }
        
        NSString *string = [nameTF.text substringWithRange:NSMakeRange(0, length)];
        
        for (NSString *labelString in self.dataArray)
        {
            if ([labelString isEqualToString:string])
            {
                postTips(@"此标签已存在,请录入新标签", nil);
                return;
            }
        }
        
        NSString *regex = @"[a-zA-Z0-9\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        if ([pred evaluateWithObject:string])
        {
            [self.insertArray addObject:string];
            [self.dataArray insertObject:string atIndex:count - 1];
            
            [self countCellWidth];
            
            DISPATCH_MAIN_START
            [ws.collectionView reloadData];
            DISPATCH_END
        }
        else
        {
            postTips(@"标签只能由汉字,英文和数字组成", nil);
        }
    }
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
