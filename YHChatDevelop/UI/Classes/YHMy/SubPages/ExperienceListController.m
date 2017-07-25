//
//  EducationExperienceController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "ExperienceListController.h"
#import "MyExperienceListCell.h"
#import "ListEditController.h"
#import "YHUserInfoManager.h"
#import "YHEducationExperienceModel.h"
#import "YHWorkExperienceModel.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

@interface ExperienceListController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) YHUserInfoManager *manager;
@end

@implementation ExperienceListController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.manager = [YHUserInfoManager sharedInstance];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	[self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.tableView registerClass:[MyExperienceListCell class] forCellReuseIdentifier:@"ListCell"];
	self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    self.tableView.rowHeight = 45;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    

    
//	UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//	editBtn.frame = CGRectMake(0, 0, 40, 40);
//	[editBtn setTitle:@"删除" forState:UIControlStateNormal];
//	editBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//	editBtn.titleLabel.textColor = [UIColor whiteColor];
//	[editBtn addTarget:self action:@selector(editList:) forControlEvents:UIControlEventTouchUpInside];
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//进入编辑模式
//- (void)editList:(id)sender
//{
//	if (self.tableView.editing)
//	{
//		[self.tableView setEditing:NO animated:YES];
//	}
//	else
//	{
//		[self.tableView setEditing:YES animated:YES];
//	}
//}

- (NSMutableArray *)dataArray
{
	if (self.experience == EducationExperience)
	{
		_dataArray = self.manager.userInfo.eductaionExperiences;
	}
	else
	{
		_dataArray = self.manager.userInfo.workExperiences;
	}
//    [self sortArray:_dataArray];

	return _dataArray;
}

//#pragma mark 数组排序
//- (void)sortArray:(NSMutableArray *)array
//{
//    [array sortUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
//        if (self.experience == WorkExperience)
//        {
//            YHWorkExperienceModel *model1 = obj1;
//            YHWorkExperienceModel *model2 = obj2;
//
//            if ([self compareWithBeginDateString:model1.endTime andEndDateString:model2.endTime])
//            {
//                return NSOrderedDescending;
//            }
//            else
//            {
//                return NSOrderedAscending;
//            }
//        }
//        else
//        {
//            YHEducationExperienceModel *model1 = obj1;
//            YHEducationExperienceModel *model2 = obj2;
//
//            if ([self compareWithBeginDateString:model1.endTime andEndDateString:model2.endTime])
//            {
//                return NSOrderedDescending;
//            }
//            else
//            {
//                return NSOrderedAscending;
//            }
//        }
//    }];
//}
//
//- (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    [dateFormatter setDateFormat:@"yyyy-MM"];
//    NSDate *beginDate = [dateFormatter dateFromString:beginDateString];
//    NSDate *endDate = [dateFormatter dateFromString:endDateString];
//    NSComparisonResult result = [beginDate compare:endDate];
//
//    if (result == NSOrderedAscending)
//    {
//        return YES;
//    }
//    return NO;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.dataArray.count == 0)
	{
		return 2;
	}
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.dataArray.count == 0)
	{
		if (section == 1)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		if (section == 1)
		{
			return 1;
		}
		else
		{
			return self.dataArray.count;
		}
	}
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataArray.count > 0) {
        return 15;
    }else{
        if (section == 0) {
            return 0.00001;
        }else{
            return 15;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] init];

	view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyExperienceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];

	//section 2
	if (self.dataArray.count == 0 || indexPath.section == 1)
	{
		cell.imageV.image = [UIImage imageNamed:@"myeditadd"];

		if (self.experience == EducationExperience)
		{
			cell.name.text = @"添加教育经历";
			cell.time.text = @"";
		}
		else
		{
			cell.name.text = @"添加工作经历";
			cell.time.text = @"";
		}
	}
	else
	{
		cell.imageV.image = [UIImage imageNamed:@"myeditpencil"];

		if (self.experience == EducationExperience)
		{
			YHEducationExperienceModel *model = self.dataArray[indexPath.row];
			cell.name.text = model.school;
			cell.time.text = [NSString stringWithFormat:@"%@ - %@", model.beginTime, model.endTime];
		}
		else
		{
			YHWorkExperienceModel *model = self.dataArray[indexPath.row];
			cell.name.text = model.company;
			cell.time.text = [NSString stringWithFormat:@"%@ - %@", model.beginTime, model.endTime];
		}
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ListEditController *editVC = [[ListEditController alloc] init];
	MyExperienceListCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	switch (self.experience)
	{
		case WorkExperience:

			if ([cell.name.text isEqualToString:@"添加工作经历"])
			{
				editVC.title = cell.name.text;
			}
			else
			{
				editVC.title = cell.name.text;
			}
			break;

		case EducationExperience:

			if ([cell.name.text isEqualToString:@"添加教育经历"])
			{
				editVC.title = cell.name.text;
			}
			else
			{
				editVC.title = cell.name.text;
			}
			break;

		default:
			break;
	}
	editVC.indexPath = indexPath;
//	DDLog(@"%ld", (long)indexPath.section);
	editVC.experience = self.experience;
	[self.navigationController pushViewController:editVC animated:YES];
}

- (void)dealloc
{
//    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
