//
//  YHExpressionTextView.m
//  YHChatDevelop
//
//  Created by samuelandkevin on 2017/7/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHExpressionTextView.h"

@interface YHExpressionTextView()
-(void)refreshPlaceholder;
@end

@implementation YHExpressionTextView
{
    UILabel *placeHolderLabel;
}

@synthesize placeholder = _placeholder;

-(void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPlaceholder) name:UITextViewTextDidChangeNotification object:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void)refreshPlaceholder
{
    if([[self text] length])
    {
        [placeHolderLabel setAlpha:0];
    }
    else
    {
        [placeHolderLabel setAlpha:1];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self refreshPlaceholder];
}

-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    placeHolderLabel.font = self.font;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [placeHolderLabel sizeToFit];
    placeHolderLabel.frame = CGRectMake(8, 8, CGRectGetWidth(self.frame)-16, CGRectGetHeight(placeHolderLabel.frame));
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    if ( placeHolderLabel == nil )
    {
        placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        placeHolderLabel.numberOfLines = 0;
        if (self.placeholderFont) {
            placeHolderLabel.font = self.placeholderFont;
        }else{
            CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
            placeHolderLabel.font = [UIFont systemFontOfSize:16 + fontSize];
        }
        placeHolderLabel.backgroundColor = [UIColor clearColor];
        placeHolderLabel.textColor = [UIColor colorWithWhite:0.686 alpha:1.000];
        placeHolderLabel.alpha = 0;
        [self addSubview:placeHolderLabel];
    }
    
    placeHolderLabel.text = self.placeholder;
    [self refreshPlaceholder];
}

//When any text changes on textField, the delegate getter is called. At this time we refresh the textView's placeholder
-(id<UITextViewDelegate>)delegate
{
    [self refreshPlaceholder];
    return [super delegate];
}

- (NSMutableArray<NSString *> *)emoticonArray{
    if (!_emoticonArray) {
        _emoticonArray = [NSMutableArray new];
    }
    return _emoticonArray;
}


- (void)setEmoticon:(NSString *)emoticon{
    _emoticon = emoticon;
    
    NSMutableString *maStr = [[NSMutableString alloc] initWithString:self.text];
    if (_emoticon) {
        [maStr insertString:_emoticon atIndex:self.selectedRange.location];
        [self.emoticonArray addObject:_emoticon];
    }
    self.text = maStr;
}


- (void)deleteEmoticon{
    
    NSRange range = self.selectedRange;
    NSInteger location = (NSInteger)range.location;
    if (location == 0) {
        if (range.length) {
            self.text = @"";
        }
        return ;
    }
    //判断是否表情
    NSString *subString = [self.text substringToIndex:location];
    if ([subString hasSuffix:@"]"]) {
        
        //查询是否存在表情
        __block NSString *emoticon = nil;
        __block NSRange  emoticonRange;
        [[YHExpressionHelper regexEmoticon] enumerateMatchesInString:subString options:kNilOptions range:NSMakeRange(0, subString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            emoticonRange = result.range;
            emoticon = [subString substringWithRange:result.range];
            
            
            
        }];
        DDLog(@"要删除表情是：\n%@",emoticon);
        if (emoticon) {
            //是表情符号,移除
            if ([self.emoticonArray containsObject:emoticon]) {
                
                self.text = [self.text stringByReplacingCharactersInRange:emoticonRange withString:@" "];
                DDLog(@"删除后字符串为:\n%@",self.text);
                
                range.location -= emoticonRange.length;
                range.length = 1;
                self.selectedRange = range;
                
            }
        }else{
            self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
            range.location -= 1;
            range.length = 1;
            self.selectedRange = range;
        }
        
    }else{
        self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
        range.location -= 1;
        range.length = 1;
        self.selectedRange = range;
    }
    
}


@end
