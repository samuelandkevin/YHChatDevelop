//
//  EducationExperienceController.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/10.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    EducationExperience = 0,
    WorkExperience,
} MyExperience;
@interface ExperienceListController : UIViewController

@property (nonatomic, assign) MyExperience experience;


@end
