//
//  YHCommentKeyboard.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/3/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHCommentKeyboard.h"
#import "YYKit.h"
#import "YHExpressionHelper.h"
#import "Masonry.h"
#import "YHExpressionInputView.h"
#import "YHExpressionTextView.h"

#define kNaviBarH       64   //导航栏高度
#define kTopToolbarH    50   //顶部工具栏高度
#define kToolbarBtnH    35   //顶部工具栏的按钮高度
#define kBotContainerH  216  //底部表情高度
#define DURTAION  0.25f      //键盘显示/收起动画时间
#define kTextVTopMargin 8



@interface YHCommentKeyboard()<YYTextKeyboardObserver,YHExpressionInputViewDelegate,UITextViewDelegate>{
    BOOL    _toolbarButtonTap; //toolbarBtn被点击
    CGFloat _height_oneRowText;//输入框每一行文字高度
    CGFloat _height_Toolbar;   //当前Toolbar高度
    NSMutableArray *_toolbarButtonArr;
    UIButton       *_toolbarButtonSelected;
    
    NSDate *_beginRecordDate;
    NSDate *_endRecordDate;
}

//表情键盘被添加到的VC 和 父视图
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView  *superView;
@property (nonatomic, weak) UIView  *aboveView;

//TopToolBar
@property (nonatomic, strong) UIView *topToolBar;
@property (nonatomic, strong) YHExpressionTextView *textView;
@property (nonatomic, strong) UIButton *toolbarEmoticonButton;//表情
@property (nonatomic, strong) UIView   *toolbarBackground;

//BottomContainer
@property (nonatomic, strong) UIView *botContainer;
@property (nonatomic, strong) YHExpressionInputView *inputV;

@property (nonatomic, weak)id <YHCommentKeyboardDelegate>delegate;
@end

@implementation YHCommentKeyboard


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _toolbarButtonArr = [NSMutableArray new];
        [self _addNotifations];
        [self _initCommentUI];
    }
    return self;
}

#pragma mark - Public
- (instancetype)initWithViewController:( UIViewController <YHCommentKeyboardDelegate>*)viewController aboveView:(UIView *)aboveView{
    if (self = [super init]) {
        //保存VC和父视图
        self.viewController = viewController;
        _delegate = viewController;
        self.superView = self.viewController.view;
        [self.superView addSubview:self];
        
        //在viewController中,表情键盘上方的视图(aboveView)
        WeakSelf
        if(aboveView){
            _aboveView = aboveView;
            if (![self.superView.subviews containsObject:_aboveView]) {
                [self.superView addSubview:_aboveView];
            }
        
        }
        
        //在viewController中,表情键盘在父视图的位置
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(weakSelf.superView).offset(kBotContainerH+kTopToolbarH);
            make.height.mas_equalTo(kBotContainerH+kTopToolbarH);
            make.left.right.equalTo(weakSelf.superView);
            
        }];
        
    }
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.textView.placeholderFont = [UIFont systemFontOfSize:14.0];
    self.textView.placeholder = placeholder;
}

- (void)setCommentType:(YHCommentType)commentType{
    if (commentType != _commentType) {
        self.textView.text = @"";
    }
    _commentType = commentType;
}

/**
 成为第一响应者
 */
- (void)becomeFirstResponder{
    if(![self.textView isFirstResponder]){
        [self.textView becomeFirstResponder];
    }
}

//结束编辑
- (void)endEditing{
    
    _toolbarButtonTap = NO;
    if (![_textView isFirstResponder]) {
        [self _hideCommentKeyboard];
    }else{
        [self.textView resignFirstResponder];
    }
    
}

#pragma mark - filePrivate
- (void)_addNotifations{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


//评论键盘布局
- (void)_layoutCommentUI{
    WeakSelf
    [_topToolBar setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [_topToolBar setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    
    [_topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.botContainer.mas_top);
        make.height.mas_equalTo(kTopToolbarH);
    }];
    
    [_toolbarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.topToolBar);
        make.height.mas_equalTo(kBotContainerH);
    }];
    
    
    [_toolbarEmoticonButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kToolbarBtnH);
        make.right.equalTo(weakSelf.topToolBar.mas_right);
        make.bottom.equalTo(weakSelf.topToolBar).offset(-8);
    }];
    
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.topToolBar).offset(5);
        make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        make.bottom.equalTo(weakSelf.topToolBar).offset(-kTextVTopMargin);
        make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];
    
    [_botContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kBotContainerH);
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
    }];
    
    [_inputV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(weakSelf.botContainer);
        make.left.right.bottom.equalTo(weakSelf.botContainer);
    }];
    
}

- (void)_initCommentUI{
    //顶部工具栏
    UIView *topToolBar = [UIView new];
    topToolBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:topToolBar];
    _topToolBar = topToolBar;
    
    
    //顶部线
    UIView *line = [UIView new];
    line.backgroundColor = UIColorHex(BFBFBF);
    [topToolBar addSubview:line];
    
    
    //顶部工具栏背景层
    UIView *topToolBarBG = [UIView new];
    topToolBarBG.backgroundColor = UIColorHex(F9F9F9);
    [topToolBar addSubview:topToolBarBG];
    _toolbarBackground = topToolBarBG;
    
    
    //输入框
    [self _initTextView];
    
    
    //表情按钮
    _toolbarEmoticonButton = [self _creatToolbarButton];
    [self _setupBtnImage:_toolbarEmoticonButton];
    
    [_toolbarButtonArr addObjectsFromArray:@[_toolbarEmoticonButton]];
    
    //底部容器
    [self _initBotContainer];
    
    [self _layoutCommentUI];
}

- (void)_initTextView {
    
    _textView = [YHExpressionTextView new];
    _textView.layer.cornerRadius =3;
    _textView.layer.borderWidth  = 1;
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
    _textView.showsVerticalScrollIndicator = YES;
    _textView.alwaysBounceVertical = NO;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeySend;
    [_topToolBar addSubview:_textView];
    
    _height_oneRowText = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height;
    _height_Toolbar    = kTopToolbarH;
}


- (UIButton *)_creatToolbarButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button addTarget:self action:@selector(_onToolbarBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_topToolBar addSubview:button];
    return button;
}


- (void)_initBotContainer{
    _botContainer = [UIView new];
    _botContainer.backgroundColor = UIColorHex(F9F9F9);
    [self addSubview:_botContainer];
    
    //表情
    YHExpressionInputView *inputV = [[YHExpressionInputView alloc] init];
    inputV.delegate = self;
    [_botContainer addSubview:inputV];
    _inputV = inputV;
    
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    for (UIButton *b in _toolbarButtonArr) {
        b.selected = NO;
        [self _setupBtnImage:b];
    }
    return YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@""]) {
        [_textView deleteEmoticon];
    }
    if([text isEqualToString:@"\n"]){
        //发送
        [self didTapSendBtn];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    [self _textViewChangeText];
    
    
}

-(void)_textViewChangeText{
    
    CGFloat textH = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height;
    
    int numberOfRowsShow;
    if (!_maxNumberOfRowsToShow) {
        numberOfRowsShow = 4;
    }
    else{
        numberOfRowsShow = _maxNumberOfRowsToShow;
    }
    
    CGFloat rows_h = _height_oneRowText*numberOfRowsShow;
    textH = textH>rows_h?rows_h:textH;
    
    //输入框高度
    CGFloat h_inputV = kTopToolbarH - 2*kTextVTopMargin;
    
    if (textH < h_inputV) {
        [_topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kTopToolbarH);
        }];
        _height_Toolbar = kTopToolbarH;
    }else{
        //工具栏高度
        CGFloat toolbarH = ceil(textH) + 2*kTextVTopMargin ;
        [_topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(toolbarH);
        }];
        _height_Toolbar = toolbarH;
    }
    WeakSelf
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
    
    [_textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    
    
}

#pragma mark - @protocol YHExpressionInputViewDelegate
- (void)emoticonInputDidTapText:(NSString *)text{
    if (text.length) {
        //设置表情符号
        _textView.emoticon = text;
        [self _textViewChangeText];
    }
    
}

- (void)emoticonInputDidTapBackspace{
    
    [_textView deleteEmoticon];
    [self _textViewChangeText];
    
}

- (void)didTapSendBtn{
    DDLog(@"点击发送,发送文本是：\n%@",_textView.text);
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:_textView.text];
    }
    
    //清空输入内容
    self.textView.text = @"";
    [self _textViewChangeText];
}


#pragma mark - Action

/**
 设置btn图片
 */
- (void)_setupBtnImage:(UIButton *)btn{
    
    if (btn == _toolbarEmoticonButton) {
        if (!btn.selected) {
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_emoticonbutton_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_emoticonbutton_background_highlighted"] forState:UIControlStateHighlighted];
        }else{
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background_highlighted"] forState:UIControlStateHighlighted];
            
        }
    }
    
}


/**
 点击toolBarButton
 */
- (void)_onToolbarBtn:(UIButton *)button {
    
    _toolbarButtonSelected = button;
    
    _toolbarButtonTap = YES;
    
    //重设toolBar其他按钮的selected状态
    for (UIButton *btn in _toolbarButtonArr) {
        if (btn != button) {
            btn.selected = NO;
            [self _setupBtnImage:btn];
        }
    }
    
    //设置选中button的selected状态
    button.selected = !button.selected;
    [self _setupBtnImage:button];
    
    
    if (button == _toolbarEmoticonButton) {
        
        if (!button.selected) {
            //显示键盘
            [_textView becomeFirstResponder];
            
        }else{
            
            //显示表情
            if (![_textView isFirstResponder]) {
                [self _showCommentKeyboard];
            }else{
                [_textView resignFirstResponder];
            }
        }
    }
}


/**
隐藏评论键盘
 */
- (void)_hideCommentKeyboard{
    WeakSelf
    [_inputV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.superView).offset(kBotContainerH+_height_Toolbar);
    }];
    
//    [UIView animateWithDuration:DURTAION animations:^{
//        [weakSelf.superView layoutIfNeeded];
//    }];
    
}


/**
 显示表情键盘
 */
- (void)_showCommentKeyboard{
    //表情键盘上移
    WeakSelf
    [_inputV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer);
    }];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.superView);
    }];
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
    
}

#pragma mark - Gesture



#pragma mark - NSNotification

- (void)keyBoardHidden:(NSNotification*)noti{
    
    //隐藏键盘
    
    if (!_toolbarButtonTap) {
        
        [self _hideCommentKeyboard];
        
    }else{
        _toolbarButtonTap = NO;
        
        if (_toolbarButtonSelected == _toolbarEmoticonButton) {
            [self _showCommentKeyboard];
        }else{
            [self _hideCommentKeyboard];
        }
    }
    
}

- (void)keyBoardShow:(NSNotification*)noti{
    //显示键盘
    WeakSelf
    CGRect endF = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    if (!_toolbarButtonTap) {
        
        NSTimeInterval duration = [[noti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGFloat diffH = endF.size.height - kBotContainerH;//高度差
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.superView).offset(-diffH);
        }];
        [UIView animateWithDuration:duration animations:^{
            [weakSelf.superView layoutIfNeeded];
        }];
        
    }else{
        _toolbarButtonTap = NO;
        
        CGFloat diffH = endF.size.height - kBotContainerH;//高度差
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.superView).offset(-diffH);
            
        }];
        
    }
    
}


- (void)_changeDuration:(CGFloat)duration{
    //动态调整tableView高度
    if (_delegate && [self.delegate respondsToSelector:@selector(keyboard:changeDuration:)]) {
        [self.delegate keyboard:self changeDuration:duration];
    }
}


@end

