//
//  YHCardDetailHeaderView.m
//  PikeWay
//
//  Created by kun on 16/6/10.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHCardDetailHeaderView.h"
#import "Masonry.h"
#define kSectionHeaderH 53.0



@interface YHCardDetailHeaderView ()
@property (nonatomic,strong) UIButton *btnExpand;

@end
@implementation YHCardDetailHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return  self;
}

- (void)initUI{
   
    UILabel *labelMainTitle = [[UILabel alloc] init];
    labelMainTitle.font = [UIFont systemFontOfSize:16.0];
    labelMainTitle.textColor = RGBCOLOR(48, 48, 48);
    [self.contentView addSubview:labelMainTitle];
    self.labelMainTitle = labelMainTitle;
    
    UILabel *labelSubTitle = [[UILabel alloc] init];
    labelSubTitle.font = [UIFont systemFontOfSize:12.0f];
    labelSubTitle.textColor = RGBCOLOR(96, 96, 96);
    [self.contentView addSubview:labelSubTitle];
    self.labelSubTitle = labelSubTitle;
    
    UIImageView *imgvArrow = [[UIImageView alloc] init];
    imgvArrow.image = [UIImage imageNamed:@"connections_img_upArrow"];
    imgvArrow.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:imgvArrow];
    self.imgvArrow = imgvArrow;
    
    UIButton *btnExpand = [[UIButton alloc] init];
    [btnExpand addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnExpand];
    self.btnExpand = btnExpand;
    
    UIView *botLine = [[UIView alloc] init];
    botLine.backgroundColor = kSeparatorLineColor;
    botLine.frame = CGRectMake(0, kSectionHeaderH-0.5, SCREEN_WIDTH, 0.5);
    [self.contentView addSubview:botLine];
    self.botLine = botLine;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
}

- (void)layoutSubviews{
    CGRect frame = self.contentView.frame;
    frame.size.width = SCREEN_WIDTH;
    frame.size.height = 53.0f;
    self.contentView.frame = frame;
    [self masonry];
}

- (void)masonry{

      __weak typeof(self) weakSelf = self;
    
     [weakSelf.labelMainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(weakSelf.contentView).offset(17);
         make.top.equalTo(weakSelf.contentView).offset(17);
         
    }];
    

    [weakSelf.labelSubTitle setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    [weakSelf.labelSubTitle setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    
    [weakSelf.labelSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
      
    
        make.left.equalTo(weakSelf.labelMainTitle.mas_right).with.offset(24);
        make.right.lessThanOrEqualTo(weakSelf.contentView.mas_right).with.offset(-60);
        make.centerY.equalTo(weakSelf.labelMainTitle);
        
    }];
    
   
    
    [weakSelf.imgvArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.width.and.height.mas_equalTo(@14);
        make.centerY.equalTo(weakSelf.labelMainTitle);
    }];
    
    [weakSelf.btnExpand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(weakSelf.contentView.mas_height);
        make.centerY.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView);
    }];
}

- (void)setModel:(YHCardSection *)model{
    _model = model;
    
    
    if (model.cellModels.count) {
        self.imgvArrow.hidden = NO;
        self.btnExpand.enabled = YES;
        if(_model.isExpand){
            self.imgvArrow.transform = CGAffineTransformIdentity;
        }
        else{
            self.imgvArrow.transform = CGAffineTransformMakeRotation(M_PI);
        }

    }
    else
    {
        self.btnExpand.enabled = NO;
        self.imgvArrow.hidden  = YES;
    }
    
    
    self.labelMainTitle.text = _model.mainTitle;
    self.labelSubTitle.text  = _model.subTitle;
    
   
}


#pragma mark - Action

- (void)onExpand:(UIButton *)btn{

    _model.isExpand = !_model.isExpand;
    
    [UIView animateWithDuration:0.25 animations:^{
       
        if (_model.isExpand) {
             self.imgvArrow.transform = CGAffineTransformIdentity;
        }
        else{
            self.imgvArrow.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
    }];
    
    __weak typeof(self)weakSelf = self;
    if (weakSelf.expandCallback) {
        weakSelf.expandCallback(weakSelf.model.isExpand);
    }
}

//- (void)layoutSubviews{
//    self.botLine.frame = CGRectMake(0, self.bounds.size.height-0.5, SCREEN_WIDTH, 0.5);
//}

@end
