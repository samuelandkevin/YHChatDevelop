//
//  MyMapController.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/12.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "MyMapController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h> //引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h> //引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h> //引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h> //引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h> //引入定位功能所有的头文件

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h> //引入计算工具所有的头文件

#import <BaiduMapAPI_Radar/BMKRadarComponent.h> //引入周边雷达功能所有的头文件
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "MyMapCell.h"
#import "MySearchResultModel.h"
#import "YHUserInfoManager.h"
#import "YHNetManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "YHChatDevelop-Swift.h"

#define MAINWIDTH  [UIScreen mainScreen].bounds.size.width
#define MAINHEIGHT [UIScreen mainScreen].bounds.size.height
#define iPhoe6P	   [[UIScreen mainScreen] bounds].size.height == 736
@interface MyMapController () <UITableViewDelegate, UITableViewDataSource, BMKSuggestionSearchDelegate>
@property (nonatomic, strong) UIView *customView;
//@property (nonatomic, strong) UILabel *ViewLabel;
@property (nonatomic, strong) NSString *addressStr;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, assign) BOOL tangkuan;
@property (nonatomic, assign) BOOL dingwei;
@property (nonatomic, assign) BOOL chengshi;
@property(nonatomic, assign) BOOL isSearch;
@property (nonatomic, assign) int dingweiNum;
@property (nonatomic, strong) NSMutableDictionary *Ldic;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic,strong) BMKSuggestionResult * searchResult;
@property(nonatomic,strong) NSString * locationName;

@end

@implementation MyMapController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];

	//适配ios7
	if ( ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0))
	{
		self.navigationController.navigationBar.translucent = NO;
	}

	// Do any additional setup after loading the view.

	self.dingweiNum = 0;
    self.isSearch = NO;
	self.dataArray = [NSMutableArray array];
	//	nav = [[MyNav alloc] initWithFrame:CGRectMake(0, 0, MAINWIDTH, 64)];

	//	[self.view addSubview:nav];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"保存" target:self selector:@selector(chilkButton:)];
    
	self.address = [[UITextField alloc] initWithFrame:CGRectMake(15, 15, MAINWIDTH - 30, 40)];
	self.address.layer.cornerRadius = 10;
	self.address.backgroundColor = [UIColor whiteColor];
	self.address.delegate = self;
	self.address.textAlignment = NSTextAlignmentCenter;
	self.address.font = [UIFont systemFontOfSize:17];
	self.address.placeholder = @"搜索地址信息";
    self.address.returnKeyType = UIReturnKeySearch;
	//address.textAlignment = NSTextAlignmentCenter;

	//	UIView *textView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	//	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 16, 17)];
	//	image.image = [UIImage imageNamed:@"seek"];
	//	[textView2 addSubview:image];
	//	address.leftView = textView2;
	//	address.leftViewMode = UITextFieldViewModeAlways;

	self.address.clearButtonMode = UITextFieldViewModeAlways;

	[self.view addSubview:self.address];

	
	self.chengshi = YES;
	self.mapView = [[BMKMapView alloc] init];
//                    WithFrame:CGRectMake(0, 70, MAINWIDTH, MAINHEIGHT - 70)];
	self.mapView.showsUserLocation = YES;
	self.mapView.zoomLevel = 18;
	[self.view addSubview:self.mapView];

	self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[self.view addSubview:self.tableView];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.tableView registerClass:[MyMapCell class] forCellReuseIdentifier:@"MyMapCell"];
	self.tableView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];

	WeakSelf

	[self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.address.mas_bottom).offset(15);
		make.left.equalTo(weakSelf.view);
		make.width.mas_equalTo(MAINWIDTH);
	}];

	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(weakSelf.mapView);
		make.top.equalTo(weakSelf.mapView.mas_bottom);
		make.bottom.equalTo(weakSelf.view);
		make.width.mas_equalTo(MAINWIDTH);
	}];

	self.Ldic = [NSMutableDictionary dictionary];

	BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
	displayParam.isRotateAngleValid = false;   //跟随态旋转角度是否生效
	displayParam.isAccuracyCircleShow = false; //精度圈是否显示

	//在6P上用的是百度地图起始点图标，，
	//    displayParam.locationViewImgName = iPhoe6P?@"icon_nav_start.png":@"icon_center_point.png";
	displayParam.locationViewImgName = iPhoe6P ? @"icon_nav_start" : @"icon_center_point";
	[self.mapView updateLocationViewWithParam:displayParam];

	self.locService = [[BMKLocationService alloc] init];
	self.locService.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	self.locService.distanceFilter = 100;
	self.locService.delegate = self;

	self.mapView.userTrackingMode = BMKUserTrackingModeFollow; //设置定位的状态

	self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
	self.geocodesearch.delegate = self;

	UIButton *locationBut = [UIButton buttonWithType:UIButtonTypeCustom];
	locationBut.backgroundColor = [UIColor blackColor];
	[locationBut addTarget:self action:@selector(dingweiButonn) forControlEvents:UIControlEventTouchUpInside];
	locationBut.layer.cornerRadius = 5;
	locationBut.layer.borderColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1].CGColor;
	locationBut.layer.borderWidth = 1;
	locationBut.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	[self.view addSubview:locationBut];

	[locationBut mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.height.equalTo(@45);
		make.left.equalTo(weakSelf.mapView).offset(15);
		make.bottom.equalTo(weakSelf.mapView).offset(-15);
	}];

	//	[self controls];
	[self dingweiButonn];

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    

}

-(BMKSuggestionSearch *)search{
    if (!_search) {
        _search = [[BMKSuggestionSearch alloc]init];
        _search.delegate = self;
    }
    return _search;
}


#pragma mark tableView delegate & datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMapCell" forIndexPath:indexPath];

	if (!cell)
	{
		cell = [[MyMapCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"MyMapCell"];
	}
	
    if (self.isSearch) {
        MySearchResultModel *model = self.dataArray[indexPath.row];
        cell.title.text = model.key;
        cell.detail.text = [NSString stringWithFormat:@"%@%@",model.city,model.district];
    }else{
    BMKPoiInfo *info = self.dataArray[indexPath.row];
	cell.title.text = info.name;
    cell.detail.text = info.address;
    }
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyMapCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.locationName = cell.title.text;
    MySearchResultModel *model = self.dataArray[indexPath.row];
    [self moveToLat:model.pt.latitude Long:model.pt.longitude];
}

#pragma mark textView delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
//    option.cityname = @"广州";
    option.keyword  = self.address.text;
    BOOL flag = [self.search suggestionSearch:option];
    if(flag)
    {
        DDLog(@"建议检索发送成功");
    }
    else
    {
        DDLog(@"建议检索发送失败");
    }
    [self.locService stopUserLocationService];

}

- (void)dingweiButonn
{
	[self.locService startUserLocationService];

	[self moveToLat:self.locService.userLocation.location.coordinate.latitude Long:self.locService.userLocation.location.coordinate.longitude];
}

//地图中心点
- (void)moveToLat:(CGFloat)lat Long:(CGFloat)newLong
{
	CLLocationCoordinate2D coor;

	coor.latitude = lat;
	coor.longitude = newLong;

	BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coor, BMKCoordinateSpanMake(0, 0));
	BMKCoordinateRegion adjusteRegion = [self.mapView regionThatFits:viewRegion];
	[self.mapView setRegion:adjusteRegion animated:YES];
}

//- (void)controls
//{
//	self.customView = [[UIView alloc] initWithFrame:CGRectMake(0, MAINHEIGHT - 50, MAINWIDTH, 50)];
//	self.customView.layer.cornerRadius = 5;
//	self.customView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1];
//
//	[[[UIApplication sharedApplication] keyWindow] addSubview:self.customView];
//
//	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 16, 20)];
//	image.image = [UIImage imageNamed:@"client_address_icon2"];
//	[self.customView addSubview:image];
//
//	self.ViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 5, self.customView.frame.size.width - 124, 40)];
//	self.ViewLabel.font = [UIFont systemFontOfSize:14];
//	self.ViewLabel.textColor = [UIColor blackColor];
//	self.ViewLabel.backgroundColor = [UIColor clearColor];
//	self.ViewLabel.numberOfLines = 2;
//	[self.customView addSubview:self.ViewLabel];
//
//	UIButton *sure = [UIButton buttonWithType:UIButtonTypeCustom];
//	sure.layer.cornerRadius = 5;
//	sure.frame = CGRectMake(self.customView.frame.size.width - 85, 10, 70, 30);
//	sure.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:86 / 255.0 blue:90 / 255.0 alpha:1];
//	[sure setTitle:@"确定" forState:UIControlStateNormal];
//	[sure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//	[sure addTarget:self action:@selector(sureButton:) forControlEvents:UIControlEventTouchUpInside];
//	[self.customView addSubview:sure];
//}

//弹框的确定按钮
//- (void)sureButton:(UIButton *)sender
//{
//	if (self.addressYes == YES)
//	{
//		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//		[dic setObject:[self.Ldic objectForKey:@"Lat"] forKey:@"lat"];
//		[dic setObject:[self.Ldic objectForKey:@"Lng"] forKey:@"lng"];
//		[dic setObject:self.addressStr forKey:@"address"];
//		return;
//	}
//	[self.locService startUserLocationService];
//
//	[self.Ldic setObject:self.addressStr forKey:@"Address"];
//	DDLog(@"dic:%@", self.Ldic);
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"AddressData" object:self.Ldic];
//	[self.navigationController popViewControllerAnimated:YES];
//}

- (void)viewWillAppear:(BOOL)animated
{
	[self.mapView viewWillAppear];
	[self.locService startUserLocationService];
	self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放

	if (self.dicInfo && ([[self.dicInfo objectForKey:@"Lat"] floatValue] > 0.0f))
	{
		self.tangkuan = NO;
		self.dingwei = NO;
	} /*else if (dicInfo&&[self NullClear:[dicInfo objectForKey:@"CityName"]]&&[self NullClear:[dicInfo objectForKey:@"AreaName"]]&&[[dicInfo objectForKey:@"CityName"] length]>0&&[[dicInfo objectForKey:@"AreaName"] length]>0){
	   *          tangkuan = YES;
	   *
	   
	   *  dingwei = NO;
	   *  }*/
	else
	{
		self.tangkuan = YES;
		self.dingwei = YES;
	}

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.fd_interactivePopDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.mapView viewWillDisappear];
	[super viewWillDisappear:animated];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
    self.geocodesearch.delegate = nil;
    self.search.delegate = nil;
    [self.locService stopUserLocationService];
}

- (void)dealloc
{
    DDLog(@"%@ did dealloc", self);
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 这里给单例赋值
- (void)chilkButton:(UIButton *)sender
{
	[self.address resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    YHUserInfo *userInfo = [[YHUserInfo alloc]init];
    userInfo.workLocation = self.locationName;
    [[NetManager sharedInstance] postEditMyCardWithUserInfo:userInfo complete:^(BOOL success, id obj) {
        [MBProgressHUD hideHUDForView: self.view animated:YES];
        if (success) {
            [YHUserInfoManager sharedInstance].userInfo.workLocation = userInfo.workLocation;
            postTips(@"保存成功", nil);
            [self.navigationController popViewControllerAnimated:YES];
        }else{
        
            
            if (isNSDictionaryClass(obj))
            {
                //服务器返回的错误描述
                NSString *msg  = obj[kRetMsg];
                
                postTips(msg, @"保存地址失败");
                
            }
            else
            {
                //AFN请求失败的错误描述
                postTips(obj, @"保存地址失败");
            }
        }
        
    }];
    
    
    
    
    
//    BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
////    option.cityname = @"广州";
//    option.keyword  = self.address.text;
//    BOOL flag = [self.search suggestionSearch:option];
//    if(flag)
//    {
//        DDLog(@"建议检索发送成功");
//    }
//    else
//    {
//        DDLog(@"建议检索发送失败");
//    }
//    [self.locService stopUserLocationService];



	//    cityName = [dicInfo objectForKey:@"CityName"];
//	self.cityName = self.address.text;

//	if (!self.cityName || self.cityName.length == 0)
//	{
//		return;
//	}
//	BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc] init];
////	geocodeSearchOption.city = self.cityName;
//	geocodeSearchOption.address = self.address.text;
//	BOOL flag = [self.geocodesearch geoCode:geocodeSearchOption];
//
//	if (flag)
//	{
//		DDLog(@"geo检索发送成功");
//	}
//	else
//	{
//		DDLog(@"geo检索发送失败");
//	}
	
}
#pragma mark BMKSuggestionSearchDelegate
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        self.isSearch = YES;
        _searchResult = result;
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(self.locService.userLocation.location.coordinate.latitude,self.locService.userLocation.location.coordinate.longitude));
        
        
        //在此处理正常结果
        [self.dataArray removeAllObjects];
        for (int i = 0; i < result.keyList.count; i++ ) {
            MySearchResultModel *model = [[MySearchResultModel alloc]init];
            NSValue *value = result.ptList[i];
            CLLocationCoordinate2D pt = [value MKCoordinateValue];
            BMKMapPoint point2 = BMKMapPointForCoordinate(pt);
            CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            model.city = result.cityList[i];
            model.key = result.keyList[i];
            model.district = result.districtList[i];
            model.distance = distance;
            model.pt = pt;
            [self.dataArray addObject:model];
        }
        
        [self.dataArray sortUsingComparator:^NSComparisonResult(MySearchResultModel * obj1, MySearchResultModel  * obj2) {
            if (obj1.distance > obj2.distance) {
                return NSOrderedDescending;
            }else if(obj1.distance < obj2.distance) {
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
        }];
        
        [self.tableView reloadData];
        
    }
    else {
        DDLog(@"抱歉，未找到结果error = %u",error);
    }
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)SetLocation:(NSDictionary *)dic
{
	if (dic)
	{
		self.dicInfo = [dic copy];
	}
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
	DDLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
	if (self.dingwei == NO)
	{
		return;
	}
	[self.mapView updateLocationData:userLocation];
	//    DDLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
	if (self.dingwei == NO)
	{
		if (self.dingweiNum == 0)
		{
			[self.mapView updateLocationData:userLocation];

			if (self.dicInfo && ([[self.dicInfo objectForKey:@"Lat"] floatValue] > 0.0f))
			{
				BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
				CLLocationCoordinate2D coor;
				coor.latitude = [[self.dicInfo objectForKey:@"Lat"] floatValue];
				coor.longitude = [[self.dicInfo objectForKey:@"Lng"] floatValue];
				annotation.coordinate = coor;
				annotation.title = [self.dicInfo objectForKey:@"ShopName"];
				[self.mapView addAnnotation:annotation];
				self.mapView.centerCoordinate = coor;
				//                address.text = [dicInfo objectForKey:@"Address"];

				BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
				reverseGeocodeSearchOption.reverseGeoPoint = coor;
				BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];

				if (flag)
				{
					DDLog(@"反geo检索发送成功");
				}
				else
				{
					DDLog(@"反geo检索发送失败");
				}
			} /*else if (dicInfo&&[self NullClear:[dicInfo objectForKey:@"CityName"]]&&[self NullClear:[dicInfo objectForKey:@"AreaName"]]&&[[dicInfo objectForKey:@"CityName"] length]>0&&[[dicInfo objectForKey:@"AreaName"] length]>0){
			   *  cityName =[dicInfo objectForKey:@"CityName"];
			   *  NSString *addr = [dicInfo objectForKey:@"Address"];
			   *  NSString *str;
			   *  if (addr == Nil || addr.length == 0 || [addr isEqual:[NSNull null]]) {
			   *      str = [dicInfo objectForKey:@"AreaName"];
			   *  }else{
			   *      str = [dicInfo objectForKey:@"Address"];
			   *  }
			   *
			   *
			   *  BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
			   *  geocodeSearchOption.city=cityName;
			   *  geocodeSearchOption.address = str;
			   *  BOOL flag = [self.geocodesearch geoCode:geocodeSearchOption];
			   *  if(flag)
			   *  {
			   *      DDLog(@"geo检索发送成功");
			   *  }
			   *  else
			   *  {
			   *      DDLog(@"geo检索发送失败");
			   *  }
			   *
			   *  }*/
			self.dingweiNum = 1;
		}

		return;
	}
	DDLog(@"didUpdateUserLocation lat %f,long %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);

	[self.mapView updateLocationData:userLocation];

	CLGeocoder *Geocoder = [[CLGeocoder alloc] init]; //CLGeocoder用法参加之前博客

	CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
		//        for (CLPlacemark *placemark in place) {
		//
		//            cityName=placemark.locality;
		//
		//
		//            DDLog(@"!!!%@",cityName);
		//
		//
		//            break;
		//
		//        }
	};

	CLLocation *loc = [[CLLocation alloc] initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
	[Geocoder reverseGeocodeLocation:loc completionHandler:handler];

	if (self.dicInfo && ([[self.dicInfo objectForKey:@"Lat"] floatValue] > 0.0f))
	{
		return;
	}
	CLLocationCoordinate2D pt = (CLLocationCoordinate2D) {userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};

	BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
	reverseGeocodeSearchOption.reverseGeoPoint = pt;
	BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];

	if (flag)
	{
		DDLog(@"反geo检索发送成功");
		NSString *str = [NSString stringWithFormat:@"%f", pt.latitude];
		[self.Ldic setObject:str forKey:@"Lat"];

		NSString *str1 = [NSString stringWithFormat:@"%f", pt.longitude];
		[self.Ldic setObject:str1 forKey:@"Lng"];
	}
	else
	{
		DDLog(@"反geo检索发送失败");
	}
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
	DDLog(@"stop locate");
}

//地理编码

#pragma mark 地图手势操作

/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi
{
	//    DDLog(@"onClickedMapPoi-%@",mapPoi.text);
	//    NSString* showmeg = [NSString stringWithFormat:@"您点击了底图标注:%@,\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", mapPoi.text,mapPoi.pt.longitude,mapPoi.pt.latitude, (int)self.mapView.zoomLevel,self.mapView.rotation,self.mapView.overlooking];

	CLLocationCoordinate2D pt = (CLLocationCoordinate2D) {mapPoi.pt.latitude, mapPoi.pt.longitude};

	//    if (_coordinateXText.text != nil && _coordinateYText.text != nil) {
	//        pt = (CLLocationCoordinate2D){[_coordinateYText.text floatValue], [_coordinateXText.text floatValue]};
	//    }
	self.IsUserTap = TRUE;
	BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
	reverseGeocodeSearchOption.reverseGeoPoint = pt;
	BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];

	if (flag)
	{
		DDLog(@"反geo检索发送成功");
		NSString *str = [NSString stringWithFormat:@"%f", mapPoi.pt.latitude];
		[self.Ldic setObject:str forKey:@"Lat"];

		NSString *str1 = [NSString stringWithFormat:@"%f", mapPoi.pt.longitude];
		[self.Ldic setObject:str1 forKey:@"Lng"];
	}
	else
	{
		DDLog(@"反geo检索发送失败");
	}
}

/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
	self.IsUserTap = TRUE;
	CLLocationCoordinate2D pt = (CLLocationCoordinate2D) {coordinate.latitude, coordinate.longitude};

	BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
	reverseGeocodeSearchOption.reverseGeoPoint = pt;
	BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];

	if (flag)
	{
		DDLog(@"反geo检索发送成功");
		NSString *str = [NSString stringWithFormat:@"%f", coordinate.latitude];
		[self.Ldic setObject:str forKey:@"Lat"];

		NSString *str1 = [NSString stringWithFormat:@"%f", coordinate.longitude];
		[self.Ldic setObject:str1 forKey:@"Lng"];
	}
	else
	{
		DDLog(@"反geo检索发送失败");
	}
}

////选中大头针触发
//-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
//{
//
//        control.hidden =NO;
//        customView.hidden = NO;
//    tangkuan = YES;
//    ViewLabel.text = addressStr;
//
//}

//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
	NSString *AnnotationViewID = @"annotationViewID";
	//根据指定标识查找一个可被复用的标注View，一般在delegate中使用，用此函数来代替新申请一个View
	BMKAnnotationView *annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];

	if (annotationView == nil)
	{
		annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
		((BMKPinAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorRed;
		((BMKPinAnnotationView *)annotationView).animatesDrop = NO;
	}

	annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
	annotationView.annotation = annotation;
	annotationView.canShowCallout = TRUE;
	annotationView.image = [UIImage imageNamed:@"client_address_icon.png"];
	return annotationView;
}

//反地理
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	if (error == 0)
	{
        self.isSearch = NO;

		//        cityName = result.addressDetail.city;

		if (self.chengshi == NO)
		{
			self.chengshi = YES;
			return;
		}
		NSArray *array = [NSArray arrayWithArray:self.mapView.annotations];
		[self.mapView removeAnnotations:array];
		array = [NSArray arrayWithArray:self.mapView.overlays];
		[self.mapView removeOverlays:array];
		BMKPointAnnotation *item = [[BMKPointAnnotation alloc] init];
		item.coordinate = result.location;
		item.title = [NSString stringWithFormat:@"%@%@%@", result.addressDetail.district, result.addressDetail.streetName, result.addressDetail.streetNumber];
		//        item.title= @"";
		self.addressStr = [NSString stringWithFormat:@"%@%@%@", result.addressDetail.district, result.addressDetail.streetName, result.addressDetail.streetNumber];

		[self.dataArray removeAllObjects];
		[self.dataArray addObjectsFromArray:result.poiList];

		[self.tableView reloadData];

		[self.mapView addAnnotation: item];

		if (!self.IsUserTap)
		{
			self.mapView.centerCoordinate = result.location;
		}

		if (self.tangkuan == YES)
		{
			//            control.hidden =NO;
			//            customView.hidden = NO;
		}
		self.tangkuan = YES;
	}
	else
	{
		DDLog(@"error = %u", error);
	}
}

//正地理
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	if (error == 0)
	{
		NSArray *array = [NSArray arrayWithArray:self.mapView.annotations];
		[self.mapView removeAnnotations:array];
		array = [NSArray arrayWithArray:self.mapView.overlays];
		[self.mapView removeOverlays:array];
		BMKPointAnnotation *item = [[BMKPointAnnotation alloc] init];
		item.coordinate = result.location;
		item.title = result.address;
		//        item.title = @"";

		DDLog(@"%@", result.address);

//		self.addressStr = result.address;
//
//		if (self.addressStr.length != 0)
//		{
//			DDLog(@"3");
//
//			[self.dataArray addObject:self.addressStr];
//
//			[self.tableView reloadData];
//		}

		[self.mapView addAnnotation:item];
		self.mapView.centerCoordinate = result.location;

		NSString *str = [NSString stringWithFormat:@"%f", item.coordinate.latitude];
		[self.Ldic setObject:str forKey:@"Lat"];

		NSString *str1 = [NSString stringWithFormat:@"%f", item.coordinate.longitude];
		[self.Ldic setObject:str1 forKey:@"Lng"];
		DDLog(@"%@", self.Ldic);
		//
		//        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){item.coordinate.latitude,item.coordinate.longitude};
		//
		//        BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
		//        reverseGeocodeSearchOption.reverseGeoPoint = pt;
		//        BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
		//        if(flag)
		//        {
		//            DDLog(@"反geo检索发送成功");
		//            chengshi = NO;
		//        }
		//        else
		//        {
		//            DDLog(@"反geo检索发送失败");
		//        }
	}
	else
	{
//        DDLog(@"%u",error);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"地址搜索不到！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

//- (void)rightBar:(UINavigationBar *)sender
//{
//	[self.Ldic setObject:self.address.text forKey:@"Address"];
//	DDLog(@"dic:%@", self.Ldic);
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"AddressData" object:self.Ldic];
//	[self.navigationController popViewControllerAnimated:YES];
//}

- (NSString *)NullClear:(id)obj
{
	if ([obj isEqual:[NSNull null]])
	{
		return Nil;
	}
	return (NSString *)obj;
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
