//
//  MySearchResultModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/13.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MySearchResultModel : NSObject

@property(nonatomic,strong) NSString * city;
@property(nonatomic,strong) NSString * key;
@property(nonatomic,strong) NSString * district;
@property(nonatomic,assign) CLLocationDistance distance;
@property(nonatomic, assign) CLLocationCoordinate2D pt;

@end
