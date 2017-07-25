//
//  ListEditController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "ListEditController.h"
#import "MyListEditCell.h"
#import "MyTimeCell.h"
#import "MyTextViewCell.h"
#import "IQKeyboardManager.h"
#import "YHWorkExperienceModel.h"
#import "YHUserInfoManager.h"
#import "YHEducationExperienceModel.h"
#import "YHActionSheet.h"
#import "SingleEditController.h"
#import "YHNetManager.h"
#import "DeleteExperienceCell.h"
#import "UIView+Extension.h"
#import "IQTextView.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHSqliteManager.h"
#import "YHChatDevelop-Swift.h"

typedef enum : NSUInteger
{
    beginDate = 100,
    endDate,
} DateForExperience;

#define nWorkExperience 501
#define nEduExperience	502
#define kMaxLength 300

@interface ListEditController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YHEducationExperienceModel *eduModel;
@property (nonatomic, strong) YHWorkExperienceModel *workModel;
@property (nonatomic, strong) UIDatePicker *picker;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSData *selectDate;
@property (nonatomic, strong) IQTextView *textView;
@property (nonatomic, assign) DateForExperience date;
@property (nonatomic, strong) YHUserInfoManager *manager;
@property (nonatomic, assign) BOOL didChanged;

@property (nonatomic, strong) UIView *timeSelectView;

@property (nonatomic, strong) NSMutableArray *yearArray;
@property (nonatomic, strong) NSMutableArray *monthArray;

@property (nonatomic, strong) UIButton *timeBtn;

@end

@implementation ListEditController

- (void)viewDidLoad
{
    //    self.view.backgroundColor = [UIColor whiteColor];
    //    self.tableView.backgroundColor = [UIColor whiteColor];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    
    manager.shouldResignOnTouchOutside = NO;
    manager.enableAutoToolbar = NO;
    [manager setKeyboardDistanceFromTextField:0];
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.keyboardDistanceFromTextField = 0;
    [manager addTextFieldViewDidBeginEditingNotificationName:UITextViewTextDidBeginEditingNotification didEndEditingNotificationName:UITextViewTextDidEndEditingNotification];
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:Event_SingleVC_Value object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteExperience:) name:Event_Experience_Delete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountLabelWith:) name:UITextViewTextDidChangeNotification object:nil];
    
    
    self.didChanged = NO;
    self.manager = [YHUserInfoManager sharedInstance];
    self.eduModel = [[YHEducationExperienceModel alloc] init];
    self.workModel = [[YHWorkExperienceModel alloc] init];
    
    if (self.experience == EducationExperience && [YHUserInfoManager sharedInstance].userInfo.eductaionExperiences.count != 0 && self.indexPath.section != 1)
    {
        self.eduModel = [[YHUserInfoManager sharedInstance].userInfo.eductaionExperiences[self.indexPath.row] copy];
    }
    else if (self.experience == WorkExperience && [YHUserInfoManager sharedInstance].userInfo.workExperiences.count != 0 && self.indexPath.section != 1)
    {
        self.workModel = [[YHUserInfoManager sharedInstance].userInfo.workExperiences[self.indexPath.row] copy];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MyListEditCell class] forCellReuseIdentifier:@"MyListEditCell"];
    [self.tableView registerClass:[MyTimeCell class] forCellReuseIdentifier:@"MyTimeCell"];
    [self.tableView registerClass:[MyTextViewCell class] forCellReuseIdentifier:@"MyTextViewCell"];
    [self.tableView registerClass:[DeleteExperienceCell class] forCellReuseIdentifier:@"DeleteExperienceCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"保存" target:self selector:@selector(save:) ];
    
    self.picker = [[UIDatePicker alloc] init];
    self.picker.datePickerMode = UIDatePickerModeDate;
    self.picker.backgroundColor = [UIColor whiteColor];
    
    [self.picker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self.picker setCalendar:[NSCalendar currentCalendar]];
    [self.picker setTimeZone:[NSTimeZone localTimeZone]];
    //给定日期选择区间,如果转动的表盘日期出了区间，系统会自动归位
    //设置一个时间戳
    NSTimeInterval timeInterval = 40 * 60 * 60 * 24 * 365;
    
    NSDate *minDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-timeInterval];
    NSDate *maxDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    //设置最大，最小日期
    self.picker.minimumDate = minDate;
    self.picker.maximumDate = maxDate;
    [self.picker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    self.timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.timeBtn setTitle:@"确定选择日期" forState:UIControlStateNormal];
    self.timeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.timeBtn.titleLabel.textColor = [UIColor whiteColor];
    self.timeSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 240, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 240)];
    [self.view addSubview:self.timeSelectView];
    //	[self.timeSelectView addSubview:self.picker];
    self.timeSelectView.backgroundColor = [UIColor whiteColor];
    self.timeSelectView.hidden = YES;
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    [self.timeSelectView addSubview:self.pickerView];
    
    WeakSelf
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(weakSelf.timeSelectView);
        make.height.mas_equalTo(weakSelf.timeSelectView.height - 55);
    }];
    
    //	[self.picker mas_makeConstraints:^(MASConstraintMaker *make) {
    //		make.top.left.right.equalTo(ws.timeSelectView);
    //		make.height.mas_equalTo(ws.timeSelectView.height - 55);
    //	}];
    
    UIColor *color = kBlueColor;
    self.timeBtn.backgroundColor = color;
    self.timeBtn.layer.cornerRadius = 5;
    self.timeBtn.layer.masksToBounds = YES;
    [self.timeSelectView addSubview:self.timeBtn];
    [self.timeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.timeSelectView).offset(15);
        make.right.equalTo(weakSelf.timeSelectView).offset(-15);
        make.top.equalTo(weakSelf.pickerView.mas_bottom);
        make.bottom.equalTo(weakSelf.timeSelectView).offset(-15);
    }];
    
    [self.timeBtn addTarget:self action:@selector(confirmSelectTime:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
}

-(void)changeCountLabelWith:(NSNotification *)notif{
    
    IQTextView *textView = (IQTextView *)notif.object;
    
    NSString *toBeString = textView.text;
    NSString *lang = [[textView textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        if (!position) {
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
            
            NSInteger count = kMaxLength - textView.text.length;
            [[NSNotificationCenter defaultCenter] postNotificationName:Event_MyListEdit_Count object:[NSNumber numberWithInteger:count]];        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textView.text = [toBeString substringToIndex:kMaxLength];
        }
        NSInteger count = kMaxLength - textView.text.length;
        [[NSNotificationCenter defaultCenter] postNotificationName:Event_MyListEdit_Count object:[NSNumber numberWithInteger:count]];    }
}

- (void)confirmSelectTime:(id)sender
{
    self.timeSelectView.hidden = YES;
    
    if (self.experience == WorkExperience)
    {
        if (![self compareWithBeginDateString:self.workModel.beginTime andEndDateString:self.workModel.endTime])
        {
            self.workModel.endTime = self.workModel.beginTime;
        }
    }
    else
    {
        if (![self compareWithBeginDateString:self.eduModel.beginTime andEndDateString:self.eduModel.endTime])
        {
            self.eduModel.endTime = self.eduModel.beginTime;
        }
    }
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_SingleVC_Value object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Event_Experience_Delete object:nil];
    
}

#pragma mark notification

- (void)deleteExperience:(NSNotification *)sender
{
    Experience exp = [sender.object integerValue];
    
    if (exp == WorkExperience)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除工作经历" message:@"您确定要删除此工作经历?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = nWorkExperience;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除教育经历" message:@"您确定要删除此教育经历?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = nEduExperience;
        [alert show];
    }
}

- (void)changeValue:(NSNotification *)sender
{
    NSMutableArray *arr = sender.object;
    Experience exp = [arr[0] integerValue];
    NSString *value = arr[1];
    
    self.didChanged = YES;
    switch (exp)
    {
        case expSchool:
        {
            self.eduModel.school = value;
        }
            break;
            
        case expMajor:
        {
            self.eduModel.major = value;
        }
            break;
            
        case expCompany:
        {
            self.workModel.company = value;
        }
            break;
            
        case expPosition:
        {
            self.workModel.position = value;
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark button method 单例赋值
- (void)save:(UIButton *)btn
{
    BOOL experienceExisted = NO;
    
    if (![self check])
    {
        if (self.experience == WorkExperience)
        {
            postTips(@"请填写完整的工作经历", nil);
        }
        else
        {
            postTips(@"请填写完整的教育经历", nil);
        }
        
        return;
    }
    
    if (self.experience == WorkExperience)
    {
        if (self.indexPath.section == 0)
        {
            for (YHWorkExperienceModel *model in self.manager.userInfo.workExperiences)
            {
                if ([model.workExpId isEqualToString: self.workModel.workExpId])
                {
                    experienceExisted = YES;
                    
                    //如果有改动,那么发送请求
                    if (self.didChanged)
                    {
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [[NetManager sharedInstance] putUpdateWorkExperience:self.workModel complete:^(BOOL success, id obj) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            
                            if (success)
                            {
                                [self.manager.userInfo.workExperiences replaceObjectAtIndex:self.indexPath.row withObject:self.workModel];
                                
                                if (self.manager.userInfo.workExperiences.count > 1)
                                {
                                    [self sortArray:self.manager.userInfo.workExperiences];
                                }
                                postTips(@"修改工作经历成功", nil);
                                [self.navigationController popViewControllerAnimated:YES];
                                
                                [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"workExperiences"] complete:^(BOOL success, id obj) {
                                    
                                }];
                            }
                            else
                            {
                                if (isNSDictionaryClass(obj))
                                {
                                    //服务器返回的错误描述
                                    NSString *msg = obj[kRetMsg];
                                    
                                    postTips(msg, @"修改工作经历失败");
                                }
                                else
                                {
                                    //AFN请求失败的错误描述
                                    postTips(obj, @"修改工作经历失败");
                                }
                            }
                        }];
                    }
                    
                    break;
                }
            }
        }
        
        if (!experienceExisted)
        {
            //            for (YHWorkExperienceModel *model in [YHUserInfoManager sharedInstance].userInfo.eductaionExperiences) {
            //                if ([model.company isEqualToString:self.workModel.company]) {
            //
            //                    return;
            //                }
            //            }
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NetManager sharedInstance] postAddWorkExperience:self.workModel complete:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (success)
                {
                    NSString *workID = obj;
                    self.workModel.workExpId = workID;
                    [self.manager.userInfo.workExperiences addObject:self.workModel];
                    
                    if (self.manager.userInfo.workExperiences.count > 1)
                    {
                        [self sortArray:self.manager.userInfo.workExperiences];
                    }
                    
                    postTips(@"添加工作经历成功", nil);
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"workExperiences"] complete:^(BOOL success, id obj) {
                        
                    }];
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"添加新工作经历失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"增加新工作经历失败");
                    }
                }
            }];
        }
    }
    else
    {
        if (self.indexPath.section == 0)
        {
            for (YHEducationExperienceModel *model in self.manager.userInfo.eductaionExperiences)
            {
                if ([model.eduExpId isEqualToString: self.eduModel.eduExpId])
                {
                    experienceExisted = YES;
                    
                    //如果有改动,那么发送请求
                    if (self.didChanged)
                    {
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        [[NetManager sharedInstance] putUpdateEducationExperience:self.eduModel complete:^(BOOL success, id obj) {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            
                            if (success)
                            {
                                [self.manager.userInfo.eductaionExperiences replaceObjectAtIndex:self.indexPath.row withObject:self.eduModel];
                                
                                if (self.manager.userInfo.eductaionExperiences.count > 1)
                                {
                                    [self sortArray:self.manager.userInfo.eductaionExperiences];
                                }
                                postTips(@"修改教育经历成功", nil);
                                
                                [self.navigationController popViewControllerAnimated:YES];
                                
                                [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"eductaionExperiences"] complete:^(BOOL success, id obj) {
                                    
                                }];
                            }
                            else
                            {
                                if (isNSDictionaryClass(obj))
                                {
                                    //服务器返回的错误描述
                                    NSString *msg = obj[kRetMsg];
                                    
                                    postTips(msg, @"修改教育经历失败");
                                }
                                else
                                {
                                    //AFN请求失败的错误描述
                                    postTips(obj, @"修改教育经历失败");
                                }
                            }
                        }];
                    }
                    break;
                }
            }
        }
        
        if (!experienceExisted)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NetManager sharedInstance] postAddEducationExperience:self.eduModel complete:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (success)
                {
                    NSString *eduID = obj;
                    self.eduModel.eduExpId = eduID;
                    [self.manager.userInfo.eductaionExperiences addObject:self.eduModel];
                    
                    if (self.manager.userInfo.eductaionExperiences.count > 1)
                    {
                        [self sortArray:self.manager.userInfo.eductaionExperiences];
                    }
                    postTips(@"添加教育经历成功", nil);
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"eductaionExperiences"] complete:^(BOOL success, id obj) {
                        
                    }];
                    
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"添加新教育经历失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"添加新教育经历失败");
                    }
                }
            }];
        }
    }
    //在这里改动单例的数据
}

#pragma mark 检查是否有没填的
- (BOOL)check
{
    if (self.experience == WorkExperience)
    {
        if (self.workModel.company.length == 0 || self.workModel.position.length == 0 || self.workModel.beginTime.length == 0 || self.workModel.endTime.length == 0)
        {
            return NO;
        }
    }
    else
    {
        if (self.eduModel.school.length == 0 || self.eduModel.major.length == 0 || self.eduModel.beginTime.length == 0 || self.eduModel.endTime.length == 0 || self.eduModel.educationBackground.length == 0)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark 数组排序
- (void)sortArray:(NSMutableArray *)array
{
    [array sortUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
        if (self.experience == WorkExperience)
        {
            YHWorkExperienceModel *model1 = obj1;
            YHWorkExperienceModel *model2 = obj2;
            
            if ([model1.endTime isEqualToString:@"至今"] && [model2.endTime isEqualToString:@"至今"])
            {
                if ([self compareWithBeginDateString:model1.beginTime andEndDateString:model2.beginTime])
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedAscending;
                }
            }
            
            if ([model1.endTime isEqualToString:@"至今"])
            {
                return NSOrderedAscending;
            }
            
            if ([model2.endTime isEqualToString:@"至今"])
            {
                return NSOrderedDescending;
            }
            
            if ([self compareWithBeginDateString:model1.endTime andEndDateString:model2.endTime])
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
        }
        else
        {
            YHEducationExperienceModel *model1 = obj1;
            YHEducationExperienceModel *model2 = obj2;
            
            if ([model1.endTime isEqualToString:@"至今"] && [model2.endTime isEqualToString:@"至今"])
            {
                if ([self compareWithBeginDateString:model1.beginTime andEndDateString:model2.beginTime])
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedAscending;
                }
            }
            
            if ([model1.endTime isEqualToString:@"至今"])
            {
                return NSOrderedAscending;
            }
            
            if ([model2.endTime isEqualToString:@"至今"])
            {
                return NSOrderedDescending;
            }
            
            if ([self compareWithBeginDateString:model1.endTime andEndDateString:model2.endTime])
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
        }
    }];
}

#pragma mark picker事件回调方法
- (void)dateChange:(UIDatePicker *)sender
{
    //取出日期
    NSDate *select = sender.date;
    
    [self showDate:select];
}

/**
 *  对比时间
 *
 *  @param beginDateString 前一个时间
 *  @param endDateString   后一个时间
 *
 *  @return 要交换位置返回YES, 不用交换位置返回NO
 */
- (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString
{
    if ([endDateString isEqualToString:@"至今"])
    {
        return YES;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *beginDate = [dateFormatter dateFromString:beginDateString];
    NSDate *endDate = [dateFormatter dateFromString:endDateString];
    NSComparisonResult result = [beginDate compare:endDate];
    
    if (result == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

- (void)showDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *dateString;
    
    if (date)
    {
        dateString = [dateFormatter stringFromDate:date];
    }
    else
    {
        dateString = @"至今";
    }
    
    if (self.experience == WorkExperience)
    {
        if (self.date == beginDate)
        {
            if (![self.workModel.beginTime isEqualToString:dateString])
            {
                self.workModel.beginTime = dateString;
                self.didChanged = YES;
            }
        }
        else
        {
            //开始时间不为空
            if (![self.workModel.beginTime isEqualToString:@""])
            {
                //对比开始时间和结束时间,结束时间比开始时间靠后才能赋值
                if ([dateString isEqualToString:@"至今"] && ![self.workModel.endTime isEqualToString:dateString])
                {
                    self.workModel.endTime = dateString;
                    self.didChanged = YES;
                    [self.tableView reloadData];
                    return;
                }
                
                if ([self compareWithBeginDateString:self.workModel.beginTime andEndDateString:dateString])
                {
                    if (![self.workModel.endTime isEqualToString:dateString])
                    {
                        self.workModel.endTime = dateString;
                        self.didChanged = YES;
                    }
                }
            }
        }
    }
    else
    {
        if (self.date == beginDate)
        {
            if (![self.eduModel.beginTime isEqualToString:dateString])
            {
                self.eduModel.beginTime = dateString;
                self.didChanged = YES;
            }
        }
        else
        {
            if (![self.eduModel.beginTime isEqualToString:@""])
            {
                if ([dateString isEqualToString:@"至今"] && ![self.eduModel.endTime isEqualToString:dateString])
                {
                    self.eduModel.endTime = dateString;
                    self.didChanged = YES;
                    [self.tableView reloadData];
                    return;
                }
                
                if ([self compareWithBeginDateString:self.eduModel.beginTime andEndDateString:dateString])
                {
                    if (![self.eduModel.endTime isEqualToString:dateString])
                    {
                        self.eduModel.endTime = dateString;
                        self.didChanged = YES;
                    }
                }
            }
        }
    }
    
    [self.tableView reloadData];
    
    //    DDLog(@"选择的日期%@", self.selectDate);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate & dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 0)
    {
        return 3;
    }
    
    //    if (section != 0 && self.indexPath.section == 1) {
    //        return 2;
    //    }
    
    if (self.experience == WorkExperience)
    {
        return 4;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    DDLog(@"%@",indexPath);
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        return 225;
    }
    else if (indexPath.section == 1 && indexPath.row == 2)
    {
        return 60;
    }
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 15;
    }
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *eduArray = @[@"学校", @"专业", @"学历"];
    NSArray *workArray = @[@"公司", @"职位"];
    
    if (indexPath.section == 0)
    {
        switch (self.experience)
        {
            case EducationExperience:
            {
                if (indexPath.row < 3)
                {
                    MyListEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListEditCell" forIndexPath:indexPath];
                    
                    cell.title.text = eduArray[indexPath.row];
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            cell.detail.text = self.eduModel.school.length > 0 ? self.eduModel.school : @"请填写学校";
                        }
                            break;
                            
                        case 1:
                        {
                            cell.detail.text = self.eduModel.major.length > 0 ? self.eduModel.major : @"请填写专业";
                        }
                            break;
                            
                        case 2:
                        {
                            cell.detail.text = self.eduModel.educationBackground.length > 0 ? self.eduModel.educationBackground : @"请填写学历";
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    return cell;
                }
                else
                {
                    MyTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTimeCell" forIndexPath:indexPath];
                    
                    if (indexPath.row == 3)
                    {
                        cell.downline.image = [UIImage imageNamed:@"mybeginline"];
                        cell.title.text = @"开始时间";
                        
                        cell.detail.text = self.eduModel.beginTime.length > 0 ? self.eduModel.beginTime : @"请完善入学时间";
                    }
                    else
                    {
                        cell.upline.image = [UIImage imageNamed:@"myendline"];
                        cell.title.text = @"结束时间";
                        
                        cell.detail.text = self.eduModel.endTime.length > 0 ? self.eduModel.endTime : @"请完善毕业时间";
                    }
                    return cell;
                }
            }
                break;
                
            case WorkExperience:
            {
                if (indexPath.row < 2)
                {
                    MyListEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListEditCell" forIndexPath:indexPath];
                    
                    cell.title.text = workArray[indexPath.row];
                    
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            cell.detail.text = self.workModel.company.length > 0 ? self.workModel.company : @"请填写公司";
                        }
                            break;
                            
                        case 1:
                        {
                            cell.detail.text = self.workModel.position.length > 0 ? self.workModel.position : @"请填写职位";
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    return cell;
                }
                else
                {
                    MyTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTimeCell" forIndexPath:indexPath];
                    
                    if (indexPath.row == 2)
                    {
                        cell.downline.image = [UIImage imageNamed:@"mybeginline"];
                        cell.title.text = @"开始时间";
                        
                        cell.detail.text = self.workModel.beginTime.length > 0 ? self.workModel.beginTime : @"请完善就职时间";
                    }
                    else
                    {
                        cell.upline.image = [UIImage imageNamed:@"myendline"];
                        cell.title.text = @"结束时间";
                        
                        cell.detail.text = self.workModel.endTime.length > 0 ? self.workModel.endTime : @"请完善离职时间";
                    }
                    return cell;
                }
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            MyListEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyListEditCell" forIndexPath:indexPath];
            
            cell.arrow.hidden = YES;
            cell.title.text = @"更多描述";
            return cell;
        }
        else if (indexPath.row == 1)
        {
            MyTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTextViewCell" forIndexPath:indexPath];
            self.textView = cell.textView;
            
            if (self.experience == EducationExperience)
            {
                cell.textView.placeholder = @"教育经历描述,不超过300字";
                cell.textView.text = self.eduModel.moreDescription;
            }
            else
            {
                cell.textView.placeholder = @"工作经历描述,不超过300字";
                
                cell.textView.text = self.workModel.moreDescription;
            }
            
            cell.textView.delegate = self;
            return cell;
        }
        else
        {
            DeleteExperienceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteExperienceCell" forIndexPath:indexPath];
            
            if (self.experience == EducationExperience)
            {
                [cell.deleteBtn setTitle:@"删除教育经历" forState:UIControlStateNormal];
                cell.experience = EducationExperience;
            }
            else
            {
                [cell.deleteBtn setTitle:@"删除工作经历" forState:UIControlStateNormal];
                cell.experience = WorkExperience;
            }
            
            if (self.indexPath.section == 1)
            {
                [cell clickDisable];
            }
            else
            {
                [cell clickAble];
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //	[dateFormatter setDateFormat:@"yyyy-MM"];
    //	NSDate *date;
    
    if (self.experience == EducationExperience && indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                SingleEditController *editVC = [[SingleEditController alloc] init];
                editVC.placeholder = @"学校不能超过20个字";
                editVC.experience = expSchool;
                editVC.String = self.eduModel.school;
                editVC.title = @"学校";
                [self.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            case 1:
            {
                SingleEditController *editVC = [[SingleEditController alloc] init];
                editVC.placeholder = @"专业不能超过20个字";
                editVC.experience = expMajor;
                editVC.String = self.eduModel.major;
                editVC.title = @"专业";
                [self.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            case 2:
            {
                NSArray *arr = @[@"大专", @"本科", @"硕士", @"博士", @"其他"];
                YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:arr];
                
                [sheet show];
                [sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
                    if (!isCancel)
                    {
                        if (![self.eduModel.educationBackground isEqualToString:arr[clickedIndex]])
                        {
                            self.eduModel.educationBackground = arr[clickedIndex];
                            self.didChanged = YES;
                        }
                    }
                    [self.tableView reloadData];
                }];
            }
                break;
                
            case 3:
            {
                if ([self.yearArray containsObject:@"至今"])
                {
                    [self.yearArray removeObject:@"至今"];
                }
                [self.pickerView reloadAllComponents];
                self.timeSelectView.hidden = NO;
                self.date = beginDate;
                
                if (self.eduModel.beginTime.length != 0)
                {
                    //显示pickView时把日期滚到原来选择好的时间
                    [self LEC_PickViewRollToDidSelectTime:self.eduModel.beginTime];
                }
            }
                break;
                
            case 4:
            {
                if (![self.yearArray containsObject:@"至今"])
                {
                    [self.yearArray insertObject:@"至今" atIndex:0];
                }
                [self.pickerView reloadAllComponents];
                
                self.timeSelectView.hidden = NO;
                self.date = endDate;
                
                if (self.eduModel.endTime.length != 0)
                {
                    [self LEC_PickViewRollToDidSelectTime:self.eduModel.endTime];
                }
            }
                break;
                
            default:
                break;
        }
    }
    else if (self.experience == WorkExperience && indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                SingleEditController *editVC = [[SingleEditController alloc] init];
                editVC.placeholder = @"公司不能超过20个字";
                editVC.title = @"公司";
                editVC.experience = expCompany;
                editVC.String = self.workModel.company;
                
                [self.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            case 1:
            {
                SingleEditController *editVC = [[SingleEditController alloc] init];
                editVC.placeholder = @"职位不能超过20个字";
                editVC.experience = expPosition;
                editVC.String = self.workModel.position;
                editVC.title = @"职位";
                
                [self.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
            case 2:
            {
                if ([self.yearArray containsObject:@"至今"])
                {
                    [self.yearArray removeObject:@"至今"];
                }
                [self.pickerView reloadAllComponents];
                
                self.timeSelectView.hidden = NO;
                self.date = beginDate;
                
                if (self.workModel.beginTime.length != 0)
                {
                    [self LEC_PickViewRollToDidSelectTime:self.workModel.beginTime];
                }
            }
                break;
                
            case 3:
            {
                if (![self.yearArray containsObject:@"至今"])
                {
                    [self.yearArray insertObject:@"至今" atIndex:0];
                }
                [self.pickerView reloadAllComponents];
                
                self.timeSelectView.hidden = NO;
                self.date = endDate;
                
                if (self.workModel.endTime.length != 0)
                {
                    [self LEC_PickViewRollToDidSelectTime:self.workModel.endTime];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)LEC_PickViewRollToDidSelectTime:(NSString *)dateString
{
    if ([dateString isEqualToString:@"至今"])
    {
        if ([self.yearArray indexOfObject:dateString])
        {
            NSInteger yearRow = [self.yearArray indexOfObject:dateString];
            [self.pickerView selectRow:yearRow inComponent:0 animated:YES];
            [self.pickerView selectRow:0 inComponent:1 animated:YES];
        }
        return;
    }
    
    NSArray *arr = [dateString componentsSeparatedByString:@"-"];
    NSInteger yearRow = [self.yearArray indexOfObject:arr[0]];
    NSInteger monthRow = [self.monthArray indexOfObject:arr[1]];
    
    [self.pickerView selectRow:yearRow inComponent:0 animated:YES];
    [self.pickerView selectRow:monthRow inComponent:1 animated:YES];
}

#pragma mark pickView delegate & dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.yearArray.count;
    }
    else
    {
        return self.monthArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.yearArray[row];
    }
    else
    {
        return self.monthArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    DDLog(@"%ld,%ld", row, component);
    NSString *year = @"";
    NSString *month = @"";
    
    if (component == 0 && row == 0)
    {
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    
    if (component == 0 && row != 0) {
        [pickerView selectRow:1 inComponent:1 animated:YES];
    }
    
    switch (component)
    {
        case 0:
        {
            year = self.yearArray[row];
            month = self.monthArray[[self.pickerView selectedRowInComponent:1]];
        }
            break;
            
        case 1:
        {
            year = self.yearArray[[self.pickerView selectedRowInComponent:0]];
            month = self.monthArray[row];
        }
            break;
            
        default:
            break;
    }
    
    if ([year isEqualToString:@"至今"])
    {
        //		month = @"";
        [self showDate:nil];
        return;
    }else{
        if (month.length == 0) {
            month = self.monthArray[[self.pickerView selectedRowInComponent:1]];
        }
    }
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%@", year, month];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    [self showDate:date];
}

- (NSMutableArray *)yearArray
{
    if (!_yearArray)
    {
        _yearArray = [NSMutableArray array];
        
        for (int i = 0; i < 30; i++)
        {
            NSInteger year = 2016 - i;
            NSString *yearString = [NSString stringWithFormat:@"%ld", (long)year];
            [_yearArray addObject:yearString];
        }
    }
    return _yearArray;
}

- (NSMutableArray *)monthArray
{
    if (!_monthArray)
    {
        _monthArray = [NSMutableArray array];
        [_monthArray addObject:@""];
        
        for (int i = 0; i < 12; i++)
        {
            NSInteger month = 12 - i;
            NSString *monthString = [NSString stringWithFormat:@"%02ld", (long)month];
            [_monthArray addObject:monthString];
        }
    }
    return _monthArray;
}

#pragma mark textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return self.timeSelectView.hidden;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.picker.hidden = YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{}

-(void)textViewDidChange:(UITextView *)textView
{
    if (self.experience == WorkExperience)
    {
        if (![self.workModel.moreDescription isEqualToString:self.textView.text])
        {
            self.didChanged = YES;
        }
        
        self.workModel.moreDescription = self.textView.text;
    }
    else
    {
        if (![self.eduModel.moreDescription isEqualToString:self.textView.text])
        {
            self.didChanged = YES;
        }
        self.eduModel.moreDescription = self.textView.text;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    NSString *result;
    
    if (textView.text.length >= range.length)
    {
        result = [textView.text stringByReplacingCharactersInRange:range withString:text];
    }
    
    if (result.length > kMaxLength)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark alertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == nWorkExperience)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[NetManager sharedInstance] deleteWorkExperience:self.workModel complete:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (success)
                {
                    [self.manager.userInfo.workExperiences removeObjectAtIndex:self.indexPath.row];
                    postTips(@"删除工作经历成功", nil);
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"workExperiences"] complete:^(BOOL success, id obj) {
                        
                    }];
                    
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"删除工作经历失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"删除工作经历失败");
                    }
                }
            }];
            return;
        }
        
        if (alertView.tag == nEduExperience)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[NetManager sharedInstance] deleteEducationExperience:self.eduModel complete:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (success)
                {
                    [self.manager.userInfo.eductaionExperiences removeObjectAtIndex:self.indexPath.row];
                    postTips(@"删除教育经历成功", nil);
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"eductaionExperiences"] complete:^(BOOL success, id obj) {
                        
                    }];
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"删除教育经历失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"删除教育经历失败");
                    }
                }
            }];
        }
    }
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
