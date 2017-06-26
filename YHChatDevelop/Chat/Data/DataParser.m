//
//  DataParser.m
//  MyProject
//
//  Created by YHIOS002 on 16/4/10.
//  Copyright © 2016年 kun. All rights reserved.
//

#import "DataParser.h"
#import "NSDate+Extension.h"
#import "YHSqilteConfig.h"

@interface DataParser()
@property (nonatomic,assign)CGFloat addFontSize;
@end

@implementation DataParser

+ (DataParser *)shareInstance{
    static DataParser *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[DataParser alloc] init];
    });
    return g_instance;
}

//解析用户列表
- (NSArray <YHUserInfo*>*)parseUserListWithListData:(NSArray<NSDictionary*> *)listData curReqPage:(int)curReqPage{
    NSMutableArray *userArray = [NSMutableArray array];
    if (listData && [listData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in listData) {
            YHUserInfo *userInfo = [self parseUserInfo:dict curReqPage:curReqPage isSelf:NO];
            [userArray addObject:userInfo];
        }
    }
    return userArray;
}


//解析用户模型
- (YHUserInfo*)parseUserInfo:(NSDictionary *)dict curReqPage:(int)curReqPage isSelf:(BOOL)isSelf{
    
    YHUserInfo *userInfo     = [YHUserInfo new];
    userInfo.isSelfModel     = isSelf;
    userInfo.isRegister      = YES;
    userInfo.uid             = dict[@"id"];
    userInfo.mobilephone     = dict[@"mobile"];
    userInfo.userName        = dict[@"name"];
    userInfo.province        = dict[@"province"];
    userInfo.workCity        = dict[@"city"];
    userInfo.taxAccount      = dict[@"userName"];
    userInfo.dynamicCount    = [dict[@"dynamic_count"] intValue];
    userInfo.visitTime       = dict[@"visitor_time"];
    NSString *jobTagsString  = dict[@"workMark"];
    
    if (jobTagsString.length && jobTagsString) {
        
        NSArray *jobTags=  [jobTagsString componentsSeparatedByString:@","];
        if (jobTags) {
            userInfo.jobTags = [NSMutableArray arrayWithArray:jobTags];
        }
    }
    
    
    userInfo.workLocation    = dict[@"location"];
    userInfo.intro       = dict[@"description"];
    NSString *strAvatar  = dict[@"profileImageUrl"];
    if (strAvatar.length > 4) {
        userInfo.avatarUrl  = [NSURL URLWithString:strAvatar];
        
    }
    userInfo.company     = dict[@"company"];
    userInfo.job         = dict[@"job"];
    userInfo.industry    = dict[@"indusry"];
    NSString *gender     = dict[@"gender"];
    if ([gender isEqualToString:@"1"]) {
        //1 是男, 0 是 女
        userInfo.sex    = Gender_Man ;
    }else{
        userInfo.sex    = Gender_Women;
    }
    
    userInfo.loginTime            = dict[@"createdDate"];
    NSArray *workExp     = dict[@"professional"];
    if ([workExp isKindOfClass:[NSArray class]] && workExp.count) {
        userInfo.workExperiences = [self parseWorkExp:workExp];
    }
    NSArray *eduExp        = dict[@"education"];
    if ([eduExp isKindOfClass:[NSArray class]] && eduExp.count) {
        userInfo.eductaionExperiences = [self parseEduExp:eduExp];
    }
    userInfo.fansCount     = [dict[@"focusCount"] intValue];
    userInfo.isFollowed    = [dict[@"isFocus"] boolValue];
    userInfo.friShipStatus = [dict[@"friendStatus"] intValue];
    
    NSString * addFriStauts = dict[@"is_sqf"];
    
    if( addFriStauts.length)
    {
        if ([addFriStauts intValue] == 0)
        {
            userInfo.addFriStatus =  AddFriendStatus_otherPersonAddMe;
        }
        else if([addFriStauts intValue] == 1)
        {
            userInfo.addFriStatus =  AddFriendStatus_IAddOtherPerson;
        }
    }
    
    userInfo.identity   = [dict[@"type"] intValue];
    userInfo.department = dict[@"deptName"];
    userInfo.curReqPage = curReqPage;
    userInfo.isInMyBlackList = [dict[@"is_black_list"] boolValue];
//    userInfo.companyID  = dict[@"companyId"];
    
    return userInfo;
    
}


- (NSMutableArray *)parseWorkExp:(NSArray *)workExp{
    
    NSMutableArray *maWorkExp = [NSMutableArray arrayWithCapacity:workExp.count];
    for (NSDictionary *dict in workExp) {
        YHWorkExperienceModel *model = [YHWorkExperienceModel new];
        model.position          = dict[@"job"];
        model.company           = dict[@"company"];
        model.beginTime         = dict[@"startDate"];
        model.endTime           = dict[@"endDate"];
        model.workExpId         = dict[@"id"];
        model.moreDescription   = dict[@"description"];
        [maWorkExp addObject:model ];
    }
    
    if ([maWorkExp count] >= 2) {
        
        [maWorkExp sortUsingComparator:^NSComparisonResult(YHWorkExperienceModel *obj1, YHWorkExperienceModel *obj2) {
            
            if ([NSDate compareWithBeginDateString:obj1.endTime andEndDateString:obj2.beginTime])
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
            
        }];
        
    }
    
    
    return maWorkExp;
    
}

- (NSMutableArray *)parseEduExp:(NSArray *)eduExp{
    
    NSMutableArray *maEduExp = [NSMutableArray arrayWithCapacity:eduExp.count];
    for (NSDictionary *dict in eduExp) {
        YHEducationExperienceModel *model = [YHEducationExperienceModel new];
        model.school            = dict[@"university"];
        model.major             = dict[@"major"];
        model.educationBackground   = dict[@"degree"];
        model.beginTime         = dict[@"startDate"];
        model.endTime           = dict[@"endDate"];
        model.eduExpId          = dict[@"id"];
        model.moreDescription   = dict[@"description"];
        [maEduExp addObject:model ];
    }
    
    if ([maEduExp count] >= 2) {
        
        [maEduExp sortUsingComparator:^NSComparisonResult(YHEducationExperienceModel *obj1, YHEducationExperienceModel *obj2) {
            
            if ([NSDate compareWithBeginDateString:obj1.endTime andEndDateString:obj2.beginTime])
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedAscending;
            }
            
        }];
        
    }
    
    return maEduExp;
    
}



// 解析聊天记录Model
- (NSArray<YHChatModel *>*)parseChatLogWithListData:(NSArray<NSDictionary *>*)listData{
    
    NSMutableArray *chatLogArray = [NSMutableArray new];
    if ([listData isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dict in listData) {
            YHChatModel *model =  [self parseOneChatLogWithDict:dict];
            [chatLogArray addObject:model];
        }
        
    }
    return chatLogArray;
}

- (YHChatModel *)parseOneChatLogWithDict:(NSDictionary *)dict{
    YHChatModel *model = [YHChatModel new];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        model.chatId = dict[@"id"];
        model.chatType    = [dict[@"isGroupChat"] intValue];
        model.content     = dict[@"content"];
        model.msgContent  = dict[@"msgContent"];
        model.createTime  = dict[@"createTime"];
        model.updateTime  = dict[@"updateTime"];
        model.audienceDept= dict[@"audienceDept"];
        model.audienceId  = dict[@"audienceId"];
        NSString *audienceHead   = dict[@"audienceHead"];
        if (audienceHead) {
            model.audienceAvatar = [NSURL URLWithString:audienceHead];
        }
        
        model.audienceName     = dict[@"audienceName"];
        NSString *speakerHead  = dict[@"speakerHead"];
        if (speakerHead) {
            NSString *thumbPic = [NSString stringWithFormat:@"%@.w80x80.png",speakerHead];
            model.speakerAvatar    = [NSURL URLWithString:thumbPic];
            model.speakerAvatarOri = [NSURL URLWithString:speakerHead];
        }
        model.speakerDept  = dict[@"speakerDept"];
        model.speakerName  = dict[@"speakerName"];
        model.speakerId    = dict[@"speakerId"];
        model.isRead       = [dict[@"isRead"] intValue]?YES:NO;
        model.timestamp    = [dict[@"cursor"] intValue];
        model.msgType      = [dict[@"msgType"] intValue];
        model.direction    = [dict[@"direction"] intValue];
        model.status       = [dict[@"status"] intValue];
        if (model.msgType == YHMessageType_Doc) {
           model.fileModel = [self parseFileModelWithfileStr:model.msgContent];
        }
    }
    return model;
}

//解析群成员
- (NSArray<YHGroupMember*>*)parseGroupMembersWithList:(NSArray <NSDictionary*>*)listData{
    NSMutableArray *groupMembers = [NSMutableArray new];
    if ([listData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in listData) {
            YHGroupMember *model = [self parseGroupMemberWithDict:dict];
            [groupMembers addObject:model];
        }
    }
    return groupMembers;
}


//解析一个YHGroupMember
- (YHGroupMember *)parseGroupMemberWithDict:(NSDictionary *)dict{
    YHGroupMember *model = [YHGroupMember new];
    model.sessionID      = dict[@"id"];
    model.groupID        = dict[@"groupId"];
    model.userID         = dict[@"memberUserId"];
    model.userName       = dict[@"memberName"];
    model.createdDate    = dict[@"createdDate"];
    model.updatedDate    = dict[@"updatedDate"];
    model.avtarUrl       = dict[@"userHead"];
    return model;
}

//解析群列表
- (NSArray<YHChatGroupModel *>*)parseGroupListWithListData:(NSArray<NSDictionary *>*)listData{
    NSMutableArray *groupList = [NSMutableArray new];
    if ([listData isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dict in listData) {
            YHChatGroupModel *model =  [self parseGroupModelWithDict:dict];
            [groupList addObject:model];
        }
        
    }
    return groupList;
}

//解析群Model
- (YHChatGroupModel *)parseGroupModelWithDict:(NSDictionary *)dict{
    YHChatGroupModel *model = [YHChatGroupModel new];
    model.groupName = dict[@"groupName"];
    model.groupDesc = dict[@"groupDesc"];
    NSString *iconStr = dict[@"groupIconUrl"];
    NSMutableArray *groupIconUrl = [NSMutableArray new];
    if (iconStr) {
        NSArray *urlStrArr = [iconStr componentsSeparatedByString:@","];
        for (NSString *urlStr in urlStrArr) {
            NSURL *iconUrl = [NSURL URLWithString:urlStr];
            if (iconUrl) {
                [groupIconUrl addObject:iconUrl];
            }
        }
    }
    model.groupIconUrl = groupIconUrl;
    model.groupLabel = dict[@"groupLabel"];
    model.groupState = dict[@"groupState"];
    model.groupID = dict[@"id"];
    model.memberCount = [dict[@"memberCount"] intValue];
    
    NSArray *headUrls = dict[@"memberHeadUrls"];
    NSMutableArray *memberHeadUrls = [NSMutableArray new];
    if ([headUrls isKindOfClass:[NSArray class]]) {
        for (NSString *urlStr in headUrls) {
            NSURL *url = [NSURL URLWithString:urlStr];
            if (url) {
                [memberHeadUrls addObject:url];
            }
        }
    }
    model.memberHeadUrls = memberHeadUrls;
    model.members = dict[@"members"];
    model.updatedDate = dict[@"updatedDate"];
    model.createdDate = dict[@"createdDate"];
    model.createdID = dict[@"createdId"];
    model.createdName = dict[@"createdName"];
    return model;
}

//解析聊天列表
- (NSArray<YHChatListModel *>*)parseChatListWithListData:(NSArray<NSDictionary *>*)listData{
    NSMutableArray *groupList = [NSMutableArray new];
    if ([listData isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *dict in listData) {
            YHChatListModel *model =  [self parseChatListModelWithDict:dict];
            [groupList addObject:model];
        }
        
    }
    return groupList;
}

//解析一个YHChatListModel
- (YHChatListModel *)parseChatListModelWithDict:(NSDictionary *)dict{
    YHChatListModel *model = [YHChatListModel new];
    model.chatId      = dict[@"id"];
    model.isStickTop  = [dict[@"isStickTop"] boolValue];
    model.isGroupChat = [dict[@"isGroupChat"] boolValue];
    model.memberCount = [dict[@"memberCount"] intValue];
    model.lastContent = dict[@"lastContent"];
    model.msgType     = [dict[@"msgType"] intValue];
    model.userId      = dict[@"userId"];
    model.sessionUserId = dict[@"sessionUserId"];
    model.creatTime     = dict[@"createTime"];
    model.sessionUserName = dict[@"sessionUserName"];
    model.unReadCount   = [dict[@"isRead"] intValue];
    model.groupName     = dict[@"groupName"];
    model.lastCreatTime = dict[@"lastCreatTime"];
    
    NSString *headsStr = dict[@"sessionUserHead"];
    NSMutableArray *sessionUserHeadUrl = [NSMutableArray new];
    if (headsStr) {
        NSArray *urlStrArr = [headsStr componentsSeparatedByString:@","];
        for (NSString *urlStr in urlStrArr) {
            NSURL *headUrl = [NSURL URLWithString:urlStr];
            if (headUrl) {
                [sessionUserHeadUrl addObject:headUrl];
            }
        }
    }
    
    model.sessionUserHead = sessionUserHeadUrl;
    model.msgId           = dict[@"msgId"];
    model.status          = [dict[@"status"] intValue];
    model.updateTime      = dict[@"updateTime"];
    return model;
}


- (YHFileModel *)parseFileModelWithfileStr:(NSString *)fileStr{
    YHFileModel *fileModel = [YHFileModel new];
    if (fileStr) {
        NSString *fileMsg = [fileStr stringByReplacingOccurrencesOfString:@"file(" withString:@""];
        NSUInteger urlLocationEnd   = [fileMsg rangeOfString:@")"].location;
        NSUInteger urlLength = urlLocationEnd;
        NSString *urlStr;
        NSString *ext;
        if (urlLocationEnd != NSNotFound && urlLength > 0) {
            urlStr = [fileMsg substringWithRange:NSMakeRange(0, urlLength)];
            ext = urlStr.pathExtension;
            
        }
        NSString *fileName;
        fileName = [fileMsg stringByReplacingOccurrencesOfString:urlStr withString:@""];
        fileName = [fileName substringFromIndex:2];
        fileName = [fileName substringWithRange:NSMakeRange(0, fileName.length-1)];
        fileModel.filePathInServer = urlStr;
        fileModel.fileName = fileName;
        fileModel.ext   = ext;
        
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",OfficeDir,[urlStr lastPathComponent]]];
        fileModel.status = exist ? FileStatus_HasDownLoaded:FileStatus_UnDownLoaded;
        fileModel.filePathInLocal = exist?[NSString stringWithFormat:@"%@/%@",OfficeDir,[urlStr lastPathComponent]]:nil;
    }
    return fileModel;
}


@end
