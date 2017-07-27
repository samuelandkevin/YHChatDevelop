//
//  YHChooseFriVC.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/10/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  选择好友

#import <UIKit/UIKit.h>
#import "ZJScrollPageViewDelegate.h"
@class YHChatModel;

//控制器页面类型(备注:重用VC,通过pagetype区分)
typedef NS_ENUM(NSInteger,PageTypeOptions){
    PageType_CreatGroupChat,    //发起群聊
    PageType_AddGroupChatMember,//添加群成员
    PageType_RetWeetMsg         //转发消息
};

@interface YHChooseFriVC : UIViewController<ZJScrollPageViewChildVcDelegate>

@property (nonatomic,assign) PageTypeOptions pageType;
//邀请成员进入群聊用到
@property (nonatomic,copy) NSString *groupId;
@property (nonatomic,copy) NSString *barTitle;


/**
 选择好友回调

 @param complete selFris（YHChatModel*）
 */
- (void)selectFrisComplete:(void(^)(NSArray <YHChatModel *>*selFris))complete;
@end
