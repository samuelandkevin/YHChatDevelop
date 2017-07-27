//
//  ChooseMyFrisViewController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/7/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "ChooseMyFrisViewController.h"
#import "YHRefreshTableView.h"
#import "YHCacheManager.h"
#import "CellForMyFans.h"
#import "RegexKitLite.h"
#import "pinyin.h"
#import "ChineseString.h"
#import "YHNetManager.h"
#import "YHChatDevelop-Swift.h"


static const CGFloat kheaderHeightInsection = 20; //section的header高度

@interface ChooseMyFrisViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) YHRefreshTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *prefixLetters;
@property (nonatomic, strong) NSMutableDictionary *usersDictSort;

@end

@implementation ChooseMyFrisViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[self initUI];

	NSArray *cacheList = [[YHCacheManager shareInstance] getCacheMyFriendsList];

	if (cacheList.count)
	{
		self.dataArray = [cacheList mutableCopy];
		[self getSortArr:self.dataArray];
		[self.tableView reloadData];
	}
	else
	{
		[self requestMyfriendsListLoadNew:YES];
	}
}

- (void)initUI
{
	self.title = @"我的好友";

	YHRefreshTableView *tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.rowHeight = 60;
	tableView.sectionIndexBackgroundColor = [UIColor clearColor];
	tableView.sectionIndexColor = RGBCOLOR(160, 160, 160);
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	self.tableView = tableView;

	//1.左BarItem
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
- (void)requestMyfriendsListLoadNew:(BOOL)loadNew
{
	__weak typeof(self) weakSelf = self;

	[[NetManager sharedInstance] postMyFriendsCount:1000 currentPage:1 complete:^(BOOL success, id obj)
	{
		if (success)
		{
			NSArray *retArray = obj[@"friends"];
			DDLog(@"我的好友列表:%@ \n数量%lu", retArray, (unsigned long)retArray.count);

			if (loadNew)
			{
				weakSelf.dataArray = [NSMutableArray arrayWithArray:retArray];
			}
			else
			{
				if (retArray.count)
				{
					[weakSelf.dataArray addObjectsFromArray:retArray];
				}
			}

			[[YHCacheManager shareInstance] cacheMyFriendsList:weakSelf.dataArray];

			if (retArray.count < lengthForEveryRequest)
			{
				if (loadNew)
				{
					if (!retArray.count)
					{
						[(YHRefreshTableView *) weakSelf.tableView setNoData:YES withText:@"暂无朋友"];
					}
				}

				[weakSelf getSortArr:weakSelf.dataArray];
			}

			[weakSelf.tableView reloadData];
		}
		else
		{
			if (isNSDictionaryClass(obj))
			{
	            //服务器返回的错误描述
				NSString *msg = obj[kRetMsg];

				postTips(msg, @"获取我的好友失败");
			}
			else
			{
	            //AFN请求失败的错误描述
				postTips(obj, @"获取我的好友失败");
			}
		}
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *key = self.prefixLetters[section];
	NSArray *arrayNick = self.usersDictSort[key];

	return arrayNick.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CellForMyFans *cell = [CellForMyFans cellWithTableView:tableView];

	[cell resetCell];
	NSString *key = [self.prefixLetters objectAtIndex:indexPath.section];
	NSArray *arrayNick = self.usersDictSort[key];

	if (indexPath.row < arrayNick.count)
	{
		cell.userInfo = [arrayNick objectAtIndex:indexPath.row];
	}
	return cell;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.prefixLetters.count;
}

//点击索引栏滚动到指定位置
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	// 获取所点目录对应的indexPath值
	NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];

	// 让table滚动到对应的indexPath位置
	[tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

	return [self.usersDictSort allKeys].count;
}

//索引栏数组
- (NSArray <NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	NSMutableArray *maIndex = [NSMutableArray array];

	if (self.prefixLetters && self.prefixLetters)
	{
		maIndex = [self.prefixLetters mutableCopy];
	}
	return maIndex;
}

//自定义headerInSectionView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	static NSString *headerId = @"headFoot";
	UITableViewHeaderFooterView *hf = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];

	if (!hf)
	{
		hf = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerId];
		hf.contentView.backgroundColor = kTbvBGColor;

		//首字母
		UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, kheaderHeightInsection)];
		labelTitle.tag = 101;
		labelTitle.font = [UIFont systemFontOfSize:14.0f];
		labelTitle.textColor = RGBCOLOR(160, 160, 160);
		[hf addSubview:labelTitle];
	}

	//设置section标题
	UILabel *labelTitle = (UILabel *)[hf viewWithTag:101];
	NSString *preLetter = [self.prefixLetters objectAtIndex:section];
	labelTitle.text = preLetter;
	return hf;
}

//headerInSection 行高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kheaderHeightInsection;
}

//选中某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *preLetter = [self.prefixLetters objectAtIndex:indexPath.section];
	NSArray *userListInpreLetter = self.usersDictSort[preLetter];

	if (indexPath.row < userListInpreLetter.count)
	{
		YHUserInfo *userInfo = userListInpreLetter[indexPath.row];
		switch (_shareType)
		{
			case SHareType_Dyn:
			{
				[self handleShareDynToUser:userInfo];
			}
			break;

			case SHareType_Card:
			{
				[self handleShareCardToUser:userInfo];
			}
			break;

			default:
				break;
		}
	}
}

- (void)handleShareDynToUser:(YHUserInfo *)userInfo
{
//	NSString *title = [NSString stringWithFormat:@"确定分享动态给 %@", userInfo.userName];
//
//	[HHUtils showAlertWithTitle:@"" message:title okTitle:@"确定" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes)
//	{
//		if (resultYes)
//		{
////             DDLog(@"确定分享 %@", self.shareDynToPWFris);
//			[IMConversationHelper addNewArrayFromUid:userInfo.uid andName:userInfo.userName andAvatarUrl:userInfo.avatarUrl];
//			NSString *conversationID = [userInfo.uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
//			NSDictionary *dic = [IMConversationHelper createExtWithUid:conversationID];
//			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//
//			[mDic setObject:self.shareDynToPWFris.dynamicId forKey:IM_ShareDynamic_ID];
//
//			NSString *urlString;
//
//			if (self.shareDynToPWFris.thumbnailPicUrls.count == 0)
//			{
//				urlString = [NSString stringWithFormat:@"%@", self.shareDynToPWFris.userInfo.avatarUrl];
//			}
//			else
//			{
//				urlString = [NSString stringWithFormat:@"%@", self.shareDynToPWFris.thumbnailPicUrls[0]];
//			}
//			[mDic setObject:urlString forKey:IM_ShareDynamic_ImageURL];
//			[mDic setObject:self.shareDynToPWFris.msgContent forKey:IM_ShareDynamic_Detail];
//
//			EMMessage *message = [EaseSDKHelper sendTextMessage:@""
//															 to:conversationID
//													messageType:EMChatTypeChat
//													 messageExt:mDic];
//
//			[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
//				if (aError)
//				{
//					DDLog(@"环信发送消息失败,错误码%u", aError.code);
//				}
//				else
//				{
//#warning 分享成功的回调
//					postTips([NSString stringWithFormat:@"已成功分享动态给%@", userInfo.userName], nil);
//                    [self onBack:nil];
//				}
//			}];
//		}
//	}
//	];
}

- (void)handleShareCardToUser:(YHUserInfo *)userInfo
{
//	NSString *title = [NSString stringWithFormat:@"确定分享名片给 %@", userInfo.userName];
//
//	[HHUtils showAlertWithTitle:@"" message:title okTitle:@"确定" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
//		if (resultYes)
//		{
//	        //确定分享名片
//            [IMConversationHelper addNewArrayFromUid:userInfo.uid andName:userInfo.userName andAvatarUrl:userInfo.avatarUrl];
//			NSString *conversationID = [userInfo.uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
//			NSDictionary *dic = [IMConversationHelper createExtWithUid:conversationID];
//			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//
//
//			[mDic setObject:self.shareCardToPWFris.uid forKey:IM_ShareFriend_UID];
//
//            NSString *avatarUrlString = [NSString stringWithFormat:@"%@", self.shareCardToPWFris.avatarUrl];
//            
//			if (avatarUrlString.length > 0)
//			{
//				[mDic setObject:avatarUrlString forKey:IM_ShareFriend_Avatar];
//			}
//			else
//			{
//				[mDic setObject:@"" forKey:IM_ShareFriend_Avatar];
//			}
//
//			if (self.shareCardToPWFris.userName.length > 0)
//			{
//				[mDic setObject:self.shareCardToPWFris.userName forKey:IM_ShareFriend_Name];
//			}
//			else
//			{
//				[mDic setObject:@"" forKey:IM_ShareFriend_Name];
//			}
//
//			if (self.shareCardToPWFris.company.length > 0)
//			{
//				[mDic setObject:self.shareCardToPWFris.company forKey:IM_ShareFriend_Company];
//			}
//			else
//			{
//				[mDic setObject:@"" forKey:IM_ShareFriend_Company];
//			}
//
//			if (self.shareCardToPWFris.job.length > 0)
//			{
//				[mDic setObject:self.shareCardToPWFris.job forKey:IM_ShareFriend_Postion];
//			}
//			else
//			{
//				[mDic setObject:@"" forKey:IM_ShareFriend_Postion];
//			}
//
//			EMMessage *message = [EaseSDKHelper sendTextMessage:@""
//															 to:conversationID
//													messageType:EMChatTypeChat
//													 messageExt:mDic];
//
//			[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
//				if (aError)
//				{
//					DDLog(@"环信发送消息失败,错误码%u", aError.code);
//				}
//				else
//				{
//#warning 分享成功的回调
//					postTips([NSString stringWithFormat:@"已成功分享好友名片给%@", userInfo.userName], nil);
//                    [self onBack:nil];
//                    
//				}
//			}];
//		}
//	}];
}

#pragma mark - Private

/**
 *  获取排序后的好友数组
 *
 *  @param arrToSort 待排序的数组
 *
 *  @return 排序成功的数组
 */
- (NSMutableArray *)getSortArr:(NSMutableArray *)arrToSort
{
	[arrToSort sortUsingComparator:^NSComparisonResult (YHUserInfo *obj1, YHUserInfo *obj2) {
		return [obj1.userName localizedCaseInsensitiveCompare:obj2.userName];
	}];

	NSMutableDictionary *dictSourceData = [NSMutableDictionary dictionary];

	for (YHUserInfo *info in arrToSort)
	{
		if (!info.userName.length)
		{
			info.userName = @"匿名用户";
		}

		NSString *key = [NSString string];
		BOOL isEn = [info.userName isMatchedByRegex:@"^[a-zA-Z]+"];

		if (isEn)
		{
			//首位为字母开头
			key = [[info.userName substringToIndex:1] uppercaseString];
		}
		else
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

	NSArray *tempKeySort = [[dictSourceData allKeys] sortedArrayUsingComparator:^NSComparisonResult (NSString *obj1, NSString *obj2) {
		char a1 = [obj1 characterAtIndex:0];
		char a2 = [obj2 characterAtIndex:0];

		if (a1 > a2)
		{
			return NSOrderedDescending;
		}
		else if (a1 == a2)
		{
			return NSOrderedSame;
		}
		else
		{
			return NSOrderedAscending;
		}
	}];

	NSMutableArray *maResultKeySort = [NSMutableArray arrayWithArray:tempKeySort];

	if (maResultKeySort.count)
	{
		if ([tempKeySort[0] isEqualToString:@"#"])
		{
			//交换首尾位置
			[maResultKeySort removeObject:@"#"];
			[maResultKeySort addObject:@"#"];
		}
		self.prefixLetters = maResultKeySort;
		self.usersDictSort = dictSourceData;
	}
	else
	{
		self.prefixLetters = nil;
		self.usersDictSort = nil;
	}

	return arrToSort;
}

#pragma mark - Action
- (void)onBack:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Life
- (void)dealloc
{
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
