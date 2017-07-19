//
//  CellChatCheckinRight.m
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatCheckinRight.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "UIImage+Extension.h"
#import "YHPhotoBrowserView.h"
#import "YHChatImageView.h"
#import "YHCheckinBtn.h"

@interface CellChatCheckinRight()<YHPhotoBrowserViewDelegate>

@property (nonatomic,strong) YHChatImageView *imgvContent;
@property (nonatomic,strong) YHCheckinBtn    *btnCheckin;
@property (nonatomic,strong) UILabel         *lbMsg;
@property (nonatomic,strong) UILabel         *lbPosition;

@end

@implementation CellChatCheckinRight

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _imgvContent = [YHChatImageView new];
    _imgvContent.isReceiver = YES;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.userInteractionEnabled = YES;
    [_imgvContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnContent:)]];
    _imgvContent.image = [UIImage imageArrowWithSize:oriImg.size image:oriImg isSender:YES];
    [self.contentView addSubview:_imgvContent];
    
    WeakSelf
    _imgvContent.retweetImageBlock = ^(UIImage *image){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetImage:inRightCheckinCell:)]) {
            [weakSelf.delegate retweetImage:image inRightCheckinCell:weakSelf];
        }
    };
    
    _imgvContent.withDrawImageBlock = ^(UIImage *image){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(withDrawImage:inRightCheckinCell:)]) {
            [weakSelf.delegate withDrawImage:image inRightCheckinCell:weakSelf];
        }
    };
    
    _btnCheckin = [YHCheckinBtn new];
    [self.contentView addSubview:_btnCheckin];
    
    _lbMsg = [UILabel new];
    _lbMsg.textColor     = [UIColor whiteColor];
    _lbMsg.numberOfLines = 0;
    _lbMsg.font          = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_lbMsg];
    
    _lbPosition = [UILabel new];
    _lbPosition.textColor = RGBCOLOR(155, 155, 155);
    _lbPosition.font      = [UIFont systemFontOfSize:11.0];
    [self.contentView addSubview:_lbPosition];
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self layoutCommonUI];
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
    [_lbMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvContent.mas_left).offset(5);
        make.top.equalTo(weakSelf.imgvContent.mas_top).offset(5);
        make.right.lessThanOrEqualTo(weakSelf.imgvContent.mas_right).offset(5);
        make.bottom.lessThanOrEqualTo(weakSelf.imgvContent.mas_bottom);
    }];
    
    [self.activityV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.imgvSendMsgFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [_btnCheckin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvContent.mas_right);
        make.top.equalTo(weakSelf.imgvContent.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 20));
    }];
    
    [_lbPosition mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.btnCheckin.mas_left).offset(5);
        make.centerY.equalTo(weakSelf.btnCheckin.mas_centerY);
        make.left.greaterThanOrEqualTo(weakSelf.contentView).offset(50);
    }];
    
    self.hyb_lastViewInCell = _btnCheckin;
    self.hyb_bottomOffsetToCell = 5;
}

#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
    //            [_delegate tapRightAvatar:nil];
    //        }
    //    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    [super onImgSendMsgFailGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
    //            [_delegate tapSendMsgFailImg];
    //        }
    //    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    self.lbName.text    = self.model.speakerName;
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    //消息图片下载
    if (self.model.msgContent && self.model.msgType == 1) {
        if (self.model.imageMsg) {
            _imgvContent.image = self.model.imageMsg;
        }else{
            NSURL *thumbUrl = [NSURL URLWithString:self.model.checkinModel.thumbPicUrl];
            [_imgvContent sd_setImageWithURL:thumbUrl placeholderImage:[UIImage imageNamed:@"chat_img_defaultPhoto"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
            }];
            
            _lbMsg.text      = self.model.checkinModel.msg;
            _lbPosition.text = self.model.checkinModel.position;
        }
    }
}

#pragma mark - Private

#pragma mark - Gesture
- (void)gestureOnContent:(UIGestureRecognizer *)aGes{
    if (aGes.state == UIGestureRecognizerStateEnded) {
        YHPhotoBrowserView *browser = [[YHPhotoBrowserView alloc] init];
        browser.currentImageView = _imgvContent;
        browser.delegate = self;
        [browser show];
    }
}

#pragma mark - @protocol YHPhotoBrowserViewDelegate

- (NSURL *)photoBrowser:(YHPhotoBrowserView *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:self.model.checkinModel.oriPicUrl];
}

- (UIImage *)photoBrowser:(YHPhotoBrowserView *)browser placeholderImageForIndex:(NSInteger)index
{
    return _imgvContent.image;
}

#pragma mark - Life
- (void)dealloc{
    //DDLog(@"%s dealloc",__func__);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
