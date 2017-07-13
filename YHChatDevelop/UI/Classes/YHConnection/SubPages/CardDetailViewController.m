//
//  CardDetailViewController.m
//  MyProject
//
//  Created by samuelandkevin on 16/4/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "CardDetailViewController.h"
#import "YHUserInfo.h"
#import "HHTagsContainer.h"
#import "UIImage+Extension.h"
#import "YHNetManager.h"
#import "YHCellWave.h"
#import "YHChatDetailVC.h"
#import "MBProgressHUD.h"
#import "YHCardDetailHeaderView.h"
#import "YHRefreshTableView.h"
#import "YHNavigationController.h"
#import "YHSqliteManager.h"
#import "UIImageView+WebCache.h"
#import "YHChatDevelop-Swift.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
//#import "MyDetailEditViewController.h"
//#import "MyDynamicViewController.h"
//#import "YHSocialShareManager.h"
//#import "YHSharePresentView.h"
//#import "MyDetailEditViewController.h"
//#import "YHConnectioniewController.h"
//#import "YHCacheManager.h"
//#import "ChooseMyFrisViewController.h"

#define  kHeaderIdentifier @"YHCardDetailHeaderView"
static const CGFloat kheaderHeightInsection = 53.0f; //section的header高度
static const CGFloat kfooterHeightInsection = 15;    //section的footer高度

static CGFloat const sectionHeaderH = 89.0f;    //个人头像
static CGFloat const sectionAccountH = 87.0f;   //税道账号
static CGFloat const sectionIntroH = 53.0f;     //个人简介
static CGFloat const sectionDynamicH = 53.0f;   //动态
static CGFloat const sectionTagsH = 53.0f;      //标签
static CGFloat const sectionJobExH = 88.0f;     //职业经历
static CGFloat const sectionLearnExH = 88.0f;   //教育经历
static CGFloat const sectionHideInfoH = 225.0f; //陌生人隐藏名片

/*****修改此值时候要到xib去修改相应的值*****/
static CGFloat const cstTagsTop = 17.0f; //标签顶部约束高度

typedef NS_ENUM (NSInteger, SectionType)
{
	SectionType_Avatar,         //头像
	SectionType_Account,        //账号
	SectionType_Intro,          //个人简介
//	SectionType_Dynamic,        //动态 (改版被删除)
	SectionType_Tags,           //标签
	SectionType_JobExperience,  //职业经历
	SectionType_LearnExperience //教育经历
};

@interface CardDetailViewController () <UITableViewDataSource, UITableViewDelegate>{
	
	CGFloat _tempSectionIntroH; //个人简介的高度
	CGFloat _tempSectionTagsH;  //标签高度
	CGFloat _tempSectionJobExH; //职业经历高度
	CGFloat _contentOffsetY;    //tableview的offsetY

	BOOL _bJobExExpand;   //职业经历展开
	BOOL _bLearnExExpand; //教育经历展开
}

/****tableviewHeader****/
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet YHCellWave *cellForHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelUserNick;   //用户昵称
@property (weak, nonatomic) IBOutlet UILabel *labelCompany;    //公司名称
@property (weak, nonatomic) IBOutlet UILabel *labelJob;        //职位名称
@property (weak, nonatomic) IBOutlet UIView *viewVerticalLine; //公司与职位之间的“|”线

/******section0*********/
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForAccount; //税道账号cell
@property (weak, nonatomic) IBOutlet UIImageView *imgvAvatar;           //头像

@property (weak, nonatomic) IBOutlet UILabel *labelPikeWayAccount; //税道账号
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNum;       //手机号码

/******section1*********/
@property (strong,nonatomic) CellForCard *cellForIntro;

/******section2*********/
@property (strong, nonatomic) IBOutlet YHCellWave *cellForDynamic; //动态cell
@property (weak, nonatomic) IBOutlet UILabel *labelDynamic;             //动态条数

/******section3*********/
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForTags;       //标签Cell
@property (strong, nonatomic) HHTagsContainer *viewTagsContainer; //标签容器
@property (weak, nonatomic) IBOutlet UILabel *labelNoTagsTips;


/****陌生人隐藏名片信息****/
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHideCardInfo;

/*********视图底部*******/
@property (weak, nonatomic) IBOutlet UIButton *btnBottom; //"分享"或者“发消息”按钮 ,在视图底部

/**********数据相关******/
@property (nonatomic, assign) BOOL isSelfProfile;     //是否个人
@property (nonatomic, assign) BOOL isMyfriend;        //是我的好友
@property (nonatomic, assign) BOOL isInfoPublic;      //资料是否公开
@property (nonatomic, strong) NSMutableArray *maTags; //标签数组

@property (nonatomic, strong) YHUserInfo *currentUserInfo; //当前用户信息

@property (nonatomic, strong) NSMutableArray *sectionDataSources;

@end

@implementation CardDetailViewController

- (NSMutableArray *)sectionDataSources
{
	if (!_sectionDataSources)
	{
		_sectionDataSources = [NSMutableArray arrayWithCapacity:2];
		YHCardSection *modelWork = [YHCardSection new];
		modelWork.mainTitle = @"职业经历";
		modelWork.subTitle = @"暂无工作经历";
		[_sectionDataSources addObject:modelWork];

		YHCardSection *modelLearn = [YHCardSection new];
		modelLearn.mainTitle = @"教育经历";
		modelLearn.subTitle = @"暂无教育经历";
		[_sectionDataSources addObject:modelLearn];
	}
	return _sectionDataSources;
}

- (instancetype)initWithUserInfo:(YHUserInfo *)userInfo
{
	if (self = [super init])
	{
        
		_currentUserInfo = userInfo;

		//0.判断条件
		if (!_currentUserInfo)
		{
			postTips(@"名片的用户信息为nil", @"");
			return nil;
		}
	}
	return self;
}

- (instancetype)initWithUserId:(NSString *)userId{
    if (self = [super init]) {
        if (!userId) {
            postTips(@"用户Id为nil",nil);
            return nil;
        }
        YHUserInfo *userInfo = [YHUserInfo new];
        userInfo.uid         =  userId;
        _currentUserInfo     = userInfo;
        
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
//    DDLog(@"CardDetailFrame = %@",NSStringFromCGRect(self.view.frame));
    self.navigationController.navigationBar.translucent = NO;
	//0.更新数据
	[self updateData];

	//1.initUI
	[self initUI];

	//2.网络请求
	if (_isSelfProfile)
	{
		//访问我自己的名片详情
		_currentUserInfo = [YHUserInfoManager sharedInstance].userInfo;
	}
	
    //访问别人的名片详情 
    [self requestCardDetaliWithTargetUid:_currentUserInfo.uid];

	//3.updateUserInfo
	[self updateUserInfo];

	//4.监听通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage:) name:Event_CardDetailPage_Refresh object:nil];
}

- (void)updateData
{
	if (_currentUserInfo.friShipStatus == FriendShipStatus_isMyFriend)
	{
		_isMyfriend = YES;
	}
	else
	{
		_isMyfriend = NO;
	}

	//1.是否个人页
	if ([_currentUserInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid])
	{
		_isSelfProfile = YES;
		_isMyfriend = YES;
	}

	_isInfoPublic = YES; //默认资料公开
}

- (void)initUI
{
	//1.tableView
	self.automaticallyAdjustsScrollViewInsets = NO;
   

//	self.imgvAvatar.layer.cornerRadius = 30;
//	self.imgvAvatar.layer.masksToBounds = YES;

	//标签容器
    _viewTagsContainer = (HHTagsContainer *)[_cellForTags viewWithTag:101];
	_viewTagsContainer.labelVerticalMargin = 4;
	_viewTagsContainer.titleColor = kBlueColor;
	_viewTagsContainer.tagTitleFontSize = 12.0f;
	_viewTagsContainer.showBackground = YES;
	_viewTagsContainer.tagBackground = [UIColor whiteColor];
	_viewTagsContainer.tagBorderHeight = 0.5;

	[self.tableView registerClass:[YHCardDetailHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderIdentifier];
    [self.tableView registerClass:[CellForCard class] forCellReuseIdentifier:NSStringFromClass([CellForCard class])];
    [self.tableView registerClass:[CellForCard2 class] forCellReuseIdentifier:NSStringFromClass([CellForCard2 class])];
	[self updateUI];
}

- (void)updateUI
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
	UIBarButtonItem *editBtn = nil;
    self.btnBottom.backgroundColor = kBlueColor;
    
	if (_isSelfProfile)
	{
		self.title = @"我的名片";

       
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithImgName:@"connection_btn_edit.png" target:self selector:@selector(onEdit:)];

        
		[self.btnBottom setTitle:@"分享名片" forState:UIControlStateNormal];
		self.btnBottom.enabled = YES;
	}
	else
	{
		if (_isMyfriend){
			//导航栏右按钮
			editBtn = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(onEdit:)];
			self.navigationItem.rightBarButtonItem = editBtn;
		}else{
			editBtn = nil;
			self.navigationItem.rightBarButtonItem = editBtn;
		}
        
		if (_isMyfriend){
			self.title = @"好友名片";
			[self.btnBottom setTitle:@"发消息" forState:UIControlStateNormal];
			self.btnBottom.enabled = YES;

		}else{
			self.title = @"陌生人名片";

			if (_currentUserInfo.addFriStatus == AddFriendStatus_otherPersonAddMe){
				[self.btnBottom setTitle:@"通过验证" forState:UIControlStateNormal];
				self.btnBottom.enabled = YES;
			}else if (_currentUserInfo.addFriStatus == AddFriendStatus_IAddOtherPerson){
				[self.btnBottom setTitle:@"等待对方验证通过" forState:UIControlStateNormal];
				self.btnBottom.enabled = NO;
			}else{
				[self.btnBottom setTitle:@"添加好友" forState:UIControlStateNormal];
				self.btnBottom.enabled = YES;
			}
		}
	}
}

- (void)updateUserInfo
{
	[self updateData];
    
	//头像
    _imgvAvatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    
    DDLog(@"%@",_currentUserInfo.avatarUrl);
	[_imgvAvatar sd_setImageWithURL:_currentUserInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed | SDWebImageProgressiveDownload |SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if (error == nil)
		{
        }
		else
		{
			DDLog(@"%@", error.description);
		}
	}];

	//昵称
	if (_currentUserInfo.userName.length)
	{
		_labelUserNick.text = _currentUserInfo.userName;
	}
	else
	{
		_labelUserNick.text = @"匿名用户";
	}

	//公司名称
	if (_currentUserInfo.company.length){
		_labelCompany.text = _currentUserInfo.company;
	}
	else{
		_labelCompany.text = @"公司";
	}

	//职位
	if (_currentUserInfo.job.length){
		_labelJob.text = _currentUserInfo.job;
	}
	else{
		_labelJob.text = @"职位";
	}

	if (!_currentUserInfo.company.length || !_currentUserInfo.job.length)
	{
		_viewVerticalLine.hidden = YES;
	}
	else{
		_viewVerticalLine.hidden = NO;
	}

	//税道账号
	if (!_currentUserInfo.taxAccount.length){
		_labelPikeWayAccount.text = @"未设置";
	}
	else{
		_labelPikeWayAccount.text = _currentUserInfo.taxAccount;
	}

	//手机号码
	if (_isMyfriend){
		_labelPhoneNum.text = _currentUserInfo.mobilephone;
	}
	else{
		_labelPhoneNum.text = @"仅好友可见";
	}

//	//个人简介
//	if (!_currentUserInfo.intro || !_currentUserInfo.intro.length){
//		_labelintro.text = @"TA很懒，没留下任何信息";
//	}
//	else{
//		_labelintro.text = _currentUserInfo.intro;
//	}

	//动态
	if (!_currentUserInfo.dynamicCount){
		_labelDynamic.text = @"暂无动态";
	}
	else{
		_labelDynamic.text = [NSString stringWithFormat:@"一共发布了%@条动态,点击查看", @(_currentUserInfo.dynamicCount)];
	}

	//标签

	if (_currentUserInfo.jobTags && [_currentUserInfo.jobTags count]){
		_viewTagsContainer.hidden = NO;
		self.labelNoTagsTips.text = @"";
		self.labelNoTagsTips.hidden = YES;

		self.maTags = _currentUserInfo.jobTags;
		[_viewTagsContainer setTagsTitle:_maTags];

	}else{
		_viewTagsContainer.hidden = YES;
		self.labelNoTagsTips.text = @"未设置职业标签";
		self.labelNoTagsTips.hidden = NO;
	}

	//职业背景
	if (_currentUserInfo.workExperiences && [_currentUserInfo.workExperiences count]){
		YHCardSection *model = self.sectionDataSources[0];
		model.cellModels = _currentUserInfo.workExperiences;
	}

	//教育背景
	if (_currentUserInfo.eductaionExperiences && [_currentUserInfo.eductaionExperiences count]){
		YHCardSection *model = self.sectionDataSources[1];
		model.cellModels = _currentUserInfo.eductaionExperiences;
	}
	
}

#pragma mark - Lazy Load
- (NSMutableArray *)maTags
{
	if (!_maTags)
	{
		_maTags = [NSMutableArray array];
	}
	return _maTags;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!_isMyfriend && !_isInfoPublic)
	{
		//陌生人信息不公开
		return 1;
	}
	else
	{
		if (section == SectionType_JobExperience || section == SectionType_LearnExperience)
		{
			int index = (section == SectionType_JobExperience) ? 0 : 1;

			YHCardSection *model = self.sectionDataSources[index];
			return model.isExpand ? model.cellModels.count : 0;
		}
		else
		{
			return 1;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!_isMyfriend && !_isInfoPublic)
	{
		//陌生人信息不公开
		if (indexPath.section == SectionType_Avatar)
		{
			return _cellForHeader;
		}
		else
		{
			return _cellForHideCardInfo;
		}
	}
	else
	{
		if (indexPath.section == SectionType_Avatar)
		{
			return _cellForHeader;
		}
		else if (indexPath.section == SectionType_Account)
		{
			return _cellForAccount;
		}
		else if (indexPath.section == SectionType_Intro)
		{
			//个人简介
            _cellForIntro = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForCard class])];
            [self setupIntro];

			return _cellForIntro;
		}
        //隐藏动态入口
//		else if (indexPath.section == SectionType_Dynamic)
//		{
//			return _cellForDynamic;
//		}
		else if (indexPath.section == SectionType_Tags)
		{
			//标签
			return _cellForTags;
		}
		else if (indexPath.section == SectionType_JobExperience)
		{
			//职业经历
            CellForCard2 *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForCard2 class])];
            if (!cell) {
                cell = [[CellForCard2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForCard2 class])];
            }

            YHCardSection *model = self.sectionDataSources[0];
            //时间线设置
			cell.viewTopLine.hidden = (indexPath.row == 0) ? YES : NO;
            if (indexPath.row == 0 && model.cellModels.count == 1){
                cell.viewBotLine.hidden = YES;
            }else{
                cell.viewBotLine.hidden = NO;
            }
            
            
			if (indexPath.row < model.cellModels.count)
			{
				[cell setWorkExpModel:model.cellModels[indexPath.row]];
			}

			return cell;
		}
		else if (indexPath.section == SectionType_LearnExperience)
		{
			//教育经历
            CellForCard2 *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellForCard2 class])];
            if (!cell) {
                cell = [[CellForCard2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CellForCard2 class])];
            }

            YHCardSection *model = self.sectionDataSources[1];
            //时间线设置
			cell.viewTopLine.hidden = (indexPath.row == 0) ? YES : NO;
            if (indexPath.row == 0 && model.cellModels.count == 1){
                cell.viewBotLine.hidden = YES;
            }else{
                cell.viewBotLine.hidden = NO;
            }
            
			if (indexPath.row < model.cellModels.count)
			{
				[cell setEduExpModel:model.cellModels[indexPath.row]];
			}

			return cell;
		}
		else
		{
			return kErrorCell;
		}
	}
}

- (void)setupIntro{
    if (!_currentUserInfo.intro || !_currentUserInfo.intro.length){
        _cellForIntro.labelContent.text = @"TA很懒，没留下任何信息";
    }
    else{
        _cellForIntro.labelContent.text = _currentUserInfo.intro;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (!_isMyfriend && !_isInfoPublic)
	{
		//陌生人资料不公开,显示两个Section
		return 2;
	}
	else
	{
		return 6;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!_isMyfriend && !_isInfoPublic)
	{
		switch (indexPath.section)
		{
			case SectionType_Avatar:
				return sectionHeaderH;

				break;

			case 1:
				return sectionHideInfoH;

				break;

			default:
				return 44.0f;

				break;
		}
	}
	else
	{
		switch (indexPath.section)
		{
			case SectionType_Avatar:
				return sectionHeaderH;

				break;

			case SectionType_Account:
				return sectionAccountH;

				break;

			case SectionType_Intro:
			{
                WeakSelf
                _tempSectionIntroH = [CellForCard hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
                    weakSelf.cellForIntro = (CellForCard *)sourceCell;
                    [self setupIntro];
                }];
                return _tempSectionIntroH;
			}

			break;

//			case SectionType_Dynamic:
//				return sectionDynamicH;
//
//				break;

			case SectionType_Tags:

				if (![_maTags count])
				{
					return sectionTagsH;
				}
				else
				{
					_tempSectionTagsH = [_viewTagsContainer estimateViewHeightWithTitles:_maTags] + cstTagsTop;

					if (_tempSectionTagsH < sectionTagsH)
					{
						return sectionTagsH;
					}
					return _tempSectionTagsH;
				}

				break;

			case SectionType_JobExperience:

				return sectionJobExH;

				break;

			case SectionType_LearnExperience:
				return sectionLearnExH;

				break;

			default:
				return 44.0f;

				break;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (!_isInfoPublic && !_isMyfriend)
	{
		//陌生人信息不公开
		return 0;
	}
	else
	{
		if (section == SectionType_LearnExperience || section == SectionType_JobExperience)
		{
			return kheaderHeightInsection;
		}
		else
		{
			return 0;
		}
	}
}

//自定义headerInSectionView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (!_isInfoPublic && !_isMyfriend)
	{
		//陌生人信息不公开
		return nil;
	}
	else
	{
		if (section == SectionType_JobExperience || section == SectionType_LearnExperience)
		{
			YHCardDetailHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];

			int index = (section == SectionType_JobExperience) ? 0 : 1;

			YHCardSection *model = self.sectionDataSources[index];

			if (_currentUserInfo.workExperiences.count && section == SectionType_JobExperience)
			{
				model.subTitle = @"";
			}

			if (_currentUserInfo.eductaionExperiences.count && section == SectionType_LearnExperience)
			{
				model.subTitle = @"";
			}

			headerView.model = model;
            
            __weak typeof(self)weakSelf = self;
			headerView.expandCallback = ^(BOOL isExpand) {
				[weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
						 withRowAnimation:UITableViewRowAnimationFade];
			};
			return headerView;
		}
		else
		{
			return nil;
		}
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *viewFooterInSection = [[UIView alloc] init];

	viewFooterInSection.backgroundColor = kViewBGColor;
	return viewFooterInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (!_isMyfriend && !_isInfoPublic)
	{
		if (section == 1)
		{
			return 0.0f;
		}
		return kfooterHeightInsection;
	}
	else
	{
		if (section == SectionType_LearnExperience)
		{
			return 0.0f;
		}
		return kfooterHeightInsection;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == SectionType_Avatar)
	{
        WeakSelf
        [_cellForHeader startAnimation:^(BOOL finished) {
            //进入二维码名片页
            YHQRCodeCardVC *vc = [[YHQRCodeCardVC alloc] initWithUserInfo:_currentUserInfo];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
		
	}
    //隐藏动态入口
//	if (indexPath.section == SectionType_Dynamic)
//	{
//		if (_isMyfriend)
//		{
//            WeakSelf
//            [_cellForDynamic startAnimation:^(BOOL finished) {
//                MyDynamicViewController *vc = [[MyDynamicViewController alloc] initWithUserInfo:_currentUserInfo];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
//            }];
//			
//		}
//		else
//		{
//			NSString *sex = (_currentUserInfo.sex == Gender_Man)? @"他" : @"她";
//			NSString *tips = [NSString stringWithFormat:@"%@不是你的好友,不能查看%@的工作状态", sex, sex];
//			postHUDTipsWithHideDelay(tips, self.view, 2);
//		}
//	}
}

#pragma mark - Private


#pragma mark - Action

- (void)onEdit:(id)sender
{
	//1.本机用户
	if (_isSelfProfile)
	{
		//进入编辑页
//		MyDetailEditViewController *vc = [[MyDetailEditViewController alloc] init];
//		[self.navigationController pushViewController:vc animated:YES];
	}
	else
	{
		//进入更多页
		YHCardSettingVC *vc = [[YHCardSettingVC alloc] initWithUserInfo:_currentUserInfo];
        vc.model = _model;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (IBAction)onBottomBtn:(id)sender
{
	//1.本机用户
	if (_isSelfProfile)
	{
		//分享名片
//		YHSharePresentView *shareView = [[YHSharePresentView alloc] init];
//        shareView.shareType = ShareType_Card;
//        [shareView show];
//        [shareView dismissHandler:^(BOOL isCanceled, NSInteger index) {
//            if (!isCanceled)
//            {
//                switch (index)
//                {
//                    case 3:
//                    {
//                        ChooseMyFrisViewController *vc = [[ChooseMyFrisViewController alloc] init];
//                        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
//                        vc.shareType = ShareType_Card;
//                        vc.shareCardToPWFris = _currentUserInfo;
//                        [self presentViewController:nav animated:YES completion:NULL];
//                        
//                    }
//                        break;
//                        
//                    case 0:
//                    {
//                        [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeCard platform:YHSharePlatform_Weixin shareObj:_currentUserInfo];
//                    }
//                        break;
//                        
//                    case 1:
//                    {
//                        //微信好友
//                        
//                        [[YHSocialShareManager sharedInstance] snsShareContentWithType:YHShareTypeCard platform:YHSharePlatform_WeixinSession shareObj:_currentUserInfo];
//                    }
//                        break;
//                        
//                    default:
//                        break;
//                }
//
//            }
//       
//        }];
 
	}
	else
	{
		if (_isMyfriend)
		{
			//发消息
			DDLog(@"点击发消息");
        
            YHChatDetailVC *vc =[YHChatDetailVC new];
            vc.model = _model;
            [self.navigationController pushViewController:vc animated:YES];

		}
		else
		{
			if (_currentUserInfo.addFriStatus == AddFriendStatus_otherPersonAddMe)
			{
				//通过验证
				[self requestAcceptAddFriendReq];
			}
			else
			{
				if ([[YHUserInfoManager sharedInstance] hasCompleteUserInfo])
				{
					//添加好友
					[self requestAddFriend];
				}
				else
				{
                    
                    [YHAlertView showWithTitle:@"请完善个人职业信息再添加好友" message:nil cancelButtonTitle:@"取消"otherButtonTitle:@"确定" clickButtonBlock:^(YHAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1)
                        {
//                            MyDetailEditViewController *VC = [[MyDetailEditViewController alloc] init];
//                            [self.navigationController pushViewController:VC animated:YES];
                        }
                    }];

				}
			}
		}
	}
}

- (void)onBack:(id)sender{
    if(_isFromScanVC && self.navigationController.viewControllers.count > 2){
        UIViewController *vc = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 网络请求
//通过验证
- (void)requestAcceptAddFriendReq
{
	__block MBProgressHUD *hud = showHUDWithText(@"", [UIApplication sharedApplication].keyWindow.rootViewController.view);

	[[NetManager sharedInstance] postAcceptAddFriendRequest:_currentUserInfo.uid complete:^(BOOL success, id obj) {
		[hud hideAnimated:YES];

		if (success)
		{
			postHUDTips(@"申请好友通过,你们现在可以聊天", self.view);

			_currentUserInfo.friShipStatus = FriendShipStatus_isMyFriend;
			[self updateUserInfo];
			[self updateUI];
			[self.tableView reloadData];

	        //新的好友页面刷新
			[[NSNotificationCenter defaultCenter] postNotificationName:Event_NewFriendsPage_Refresh object:self userInfo:@{@"userInfo" : _currentUserInfo}];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

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

//添加好友
- (void)requestAddFriend
{
	__block MBProgressHUD *hud = showHUDWithText(@"", [UIApplication sharedApplication].keyWindow.rootViewController.view);

	[[NetManager sharedInstance] postAddFriendwithFriendId:_currentUserInfo.uid complete:^(BOOL success, id obj) {
		[hud hideAnimated:YES];

		if (success)
		{
			NSString *userName = _currentUserInfo.userName.length ? _currentUserInfo.userName : @"TA";
			NSString *tips = [NSString stringWithFormat:@"您已申请添加%@为好友", userName];
			postHUDTipsWithHideDelay(tips, self.view, 3);

			_currentUserInfo.addFriStatus = AddFriendStatus_IAddOtherPerson;
			[self updateUserInfo];
			[self updateUI];

			[self.tableView reloadData];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

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

//删除好友
- (void)requestDeleteFriend
{
	[[NetManager sharedInstance] postDeleteFriendWithFrinedId:@"5" complete:^(BOOL success, id obj) {
		if (success)
		{
			DDLog(@"删除好友失败:%@", obj);
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"删除好友失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"删除好友失败");
			}
		}
	}];
}

//获取我的名片详情
- (void)requestGetMyCardDetail
{
	[[NetManager sharedInstance] getMyCardDetailComplete:^(BOOL success, id obj) {
		if (success)
		{
			DDLog(@"获取我的名片成功:%@", obj);
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"获取我的名片失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"获取我的名片失败");
			}
		}
	}];
}

//请求别人的名片详情
- (void)requestCardDetaliWithTargetUid:(NSString *)targertUid
{
	[[NetManager sharedInstance] getVisitCardDetailWithTargetUid:targertUid complete:^(BOOL success, id obj) {
		if (success)
		{
			DDLog(@"获取名片详情成功:%@", obj);
			_currentUserInfo = obj;
			[self updateUserInfo];
			[self updateUI];
			[self.tableView reloadData];

			[self requestGetUserAccount];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"获取名片详情失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"获取名片详情失败");
			}
		}
	}];
}

//请求获取用户的手机号和税道账号
- (void)requestGetUserAccount
{
	[[NetManager sharedInstance] getUserAccountWithUserId:_currentUserInfo.uid complete:^(BOOL success, id obj) {
		if (success)
		{
			DDLog(@"获取用户账号成功:%@", obj);

			_currentUserInfo.mobilephone = obj[@"mobilePhone"];
			_currentUserInfo.taxAccount = obj[@"taxAccount"];
			[self updateUserInfo];
            
            if(_isMyfriend){
                [[SqliteManager sharedInstance] updateOneFri:_currentUserInfo updateItems:nil complete:^(BOOL success, id obj) {
                    if (success) {
                        DDLog(@"更新某个好友信息成功%@",obj);
                    }else{
                        DDLog(@"更新某个好友信息失败%@",obj);
                    }
                }];
            }
         
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"获取用户账号失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"获取用户账号失败");
			}
		}
	}];
}

#pragma mark - NSNotification
- (void)refreshPage:(NSNotification *)aNotification
{
	NSDictionary *dict = aNotification.userInfo;

	_currentUserInfo = dict[@"userInfo"];
	[self updateUserInfo];
	[self updateUI];
	[self.tableView reloadData];
}

#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if (_isSelfProfile)
	{
        _currentUserInfo = [YHUserInfoManager sharedInstance].userInfo;
		[self updateUserInfo];
		[self.tableView reloadData];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)dealloc
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DDLog(@"%s vc dealloc", __FUNCTION__);
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
