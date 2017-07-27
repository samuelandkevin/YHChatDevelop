//
//  CellForComment.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/7.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "CellForComment.h"

#import "NSDate+Extension.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "YHExpressionHelper.h"

@interface CellForComment()

@property (nonatomic,strong)UIImageView *imgvAvatar;
@property (nonatomic,strong)UILabel     *labelName;
@property (nonatomic,strong)UILabel     *labelPubTime;
@property (nonatomic,strong)YYLabel     *labelContent;
@property (nonatomic,strong)UIView *viewBotLine;
@end

@implementation CellForComment

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup{
    
    // Initialization code
    UILongPressGestureRecognizer *guesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:guesture];
    
   
    self.imgvAvatar = [UIImageView new];
//    self.imgvAvatar.layer.cornerRadius = 20;
//    self.imgvAvatar.layer.masksToBounds = YES;
    self.imgvAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatar:)];
    [self.imgvAvatar addGestureRecognizer:tapGuesture];
    [self.contentView addSubview:self.imgvAvatar];
    
    self.labelName  = [UILabel new];
    self.labelName.font = [UIFont systemFontOfSize:12.0f];
    self.labelName.textColor = RGB16(0x303030);
    [self.contentView addSubview:self.labelName];
    
    self.labelPubTime = [UILabel new];
    self.labelPubTime.font = [UIFont systemFontOfSize:10.0f];
    self.labelPubTime.textColor = RGBCOLOR(120, 120, 120);
    [self.contentView addSubview:self.labelPubTime];
    
    self.labelContent = [YYLabel new];
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    self.labelContent.font = [UIFont systemFontOfSize:(12.0f+addFontSize)];
//    self.labelContent.font = [UIFont fontWithName:@"Heiti SC" size:(12+addFontSize)];
    self.labelContent.numberOfLines = 0;
    self.labelContent.textColor = RGBCOLOR(120, 120, 120);
    [self.contentView addSubview:self.labelContent];
    WeakSelf
    _labelContent.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        
        if (weakSelf.model.toReplyCommentData)
        {
            NSString *replyUser = [NSString stringWithFormat:@"回复 @%@",weakSelf.model.toReplyCommentData.authorInfo.userName];
            if ([text.string hasPrefix:replyUser]) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onReplyUserInCell:)]) {
                    [weakSelf.delegate onReplyUserInCell:weakSelf];
                }
            }
        }
        
        int linkType = 0;
        if([text.string hasPrefix:@"http"]){
            linkType = 1;
        }else if ([text.string hasPrefix:@"@"]){
            linkType = 0;
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onLinkInCommentCell:linkType:linkText:)]) {
            [weakSelf.delegate onLinkInCommentCell:weakSelf linkType:linkType linkText:text.string];
        }
       
        
    };
    
    
    
    UIView *viewBotLine = [UIView new];
    viewBotLine.backgroundColor = kSeparatorLineColor;
    [self.contentView addSubview:viewBotLine];
    self.viewBotLine = viewBotLine;
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(10);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.labelName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(weakSelf.contentView).offset(-5);
        make.top.equalTo(weakSelf.contentView).offset(10);
    }];

    
    [self.labelPubTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.labelName.mas_left);
        make.top.equalTo(weakSelf.labelName.mas_bottom).offset(5);
    }];
    
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.labelName.mas_left);
        make.top.equalTo(weakSelf.labelPubTime.mas_bottom).offset(5);
        make.right.mas_lessThanOrEqualTo(weakSelf.contentView).offset(-5);
    }];
    
    // 不然在6/6plus上就不准确了
    self.labelContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 65;
    
    [self.labelContent setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [self.labelContent setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
 
    /*******使用FDTemplateLayoutCell*******/
//    [self.viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo(0.5);
//    }];
    
    
    /*******使用HYBMasonryAutoCell*******/
    [self.viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.labelContent.mas_bottom).offset(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    self.hyb_lastViewInCell = self.viewBotLine;
  
}

- (void)setModel:(YHCommentData *)model{
    
    _model = model;
    
    [self.imgvAvatar sd_setImageWithURL:_model.authorInfo.avatarUrl placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    _labelContent.attributedText = _model.commentContent;
    
    if (_model.authorInfo.userName.length) {
        self.labelName.text    = _model.authorInfo.userName;
    }
    else{
        self.labelName.text    = @"匿名用户";
    }
    
    self.labelPubTime.text =  _model.publishTime;
    
}

#pragma mark - Action

- (void)longPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(_delegate && [_delegate respondsToSelector:@selector(longPressInCell:)]){
            [_delegate longPressInCell:self];
        }
    }
    
}

- (void)onAvatar:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(onTapAvatar:)]) {
            [_delegate onTapAvatar:self];
        }
    }
}

@end

