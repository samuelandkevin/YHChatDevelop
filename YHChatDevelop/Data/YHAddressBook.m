//
//  YHAddressBook.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/1/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHAddressBook.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "YHChatDevelop-Swift.h"


@implementation YHAddressBook

@end


NSArray *getAddressBookContacts() {
    
    if ( kSystemVersion< 9.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSMutableArray *allPerson = [NSMutableArray arrayWithCapacity:CFArrayGetCount(results)];
        
        for(int i = 0; i < CFArrayGetCount(results); i++){
            
            ABRecordRef person = CFArrayGetValueAtIndex(results, i);
            NSString *text = @"";
            YHABUserInfo *userInfo = [YHABUserInfo new];
            //读取firstname
            NSString *personName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            text = [text stringByAppendingFormat:@"姓名：%@\n",personName];
            //读取lastname
            NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            text = [text stringByAppendingFormat:@"%@\n",lastname];
            NSString *nick = lastname;
            if (!nick) {
                nick = personName;
            }
            else if (personName) nick = [nick stringByAppendingString:personName];
            userInfo.userName = nick;
            
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int k = 0; k<ABMultiValueGetCount(phone); k++)
            {
                //获取电话Label
                CFStringRef tempValue = ABMultiValueCopyLabelAtIndex(phone, k);
                NSString * personPhoneLabel = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(tempValue);
                //获取該Label下的电话值
                NSString * personPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                userInfo.mobilephone = personPhone;
                text = [text stringByAppendingFormat:@"%@:%@\n",personPhoneLabel,personPhone];
                
            }
            CFRelease(phone);
            
            if (userInfo.mobilephone) {
                userInfo.mobilephone = [userInfo.mobilephone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                userInfo.mobilephone = [userInfo.mobilephone stringByReplacingOccurrencesOfString:@"+" withString:@""];
            }
            
            //读取照片
            if (ABPersonHasImageData(person) ) {
                NSData *image = (__bridge_transfer NSData*)ABPersonCopyImageData(person);
                userInfo.avatarImage = [UIImage imageWithData:image];
            }
            
            [allPerson addObject:userInfo];
            
            DDLog(@"text = %@", text);
        }
        CFRelease(results);
        CFRelease(addressBook);
        return allPerson;
 #pragma clang diagnostic pop       
    }else{
        NSError *error = nil;
        CNContactStore *contactStore = [[CNContactStore alloc]init];
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //创建获取联系人的请求
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        //遍历查询
        NSMutableArray *allPerson = [NSMutableArray array];
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact,  BOOL * _Nonnull stop) {
            if (!error) {
                YHABUserInfo *userInfo = [YHABUserInfo new];
                NSString *familyName = contact.familyName;
                NSString *givenName = contact.givenName;
                NSString *phoneNum  = ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue;
                phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"+" withString:@""];
                DDLog(@"familyName = %@", familyName);   //姓
                DDLog(@"givenName = %@", givenName);     //名字
                DDLog(@"phoneNumber = %@", phoneNum);//电话
               
                
                if (!givenName) {
                    givenName = @"";
                }
                if (!familyName) {
                    familyName = @"";
                }
                NSString *fullName = [NSString stringWithFormat:@"%@%@",familyName,givenName];
                if (!fullName.length) {
                     fullName = nil;
                }
                userInfo.userName = fullName;
                userInfo.mobilephone = phoneNum;
                
                [allPerson addObject:userInfo];
                
            }else{
                DDLog(@"error:%@", error.localizedDescription);
            }
        }];
        return allPerson;
        
    }
}
