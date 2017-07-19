//
//  YHAddressBook.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHAddressBook : NSObject

@end


/**
 获取通讯录所有联系人，数组元素为 HHUserInfo 类型
 */
NSArray *getAddressBookContacts();
