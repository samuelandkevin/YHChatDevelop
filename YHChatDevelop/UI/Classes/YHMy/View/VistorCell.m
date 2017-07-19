//
//  VistorCell.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/5/9.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "VistorCell.h"
#import "YHUserInfoManager.h"
#import "NSDate+Extension.h"
#import "UIImageView+WebCache.h"

@interface VistorCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIView *viewVeticalLine;

- (IBAction)addFriend:(UIButton *)sender;

@end

@implementation VistorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.avatar.layer.cornerRadius = self.avatar.layer.bounds.size.width/2;
//    self.avatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addFriend:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onAddFriendInCell:)]) {
        [_delegate onAddFriendInCell:self];
    }
    
}


- (void)setUserInfo:(YHUserInfo *)userInfo{
    
    _userInfo = userInfo;
    
    self.avatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    [self.avatar sd_setImageWithURL:userInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload|SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL *targetURL) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error == nil) {
            
        }else{
          
        }
    }];
    
    if (_userInfo.userName.length) {
         self.name.text    = _userInfo.userName;
    }
    else{
         self.name.text    = @"匿名用户";
    }
    
    if (!_userInfo.userName.length || !_userInfo.job.length) {
        self.viewVeticalLine.hidden = YES;
    }
    else{
        self.viewVeticalLine.hidden = NO;
    }
    
    self.company.text = _userInfo.company;
    self.position.text= _userInfo.job;
    self.time.text    = _userInfo.visitTime;
    if ([_userInfo.uid isEqualToString:[YHUserInfoManager sharedInstance].userInfo.uid]) {
        self.addFriendBtn.hidden  = YES;
        self.imgvAddFriend.hidden = YES;
    }else{
        self.addFriendBtn.hidden  = NO;
        self.imgvAddFriend.hidden = NO;
    }
    
    
    if (_userInfo.friShipStatus == FriendShipStatus_isMyFriend)
    {
        self.addFriendBtn.hidden  = YES;
        self.imgvAddFriend.hidden = YES;
    }
    else
    {
        if (_userInfo.addFriStatus == AddFriendStatus_IAddOtherPerson)
        {
            self.addFriendBtn.hidden  = YES;
            self.imgvAddFriend.hidden = YES;
        }
        else{
            self.addFriendBtn.hidden  = NO;
            self.imgvAddFriend.hidden = NO;
        }
       
    }
}

@end
