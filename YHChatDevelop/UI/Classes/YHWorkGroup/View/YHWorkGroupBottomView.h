#import <UIKit/UIKit.h>
#import "YHWorkGroupButton.h"

@class YHWorkGroupBottomView;

@protocol YHWorkGroupBottomViewDelegate <NSObject>

- (void)onComment;
- (void)onLikeInView:(YHWorkGroupBottomView *)inView;
- (void)onShare;

@end

@interface YHWorkGroupBottomView : UIView

@property (nonatomic,strong)YHWorkGroupButton *btnComment;
@property (nonatomic,strong)YHWorkGroupButton *btnLike;
@property (nonatomic,strong)YHWorkGroupButton *btnShare;
@property (nonatomic,weak)id<YHWorkGroupBottomViewDelegate>delegate;
@end