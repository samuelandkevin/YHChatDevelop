//
//  MyDetailEditViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "MyDetailEditViewController.h"
#import "MyDetailEditCell.h"
#import "SingleEditController.h"
#import "YHActionSheet.h"
#import "YHRegisterChooseJobFunctionViewController.h"
#import "IntroduceEditController.h"
#import "ExperienceListController.h"
#import "MyMapController.h"
#import "MBProgressHUD.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "LabelController.h"
#import "YHUserInfoManager.h"
#import "UIImage+Extension.h"
#import "YHEducationExperienceModel.h"
#import "YHWorkExperienceModel.h"
#import "YHNetManager.h"
#import "YHUICommon.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CityListController.h"
#import <Photos/Photos.h>
#import "YHChatDevelop-Swift.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "TZImageManager.h"


#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
@interface MyDetailEditViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YHUserInfoManager *manager;

@end

@implementation MyDetailEditViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	if ([YHUserInfoManager sharedInstance].userInfo == nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:Event_UserInfo_UpdateFinish object:nil];
	}

	self.title = @"编辑资料";
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];

	[self.view addSubview:self.tableView];
	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
	}];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
	[self.tableView registerClass:[MyDetailEditCell class] forCellReuseIdentifier:@"MyDetailEditCell"];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
}

- (void)dealloc
{
	DDLog(@"%@ did dealloc", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:Event_UserInfo_UpdateFinish object:nil];
}

#pragma mark notification
- (void)reloadView:(NSNotification *)sender
{
	if ([YHUserInfoManager sharedInstance].userInfo == nil)
	{
		return;
	}
	[self.tableView reloadData];
}

#pragma mark 数组排序
- (void)sortArray:(NSMutableArray *)array withExperience:(MyExperience)exp
{
    [array sortUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
        if (exp == WorkExperience)
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
    }];}

- (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString
{
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

#pragma mark tableView delegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 1;
	}
	else
	{
		return 12;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 15;
	}
	else
	{
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		return 89;
	}
	else
	{
		return 45;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *title = @[@"姓名", @"性别", @"工作城市", @"工作地点", @"行业职能", @"公司",@"部门", @"职位", @"职业标签", @"个人简介", @"教育经历", @"工作经历"];

	static NSString *identifier = @"MyDetailEditCell";
	MyDetailEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if (indexPath.section == 0)
	{
		cell.title.text = @"形象照片";
		cell.avatar.hidden = NO;

		if ([YHUserInfoManager sharedInstance].userInfo.avatarUrl != nil)
		{
            cell.avatar.image = [UIImage imageNamed:@"common_avatar_80px"];
			[cell.avatar sd_setImageWithURL:[YHUserInfoManager sharedInstance].userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed | SDWebImageDelayPlaceholder | SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
				if (error == nil)
				{}
				else
				{
					DDLog(@"%@", error.description);
				}
			}];
		}
		cell.detail.hidden = YES;
	}
	else
	{
		cell.title.text = title[indexPath.row];
		cell.avatar.hidden = YES;
        cell.detail.hidden = NO;
		switch (indexPath.row)
		{
			case 0:
			{
				//姓名
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.userName;
			}
			break;

			case 1:
			{
				//性别
				if ([YHUserInfoManager sharedInstance].userInfo.sex == Gender_Man)
				{
					cell.detail.text = @"男";
				}
				else if ([YHUserInfoManager sharedInstance].userInfo.sex == Gender_Women)
				{
					cell.detail.text = @"女";
				}
				else
				{
					cell.detail.text = @"";
				}
			}
			break;

			case 2:
			{
				//工作城市
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.workCity;
			}
			break;

			case 3:
			{
				//工作地点
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.workLocation;
			}
			break;

			case 4:
			{
				//行业职能
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.industry;
			}
			break;

			case 5:
			{
				//公司
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.company;
			}
			break;

            case 6:{
                //部门
                cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.department;
            }
                break;
                
			case 7:
			{
				//职位
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.job;
			}
			break;

			case 8:
			{
				//职业标签
				NSString *jobTags = [[YHUserInfoManager sharedInstance].userInfo.jobTags componentsJoinedByString:@" , "];
				cell.detail.text = jobTags;
			}
			break;

			case 9:
			{
				//个人简介
				cell.detail.text = [YHUserInfoManager sharedInstance].userInfo.intro;
			}
			break;

			case 10:
			{
				//教育经历
				if ([YHUserInfoManager sharedInstance].userInfo.eductaionExperiences.count > 0)
				{
					if ([YHUserInfoManager sharedInstance].userInfo.eductaionExperiences.count > 1)
					{
						[self sortArray:[YHUserInfoManager sharedInstance].userInfo.eductaionExperiences withExperience:EducationExperience];
					}

					YHEducationExperienceModel *model = [YHUserInfoManager sharedInstance].userInfo.eductaionExperiences[0];

					if ([YHUserInfoManager sharedInstance].userInfo.eductaionExperiences.count == 1)
					{
						cell.detail.text = [NSString stringWithFormat:@"%@", model.school];
					}
					else
					{
						cell.detail.text = [NSString stringWithFormat:@"%@等%ld所学校", model.school, [YHUserInfoManager sharedInstance].userInfo.eductaionExperiences.count];
					}
				}
				else
				{
					cell.detail.text = @"请添加教育经历";
				}
			}
			break;

			case 11:
			{
				//工作经历
				if ([YHUserInfoManager sharedInstance].userInfo.workExperiences.count > 0)
				{
					if ([YHUserInfoManager sharedInstance].userInfo.workExperiences.count > 1)
					{
						[self sortArray:[YHUserInfoManager sharedInstance].userInfo.workExperiences withExperience:WorkExperience];
					}

					YHWorkExperienceModel *model = [YHUserInfoManager sharedInstance].userInfo.workExperiences[0];

					if ([YHUserInfoManager sharedInstance].userInfo.workExperiences.count == 1)
					{
						cell.detail.text = [NSString stringWithFormat:@"%@", model.company];
					}
					else
					{
						cell.detail.text = [NSString stringWithFormat:@"%@等%ld家公司", model.company, [YHUserInfoManager sharedInstance].userInfo.workExperiences.count];
					}
				}
				else
				{
					cell.detail.text = @"请添加工作经历";
				}
			}
			break;
                
           
                
			default:
				break;
		}
	}

	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] init];

	view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:@[@"拍照", @"从手机相册选取"]];
		[sheet show];
		[sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
			if (!isCancel)
			{
				UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
				imagePickerVC.delegate = self;
				imagePickerVC.allowsEditing = YES;
				UIColor *color = kBlueColor;
				imagePickerVC.navigationBar.barTintColor = color;

				NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:18]};
				imagePickerVC.navigationBar.titleTextAttributes = attributes;

				if (clickedIndex == 0)
				{
					[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
						if (granted)
						{
							imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
							[self presentViewController:imagePickerVC animated:YES completion:nil];
							DDLog(@"=====用户允许使用相机=====");
						}
						else
						{
							DDLog(@"=====用户不允许使用相机=====");
							postTips(@"税道APP没有权限访问您的相机,请在设置中开启税道访问相机的权限", nil);
						}
					}];
				}
				else if (clickedIndex == 1)
				{
                    if ([[TZImageManager manager] authorizationStatusAuthorized])
                    {
                        TZImagePickerController * imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
                        imagePickerVC.allowPickingVideo = NO;
                        
                        [self presentViewController:imagePickerVC animated:YES completion:nil];
                    }
                    else
                    {
                        if (iOS8Later)
                        {
                            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
                            {
                                return;
                            }
                        }
                        else
                        {
                            if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined)
                            {
                                return;
                            }
                        }
                        postTips(@"税道APP没有权限访问您的相册,请在设置中开启税道访问相册的权限", nil);
                    }
				}
			}
		}];
	}
	else
	{
		switch (indexPath.row)
		{
			case 0:
			{
				SingleEditController *editVC = [[SingleEditController alloc] init];
				editVC.placeholder = @"姓名不能超过20个字";
				editVC.title = @"姓名";
				editVC.String = [YHUserInfoManager sharedInstance].userInfo.userName;
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 1:
			{
				YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:@[@"男", @"女"]];
				[sheet show];
				[sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
					if (!isCancel)
					{
						[MBProgressHUD showHUDAddedTo:self.view animated:YES];
						YHUserInfo *userInfo = [[YHUserInfo alloc] init];

						if (clickedIndex == 0)
						{
				            //修改userinfo数据
							userInfo.sex = Gender_Man;
						}
						else if (clickedIndex == 1)
						{
				            //修改userinfo数据
							userInfo.sex = Gender_Women;
						}
						[[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
							[MBProgressHUD hideHUDForView:self.view animated:YES];

							if (success)

							{
								postTips(@"保存成功", nil);
								[YHUserInfoManager sharedInstance].userInfo.sex = userInfo.sex;
								[self.tableView reloadData];
							}
							else
							{
								if (isNSDictionaryClass(obj))
								{
				                    //服务器返回的错误描述
									NSString *msg = obj[kRetMsg];

									postTips(msg, @"修改性别失败");
								}
								else
								{
				                    //AFN请求失败的错误描述
									postTips(obj, @"修改性别失败");
								}
							}
						}];
					}
				}];
			}
			break;

			case 2:
			{
				CityListController *editVC = [[CityListController alloc] init];

				editVC.title = @"城市选择";

				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 3:
			{
//                MapViewController *mapVC = [[MapViewController alloc]init];
				MyMapController *mapVC = [[MyMapController alloc] init];
//                mapVC.fd_interactivePopDisabled = YES;
				[self.navigationController pushViewController:mapVC animated:YES];
			}
			break;

			case 4:
			{
				YHRegisterChooseJobFunctionViewController *vc = [[YHRegisterChooseJobFunctionViewController alloc] initWithSelectedJobBlock:^(NSString *jobType, NSString *jobDetail) {
//					DDLog(@"%@,%@", jobType, jobDetail);
//                    YHUserInfo *userInfo = [[YHUserInfo alloc]init];
//                    userInfo.
				}];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;

			case 5:
			{
				SingleEditController *editVC = [[SingleEditController alloc] init];
				editVC.placeholder = @"公司名称不能超过20个字";
				editVC.title = @"公司";
				editVC.String = [YHUserInfoManager sharedInstance].userInfo.company;
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

            case 6:
            {
                
                SingleEditController *editVC = [[SingleEditController alloc] init];
                editVC.placeholder = @"部门不能超过20个字";
                editVC.title = @"部门";
                editVC.String = [YHUserInfoManager sharedInstance].userInfo.department;
                [self.navigationController pushViewController:editVC animated:YES];
            }
                break;
                
			case 7:
			{
				JobSelectController *editVC = [[JobSelectController alloc] init];
//				editVC.placeholder = @"职位名称不能超过20个字";
				editVC.title = @"职位";
                editVC.jobString = [YHUserInfoManager sharedInstance].userInfo.job;
//				editVC.String = [YHUserInfoManager sharedInstance].userInfo.job;
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 8:
			{
				LabelController *editVC = [[LabelController alloc] init];
				editVC.title = @"职业标签";
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 9:
			{
				IntroduceEditController *editVC = [[IntroduceEditController alloc] init];
				editVC.title = @"个人简介";
				editVC.string = [YHUserInfoManager sharedInstance].userInfo.intro;
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 10:
			{
				ExperienceListController *editVC = [[ExperienceListController alloc] init];
				editVC.title = @"教育经历";
				editVC.experience = EducationExperience;
				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;

			case 11:
			{
				ExperienceListController *editVC = [[ExperienceListController alloc] init];
				editVC.title = @"工作经历";
				editVC.experience = WorkExperience;

				[self.navigationController pushViewController:editVC animated:YES];
			}
			break;
                
			default:
				break;
		}
	}
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *, id> *)info
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	UIImage *originImage = info[UIImagePickerControllerEditedImage];
	
    [self uploadAvatarWithImage:originImage];
    
    
//    NSData *data = nil;
//    
//	//安全操作,不能转jpeg才转png,以便压缩得更小
//	if (UIImageJPEGRepresentation(originImage, 0.1) != nil)
//	{
//		//将图片转换为JPG格式的二进制数据
//		data = UIImageJPEGRepresentation(originImage, 0.1);
//	}
//	else
//	{
//		//将图片转换为PNG格式的二进制数据
//		data = UIImagePNGRepresentation(originImage);
//	}
//
//	//将二进制数据生成UIImage
//	UIImage *image;
//
//	//这步安全操作
//	if (data == nil)
//	{
//		image = originImage;
//	}
//	else
//	{
//		image = [UIImage imageWithData:data];
//	}

	
}

#pragma mark
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (isSelectOriginalPhoto) {
        [[TZImageManager manager] getOriginalPhotoWithAsset:assets[0] completion:^(UIImage *photo, NSDictionary *info) {
            [self uploadAvatarWithImage:photo];
        }];
    }else{
        [self uploadAvatarWithImage:photos[0]];
    }
    
    //    NSData *data;
//    //安全操作,不能转jpeg才转png,以便压缩得更小
//    if (UIImageJPEGRepresentation(originImage, 0.1) != nil)
//    {
//        //将图片转换为JPG格式的二进制数据
//        data = UIImageJPEGRepresentation(originImage, 0.1);
//    }
//    else
//    {
//        //将图片转换为PNG格式的二进制数据
//        data = UIImagePNGRepresentation(originImage);
//    }
//    
//    //将二进制数据生成UIImage
//    UIImage *image;
//    
//    //这步安全操作
//    if (data == nil)
//    {
//        image = originImage;
//    }
//    else
//    {
//        image = [UIImage imageWithData:data];
//    }
}

-(void)uploadAvatarWithImage:(UIImage*)image{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    MyDetailEditCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //	UIImage *roundImage = [image ds_imageWithCornerRadius:image.size.width / 2];
    
    [[NetManager sharedInstance] postUploadImage:image complete:^(BOOL success, id obj) {
        if (success)
        {
            DDLog(@"上传照片成功");
            //修改单例属性值
            NSURL *oriUrl = obj;
            NSString *oriUrlStr = [oriUrl absoluteString];
            NSString *thumbUrlStr = [oriUrlStr stringByAppendingString:@"!m90x90.png"];
            NSURL *thumbUrl = [NSURL URLWithString:thumbUrlStr];
            YHUserInfo *userInfo = [[YHUserInfo alloc] init];
            userInfo.avatarUrl = thumbUrl;
            
            [[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (success)
                {
                    DDLog(@"上传照片URL成功");
                    [YHUserInfoManager sharedInstance].userInfo.avatarUrl = thumbUrl;
                    //更新数据库头像信息
                    [[SqliteManager sharedInstance] updateUserInfoWithItems:@[@"avatarUrl",@"oriAvaterUrl",@"avatarImage"] complete:^(BOOL success, id obj) {
                    }];
                    cell.avatar.image = [UIImage imageNamed:@"common_avatar_80px"];
                    [cell.avatar sd_setImageWithURL:thumbUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed | SDWebImageDelayPlaceholder | SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (error == nil)
                        {
                            
                        }
                        else
                        {
                            DDLog(@"%@", error.description);
                        }
                    }];
                }
                else
                {
                    if (isNSDictionaryClass(obj))
                    {
                        //服务器返回的错误描述
                        NSString *msg = obj[kRetMsg];
                        
                        postTips(msg, @"上传照片URL失败");
                    }
                    else
                    {
                        //AFN请求失败的错误描述
                        postTips(obj, @"上传照片URL失败");
                    }
                }
            }];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_NotReachable)
            {
                postTips(obj, @"网络连接失败，请检查网络设置");
            }
            else
            {
                postTips(obj, @"");
            }
        }
    } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- 缩放图片
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
	UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
	[image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
