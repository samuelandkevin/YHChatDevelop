//
//  YHWGLayout.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/3/24.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHWGLayout.h"
#import "YHExpressionHelper.h"
/**
 文本 Line 位置修改
 将每行文本的高度和位置固定下来，不受中英文/Emoji字体的 ascent/descent 影响
 */
@interface YHWGLinePositionModifier : NSObject <YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font; // 基准字体 (例如 Heiti SC/PingFang SC)
@property (nonatomic, assign) CGFloat paddingTop;    //文本顶部留白
@property (nonatomic, assign) CGFloat paddingBottom; //文本底部留白
@property (nonatomic, assign) CGFloat lineHeightMultiple; //行距倍数
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end

@implementation YHWGLinePositionModifier


- (instancetype)init {
    self = [super init];
    
    _lineHeightMultiple = 1.5;

    return self;
}


- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container {
//    CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    YHWGLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
//        CGFloat ascent = _font.ascender;
//        CGFloat descent = ABS(_font.descender);

    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = ABS(_font.pointSize * 0.14);
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    CGFloat retHeight = _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;

    return retHeight;
}

@end

@interface YHWGLayout()
@property (nonatomic,strong) YHWGLinePositionModifier *modifier;
@property (nonatomic,assign) CGFloat addFontSize;
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,assign) int maxShowingRows;//最多显示行数
@end

@implementation YHWGLayout

- (instancetype)init{
    if (self = [super init]) {
        _maxShowingRows = 5;
        //系统字体变化幅度
        _addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
        _fontSize    = (_addFontSize + 13);
        _modifier      = [YHWGLinePositionModifier new];
        _modifier.font = [UIFont systemFontOfSize:_fontSize];
        _modifier.paddingTop    = 0;
        _modifier.paddingBottom = 0;
        
    }
    return self;
}

- (void)layoutWithText:(NSString *)text{
    
    CGRect textRect  = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:_fontSize]} context:nil];
    _shouldShowMore = NO;
    
    //最多显示的文本高度
    _designatedTextHeight = [_modifier heightForLineCount:_maxShowingRows];
    if (textRect.size.height > _designatedTextHeight) {
        //文章超过指定行数
        _shouldShowMore = YES;
    }
 
    NSMutableAttributedString *maStr = [YHExpressionHelper attributedStringWithText:text fontSize:_fontSize textColor:[UIColor blackColor]];
    

    //展开全文布局
    if(_shouldShowMore){
        YYTextContainer *container = [YYTextContainer new];
        container.size = CGSizeMake(SCREEN_WIDTH -20 , HUGE);
        container.linePositionModifier = _modifier;
        _fullTextLayout = [YYTextLayout layoutWithContainer:container text:maStr];
       
    }
    
    //文章收起布局
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(SCREEN_WIDTH -20 , HUGE);
    container.linePositionModifier = _modifier;
    container.maximumNumberOfRows = 5;
    _textLayout = [YYTextLayout layoutWithContainer:container text:maStr];
    
    
    if (_shouldShowMore) {
        //展开全文高度
         _fullTextHeight = [_modifier heightForLineCount:_fullTextLayout.rowCount];
    }
    //收起文章高度
    _shrinkTextHeight = [_modifier heightForLineCount:_textLayout.rowCount];
    
   
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}

@end
