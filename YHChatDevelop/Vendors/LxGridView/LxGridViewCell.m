//
//  LxGridViewCell.m
//  LxGridView
//

#import "LxGridView.h"
#import "Masonry.h"

static NSString *const kVibrateAnimation = @stringify(kVibrateAnimation);
static CGFloat const VIBRATE_DURATION = 0.1;
static CGFloat const VIBRATE_RADIAN = M_PI / 96;

@interface LxGridViewCell ()

@property (nonatomic, assign) BOOL vibrating;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LxGridViewCell

@synthesize editing = _editing;

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
		[self setup];
		[self setupEvents];
		self.didSelect = YES;
	}
	return self;
}

- (void)setup
{
    self.titleLabel = [[UILabel alloc] init];
    
	self.titleLabel.font = [UIFont systemFontOfSize:14];
	self.titleLabel.textColor = kBlueColor;
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.titleLabel.numberOfLines = 1;
	[self.contentView addSubview:self.titleLabel];
	self.layer.borderColor = kBlueColor.CGColor;
	self.layer.borderWidth = 1;

	self.addImage = [[UIImageView alloc] init];
	self.addImage.hidden = YES;
//	self.addImage.image = [UIImage imageNamed:@"myaddtags"];
	[self.contentView addSubview:self.addImage];
}

- (void)selectOrNot
{
	self.didSelect = !self.didSelect;

	if (self.didSelect == NO)
	{
		self.titleLabel.textColor = [UIColor colorWithWhite:0.686 alpha:1.000];
		self.layer.borderColor = [UIColor colorWithWhite:0.686 alpha:1.000].CGColor;
	}
	else
	{
		self.titleLabel.textColor = kBlueColor;
		self.layer.borderColor = kBlueColor.CGColor;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
	}];
	[self.addImage mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
	}];
}

- (void)setupEvents
{
	[self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deleteButtonClicked:(UIButton *)btn
{
	if ([self.delegate respondsToSelector:@selector(deleteButtonClickedInGridViewCell:)])
	{
		[self.delegate deleteButtonClickedInGridViewCell:self];
	}
}

- (BOOL)vibrating
{
	return [self.layer.animationKeys containsObject:kVibrateAnimation];
}

- (void)setVibrating:(BOOL)vibrating
{
	BOOL _vibrating = [self.layer.animationKeys containsObject:kVibrateAnimation];

	if (_vibrating && !vibrating)
	{
//		[self.layer removeAnimationForKey:kVibrateAnimation];
	}
	else if (!_vibrating && vibrating)
	{
		CABasicAnimation *vibrateAnimation = [CABasicAnimation animationWithKeyPath:@stringify(transform.rotation.z)];
		vibrateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		vibrateAnimation.fromValue = @(-VIBRATE_RADIAN);
		vibrateAnimation.toValue = @(VIBRATE_RADIAN);
		vibrateAnimation.autoreverses = YES;
		vibrateAnimation.duration = VIBRATE_DURATION;
		vibrateAnimation.repeatCount = CGFLOAT_MAX;
//		[self.layer addAnimation:vibrateAnimation forKey:kVibrateAnimation];
	}
}

- (BOOL)editing
{
	return self.vibrating;
}

- (void)setEditing:(BOOL)editing
{
	self.vibrating = editing;
	self.deleteButton.hidden = !editing;
}

- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}

- (NSString *)title
{
	return self.titleLabel.text;
}

- (UIView *)snapshotView
{
	UIView *snapshotView = [[UIView alloc] init];

	UIView *cellSnapshotView = nil;
	UIView *deleteButtonSnapshotView = nil;

	if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
	{
		cellSnapshotView = [self snapshotViewAfterScreenUpdates:NO];
	}
	else
	{
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *cellSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		cellSnapshotView = [[UIImageView alloc] initWithImage:cellSnapshotImage];
	}

	if ([self.deleteButton respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
	{
		deleteButtonSnapshotView = [self.deleteButton snapshotViewAfterScreenUpdates:NO];
	}
	else
	{
		UIGraphicsBeginImageContextWithOptions(self.deleteButton.bounds.size, self.deleteButton.opaque, 0);
		[self.deleteButton.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *deleteButtonSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		deleteButtonSnapshotView = [[UIImageView alloc] initWithImage:deleteButtonSnapshotImage];
	}

	snapshotView.frame = CGRectMake(-deleteButtonSnapshotView.frame.size.width / 2,
			-deleteButtonSnapshotView.frame.size.height / 2,
			deleteButtonSnapshotView.frame.size.width / 2 + cellSnapshotView.frame.size.width,
			deleteButtonSnapshotView.frame.size.height / 2 + cellSnapshotView.frame.size.height);
	cellSnapshotView.frame = CGRectMake(deleteButtonSnapshotView.frame.size.width / 2,
			deleteButtonSnapshotView.frame.size.height / 2,
			cellSnapshotView.frame.size.width,
			cellSnapshotView.frame.size.height);
	deleteButtonSnapshotView.frame = CGRectMake(0, 0,
			deleteButtonSnapshotView.frame.size.width,
			deleteButtonSnapshotView.frame.size.height);

	[snapshotView addSubview:cellSnapshotView];
	[snapshotView addSubview:deleteButtonSnapshotView];

	return snapshotView;
}

@end
