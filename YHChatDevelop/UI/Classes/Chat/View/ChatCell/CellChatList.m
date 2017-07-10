//
//  CellChatList.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatList.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "YHChatListModel.h"
#import "YHGroupIconView.h"
#import "YHChatServiceDefs.h"


#define kGroupIconW 50
#define kUnReadMsgW 18
@interface CellChatList()

@property (nonatomic,strong) UILabel *lbTime;
@property (nonatomic,strong) UILabel *lbName;
@property (nonatomic,strong) UIImageView *imgvAvatar;
@property (nonatomic,strong) UILabel *lbContent;
@property (nonatomic,strong) UILabel *lbNewMsg;
@property (nonatomic,strong) UIView  *viewBotLine;
@property (nonatomic,strong) YHGroupIconView *imgvGroupIcon;
@property (nonatomic,strong) UILabel  *lbUnReadMsgGroup;  //群聊未读消息
@property (nonatomic,strong) UILabel  *lbUnReadMsgPrivate;//私聊未读消息
@end


@implementation CellChatList

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _imgvAvatar = [UIImageView new];
    _imgvAvatar.userInteractionEnabled = YES;
    [_imgvAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarGesture:)]];
    _imgvAvatar.layer.cornerRadius  = 2.0;
    _imgvAvatar.layer.masksToBounds = YES;
    _imgvAvatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    [self.contentView addSubview:_imgvAvatar];
    
    _imgvGroupIcon = [YHGroupIconView new];
    _imgvGroupIcon.containerW = kGroupIconW;
    _imgvGroupIcon.layer.cornerRadius  = 2;
    _imgvGroupIcon.layer.masksToBounds = YES;
    _imgvGroupIcon.backgroundColor = RGBCOLOR(221, 222, 224);
    [self.contentView addSubview:_imgvGroupIcon];
    
    
    _lbUnReadMsgGroup = [UILabel new];
    _lbUnReadMsgGroup.textColor = [UIColor whiteColor];
    _lbUnReadMsgGroup.textAlignment = NSTextAlignmentCenter;
    _lbUnReadMsgGroup.font = [UIFont systemFontOfSize:12.0];
    _lbUnReadMsgGroup.backgroundColor = [UIColor redColor];
    _lbUnReadMsgGroup.layer.cornerRadius  = kUnReadMsgW/2;
    _lbUnReadMsgGroup.layer.masksToBounds = YES;
    _lbUnReadMsgGroup.hidden = YES;
    [self.contentView addSubview:_lbUnReadMsgGroup];
    
    _lbUnReadMsgPrivate = [UILabel new];
    _lbUnReadMsgPrivate.textColor = [UIColor whiteColor];
    _lbUnReadMsgPrivate.textAlignment = NSTextAlignmentCenter;
    _lbUnReadMsgPrivate.font = [UIFont systemFontOfSize:12.0];
    _lbUnReadMsgPrivate.backgroundColor = [UIColor redColor];
    _lbUnReadMsgPrivate.layer.cornerRadius  = kUnReadMsgW/2;
    _lbUnReadMsgPrivate.layer.masksToBounds = YES;
    _lbUnReadMsgPrivate.hidden = YES;
    [self.contentView addSubview:_lbUnReadMsgPrivate];
    
    _lbNewMsg = [UILabel new];
    _lbNewMsg.backgroundColor = [UIColor redColor];
    _lbNewMsg.textAlignment = NSTextAlignmentCenter;
    _lbNewMsg.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_lbNewMsg];
    
    _lbTime = [UILabel new];
    _lbTime.textColor = [UIColor grayColor];
    _lbTime.textAlignment = NSTextAlignmentRight;
    _lbTime.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_lbTime];
    
    _lbName = [UILabel new];
    _lbName.textColor = [UIColor blackColor];
    _lbName.textAlignment = NSTextAlignmentLeft;
    _lbName.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_lbName];
    
    

    _lbContent = [UILabel new];
    
    //-5-AvatarWidth-10-15-5-10-AvatarWidth
    _lbContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 133;
    _lbContent.textColor = RGBCOLOR(155, 155, 155);
    _lbContent.textAlignment = NSTextAlignmentLeft;
    _lbContent.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_lbContent];
    
    
    _viewBotLine = [UIView new];
    _viewBotLine.backgroundColor = RGBCOLOR(222, 222, 222);
    [self.contentView addSubview:_viewBotLine];
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    
    
    [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kGroupIconW);
        make.centerY.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.contentView).offset(10);
    }];
    
    [_imgvGroupIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kGroupIconW);
        make.centerY.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.contentView).offset(10);
    }];
    
    [_lbUnReadMsgPrivate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.imgvAvatar.mas_centerX).offset(kGroupIconW/2-kUnReadMsgW/4);
        make.centerY.equalTo(weakSelf.imgvAvatar.mas_centerY).offset(-kGroupIconW/2+kUnReadMsgW/4);
        make.width.mas_greaterThanOrEqualTo(kUnReadMsgW);
        make.height.mas_equalTo(kUnReadMsgW);
    }];
    
    
    [_lbUnReadMsgGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.imgvGroupIcon.mas_centerX).offset(kGroupIconW/2-kUnReadMsgW/4);
        make.centerY.equalTo(weakSelf.imgvGroupIcon.mas_centerY).offset(-kGroupIconW/2+kUnReadMsgW/4);
        make.width.mas_greaterThanOrEqualTo(kUnReadMsgW);
        make.height.mas_equalTo(kUnReadMsgW);
    }];
    
    
    [_lbName setContentHuggingPriority:248 forAxis:UILayoutConstraintAxisHorizontal];
    [_lbName setContentCompressionResistancePriority:748 forAxis:UILayoutConstraintAxisHorizontal];
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.contentView).offset(15);
        make.right.equalTo(weakSelf.lbTime.mas_left);
    }];
    
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.top.equalTo(weakSelf.lbName.mas_top);
    }];
    
    
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(10);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-10);
    }];
    
    [_viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
}

#pragma mark - Gesture
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded) {
      
    }
}

#pragma mark - Setter
- (void)setModel:(YHChatListModel *)model{
    _model = model;
    _lbName.text = _model.sessionUserName;
    
    
    _lbTime.text = _model.creatTime;
    if(_model.status == 1){
        //撤回
        NSString *msg = @"撤回一条消息";
        switch (_model.msgType) {
            case   YHMessageType_Image:
                msg = @"撤回一张图片";
                break;
            case   YHMessageType_Voice:
                msg = @"撤回一条语音";
                break;
            case  YHMessageType_Doc:
                msg = @"撤回一个文件";
                break;
            default:
                break;
        }
        _lbContent.text = msg;
    }else{
        //未撤回
        NSString *msg = _model.lastContent;
        switch (_model.msgType) {
            case   YHMessageType_Image:
                msg = @"[图片]";
                break;
            case   YHMessageType_Voice:
                msg = @"[语音]";
                break;
            case  YHMessageType_Doc:
                msg = @"[文件]";
                break;
            default:
                break;
        }

        _lbContent.text = msg;
    }
    
    if (_model.isGroupChat) {
        _imgvGroupIcon.picUrlArray = _model.sessionUserHead;
        _imgvGroupIcon.hidden    = NO;
        _imgvAvatar.hidden       = YES;
        _lbUnReadMsgPrivate.hidden = YES;
        if (_model.unReadCount) {
            _lbUnReadMsgGroup.hidden = NO;
            _lbUnReadMsgGroup.text   = [NSString stringWithFormat:@"%u  ",_model.unReadCount];
        }else{
            _lbUnReadMsgGroup.hidden = YES;
        }
       

    }else{
        [_imgvAvatar sd_setImageWithURL:_model.sessionUserHead[0] placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
        _imgvAvatar.hidden         = NO;
        _imgvGroupIcon.hidden      = YES;
        _lbUnReadMsgGroup.hidden   = YES;
        if (_model.unReadCount) {
             _lbUnReadMsgPrivate.hidden = NO;
             _lbUnReadMsgPrivate.text   = [NSString stringWithFormat:@"%u",_model.unReadCount];
        }else{
            _lbUnReadMsgPrivate.hidden  = YES;
        }
       

    }
    
    
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
