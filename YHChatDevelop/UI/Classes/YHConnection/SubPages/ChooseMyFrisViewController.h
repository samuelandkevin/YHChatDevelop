//
//  ChooseMyFrisViewController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/7/14.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  选择我的好友

#import <UIKit/UIKit.h>
#import "YHWorkGroup.h"
#import "YHUserInfo.h"

typedef NS_ENUM(int,SHareType){
    SHareType_Card = 1,//分享名片
    SHareType_Dyn ,    //分享动态
};

@interface ChooseMyFrisViewController : UIViewController

@property (nonatomic,assign) SHareType shareType;
@property (nonatomic,strong) YHWorkGroup *shareDynToPWFris;   //分享动态给税道好友
@property (nonatomic,strong) YHUserInfo *shareCardToPWFris;  //分享名片给税道好友
@end
