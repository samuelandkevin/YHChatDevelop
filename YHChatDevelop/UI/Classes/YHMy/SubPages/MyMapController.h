//
//  MyMapController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/12.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Search/BMKGeoCodeSearch.h>
#import <BaiduMapAPI_Search/BMKSuggestionSearch.h>

@interface MyMapController : UIViewController <BMKLocationServiceDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, UITextFieldDelegate>
@property (nonatomic, strong) BMKSuggestionSearch *search;
@property (nonatomic, assign) BOOL IsUserTap;
@property (nonatomic, strong) NSDictionary *dicInfo;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) UITextField *address;
//@property (nonatomic, assign) BOOL addressYes;

- (void)SetLocation:(NSDictionary *)dic;

@end
