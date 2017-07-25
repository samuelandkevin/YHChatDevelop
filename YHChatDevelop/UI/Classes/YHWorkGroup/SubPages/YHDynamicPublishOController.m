//
//  YHDynamicPublishController.m
//  PikeWay
//
//  Created by YHIOS003 on 16/5/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHDynamicPublishOController.h"
#import "TZImagePickerController.h"
#import "YHNetManager.h"
#import "UIView+Extension.h"
#import "YHActionSheet.h"
#import "UIImage+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImageManager.h"
#import <Photos/Photos.h>
#import "IQKeyboardManager.h"
#import "MBProgressHUD.h"
#import "Masonry.h"
#import "IQTextView.h"
#import "YHChatDevelop-Swift.h"

typedef enum : NSUInteger {
    CaseShare,
    Tax = 2,
    News,
} LabelType;

@interface YHDynamicPublishOController () <UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate>
@property (nonatomic, strong) IQTextView *textView;

@property (nonatomic, strong) UIButton *addImageBtn;

@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *imageContainer;

@property (nonatomic, strong) UIView *labelContainer;

@property (nonatomic, strong) NSMutableArray *labelBtnArray;

@property (nonatomic, strong) TZImagePickerController *imagePickerVc;

@property (nonatomic, strong) UIImagePickerController *imageTakerVC;

@property(nonatomic, assign) LabelType labelType;

@end

#define textViewHeight (SCREEN_WIDTH - 60) / 3 * 1.5
@implementation YHDynamicPublishOController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"发动态";

	self.navigationController.navigationBar.translucent = NO;
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {

    }];
    
    [[TZImageManager manager] authorizationStatusAuthorized];

	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
	self.scrollView.delegate = self;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	[self.view addSubview:self.scrollView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];

	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
	self.textView = [[IQTextView alloc] init];
	self.textView.backgroundColor = [UIColor whiteColor];

	CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];

	self.textView.font = [UIFont systemFontOfSize:16 + fontSize];
	self.textView.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	self.textView.layer.cornerRadius = 10;
    UIView * accessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    //键盘辅助栏
    accessoryView.backgroundColor = [UIColor redColor];
//    self.textView.inputAccessoryView = accessoryView;
    
    
	self.textView.placeholder = @"随便说点儿什么吧，看有没有同道中人";
//	self.textView.placeholderFont = [UIFont systemFontOfSize:16 + fontSize];
//	self.textView.placeholderTextColor = [UIColor colorWithWhite:0.557 alpha:1.000];
	self.textView.delegate = self;
	WeakSelf

	UILabel *tipLabel = [[UILabel alloc] init];
	[self.scrollView addSubview:tipLabel];
	tipLabel.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
	tipLabel.text = @"请选择动态类型";
	tipLabel.font = [UIFont systemFontOfSize:18];
	[tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.left.equalTo(weakSelf.scrollView).offset(15);
	}];
//    tipLabel.backgroundColor = [UIColor redColor];

    
	self.labelContainer = [[UIView alloc] init];
//    self.labelContainer.backgroundColor = [UIColor greenColor];
	[self.scrollView addSubview:self.labelContainer];
	[self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(tipLabel.mas_bottom);
		make.left.equalTo(weakSelf.scrollView);
		make.right.mas_equalTo(SCREEN_WIDTH);
		make.height.mas_equalTo(50);
	}];

	[self.scrollView addSubview:self.textView];
	[self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.labelContainer.mas_bottom);
		make.left.equalTo(weakSelf.scrollView).offset(15);
		make.width.mas_equalTo(SCREEN_WIDTH - 30);
		make.height.mas_equalTo(textViewHeight);
	}];

	self.imageContainer = [[UIView alloc] init];
	[self.scrollView addSubview:self.imageContainer];
	[self.imageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(weakSelf.textView.mas_bottom);
		make.left.equalTo(weakSelf.scrollView);
		make.width.height.mas_equalTo(SCREEN_WIDTH);
	}];

	self.addImageBtn = [UIButton buttonWithType:UIButtonTypeSystem];

//    self.addImageBtn.backgroundColor = [UIColor blueColor];
	[self.imageContainer addSubview:self.addImageBtn];
	CGFloat width = (SCREEN_WIDTH - 60) / 3;
	self.addImageBtn.frame = CGRectMake(15, 15, width, width);
	[self.addImageBtn addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.image = [UIImage imageNamed:@"common_img_add_normal"];
	[self.addImageBtn addSubview:imageView];
	[imageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.insets(UIEdgeInsetsZero);
	}];

	//navigationbar rightbtn
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"发布" target:self selector:@selector(publish:)];

	//navigationbar leftbtn
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithTitle:@"取消" target:self selector:@selector(cancel:)];
	

	for (int i = 0; i < 9; i++)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (width + 15) * (i % 3), 15 + (width + 15) * (i / 3), width, width)];
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.tag = i + 200;
		imageView.image = [UIImage imageNamed:@"0"];
		imageView.layer.masksToBounds = YES;
		UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		removeBtn.frame = CGRectMake(0, 0, 20, 20);
		[removeBtn setImage:[UIImage imageNamed:@"common_img_delete_selected"] forState:UIControlStateNormal];
		removeBtn.tag = i + 300;
		removeBtn.layer.masksToBounds = YES;
		removeBtn.center = CGPointMake(imageView.x + imageView.width, imageView.y);
		[removeBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
		[self.imageContainer addSubview:imageView];
		[self.imageContainer addSubview:removeBtn];
		imageView.hidden = YES;
		removeBtn.hidden = YES;
	}

	//test
	if (self.labelArray.count == 0)
	{
		[self.labelArray addObject:@"案例分享"];
		[self.labelArray addObject:@"财税说说"];
		[self.labelArray addObject:@"花边新闻"];
	}
	//label初值
	self.labelType = Tax;

	[self layoutLabelBtn];

	[self layoutImageViewAndBtn];

	// Do any additional setup after loading the view.
}

- (UIImagePickerController *)imageTakerVC
{
	if (!_imageTakerVC)
	{
		_imageTakerVC = [[UIImagePickerController alloc] init];
		_imageTakerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
		UIColor *color = kBlueColor;
		_imageTakerVC.navigationBar.barTintColor = color;

		NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:18]};
		_imageTakerVC.navigationBar.titleTextAttributes = attributes;
        _imageTakerVC.delegate = self;
	}
	return _imageTakerVC;
}

- (TZImagePickerController *)imagePickerVc
{
	if (!_imagePickerVc)
	{
		_imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
		_imagePickerVc.allowPickingVideo = NO;
	}
	return _imagePickerVc;
}

#pragma mark bottonMethod
- (void)selectDynamicLabel:(UIButton *)sender
{
	for (UIButton *btn in self.labelBtnArray)
	{
		if (sender == btn)
		{
			btn.selected = YES;
            switch ([self.labelBtnArray indexOfObject:sender]) {
                case 0:
                    self.labelType = CaseShare;
                    break;
                case 1:
                    self.labelType = Tax;
                    break;
                case 2:
                    self.labelType = News;
                    break;
                default:
                    break;
            }
			continue;
		}
		btn.selected = NO;
	}
}

- (void)addImage:(id)sender
{
	WeakSelf

	[self.view endEditing: YES];
	YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:@[@"拍照", @"从手机相册选取"]];
	[sheet show];
	[sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
		if (!isCancel)
		{
			if (clickedIndex == 0)
			{
				[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
					if (granted)
					{
						[weakSelf presentViewController:weakSelf.imageTakerVC animated:YES completion:nil];
						DDLog(@"=====用户允许使用相机=====");
					}
					else
					{
						DDLog(@"=====用户不允许使用相机=====");
						postTips(@"税道APP没有权限访问您的相机,请在设置中开启税道访问相机的权限", nil);
					}
				}];
			}
			else if (clickedIndex == 1)
			{
//				MyWeakSelf

				if ([[TZImageManager manager] authorizationStatusAuthorized])
				{
					[self presentViewController:self.imagePickerVc animated:YES completion:nil];

//					[self zz_presentPhotoVC:9 completeHandler:^(NSArray < PHAsset * > *_Nonnull array) {
//	                    // You can get the photos by block, the same as by delegate.
//	                    // 你可以通过block或者代理，来得到用户选择的照片.
//						PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//						options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//
//						for (PHAsset *asset in array)
//						{
//							[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
//								@autoreleasepool {
//									[ws.imageArray addObject:result];
//								}
//
//								if (ws.imageArray.count > 9)
//								{
//									while (ws.imageArray.count > 9) {
//										[ws.imageArray removeLastObject];
//									}
//								}
//
//								if (ws.imageArray.count == array.count)
//								{
//									dispatch_async(dispatch_get_main_queue(), ^{
//										[ws layoutImageViewAndBtn];
//									});
//								}
//							}];
//						}
//					}];
				}
				else
				{
					if (iOS8Later)
					{
						if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
						{
							return;
						}
					}
					else
					{
						if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined)
						{
							return;
						}
					}
					postTips(@"税道APP没有权限访问您的相册,请在设置中开启税道访问相册的权限", nil);
				}
			}
		}
	}];
}

- (void)dealloc
{
	DDLog(@"%@ did dealloc", self);
	[self.imageArray removeAllObjects];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark lazy init
- (NSMutableArray *)labelArray
{
	if (!_labelArray)
	{
		_labelArray = [NSMutableArray array];
	}
	return _labelArray;
}

- (NSMutableArray *)imageArray
{
	if (!_imageArray)
	{
		_imageArray = [NSMutableArray array];
	}
	return _imageArray;
}

- (NSMutableArray *)labelBtnArray
{
	if (!_labelBtnArray)
	{
		_labelBtnArray = [NSMutableArray array];
	}
	return _labelBtnArray;
}

#pragma mark layoutSubView
- (void)layoutLabelBtn
{
	//如果服务器没有返回label数组,那么
	if (self.labelArray.count == 0)
	{
		[self.labelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
			make.height.mas_equalTo(0);
		}];
		return;
	}
	NSInteger count = self.labelArray.count;
	CGFloat labelWidth = (SCREEN_WIDTH - 15) / count - 15;

	for (int i = 0; i < count; i++)
	{
		UIButton *labelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        labelBtn.backgroundColor = [UIColor blueColor];
		labelBtn.frame = CGRectMake(15 + (labelWidth + 15) * i, 0, labelWidth, 50);
		labelBtn.tag = 500 + i;
		labelBtn.titleLabel.layer.masksToBounds = YES;
//        [labelBtn setTintColor:[UIColor greenColor]];
		[labelBtn setTintColor:kBlueColor];
		[labelBtn setTitleColor:kBlueColor forState:UIControlStateNormal];
		[labelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
		[labelBtn addTarget:self action:@selector(selectDynamicLabel:) forControlEvents:UIControlEventTouchUpInside];
		[labelBtn setTitle:self.labelArray[i] forState:UIControlStateNormal];
		[self.labelContainer addSubview:labelBtn];
		[self.labelBtnArray addObject:labelBtn];
	}

	UIButton *btn = self.labelBtnArray[1];
	btn.selected = YES;
}

- (void)layoutImageViewAndBtn
{
	CGFloat width = (SCREEN_WIDTH - 60) / 3;

	for (int i = 0; i < self.imageArray.count; i++)
	{
		UIImageView *imageView = [self.scrollView viewWithTag:i + 200];
		UIButton *btn = [self.imageContainer viewWithTag:i + 300];

		if ([self.imageArray[i] isKindOfClass:[UIImage class]])
		{
			UIImage *originImage = self.imageArray[i];
			//			DDLog(@"%@", NSStringFromCGSize(originImage.size));

//			CGFloat imageWidth = originImage.size.width > originImage.size.height ? originImage.size.height : originImage.size.width;
//			CGFloat imageX = originImage.size.width > originImage.size.height ? (originImage.size.width - originImage.size.height) / 2 : 0;
//			CGFloat imageY = originImage.size.height > originImage.size.width ? (originImage.size.height - originImage.size.width) / 2 : 0;
			//            if (originImage.size.width <= width) {
			//                imageWidth = originImage.size.width;
			//            }
			//            if (originImage.size.height <= width) {
			//                imageWidth = originImage.size.height;
			//            }
//			UIImage *tempImage = [self getLowQualityImage:originImage];

//			UIImage *finalImage = [self imageFromImage:originImage inRect:CGRectMake(imageX, imageY, imageWidth, imageWidth)];
//			UIImage *finalImage = [self createThumbnailImage:originImage];
			imageView.image = originImage;
			imageView.hidden = NO;
			btn.hidden = NO;
		}
	}

	for (NSInteger i = self.imageArray.count; i < 9; i++)
	{
		UIImageView *imageView = [self.scrollView viewWithTag:i + 200];
		UIButton *btn = [self.imageContainer viewWithTag:i + 300];
		imageView.hidden = YES;
		btn.hidden = YES;
	}
    
    CGRect frame = CGRectMake(15 + (width + 15) * (self.imageArray.count % 3), 15 + (width + 15) * (self.imageArray.count / 3), self.addImageBtn.frame.size.width, self.addImageBtn.frame.size.height);
    self.addImageBtn.frame = frame;
//	self.addImageBtn.frame.origin = CGPointMake(15 + (width + 15) * (self.imageArray.count % 3), 15 + (width + 15) * (self.imageArray.count / 3));

	if (self.imageArray.count == 9)
	{
		self.addImageBtn.hidden = YES;
	}
	else
	{
		self.addImageBtn.hidden = NO;
	}
}

- (void)deleteImage:(UIButton *)btn
{
	[self.view endEditing:YES];
	NSInteger imageIndex = btn.tag - 300;
	[self.imageArray removeObjectAtIndex:imageIndex];
	[self layoutImageViewAndBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[self.textView becomeFirstResponder];
}

- (void)touchesBegan:(NSSet <UITouch *> *)touches withEvent:(UIEvent *)event
{
	[self.view endEditing:YES];
}

- (void)cancel:(id)sender
{
	[self.view endEditing:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publish:(id)sender
{
	[self.view endEditing:YES];
	NSString *content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if (self.imageArray.count == 0 && content.length == 0)
	{
		postTips(@"随便说点儿什么吧", nil);
		return;
	}
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.scrollView];

	[self.scrollView addSubview:HUD];

	if (self.imageArray.count == 0)
	{
		[HUD show:YES];
		//发布只有文字的动态
		WeakSelf
		[[NetManager sharedInstance] postSendDynamicContent: content originalPicUrls: nil thumbnailPicUrls: nil visible: DynmaicVisible_AllPeople atUsers: nil dynamicType: self.labelType complete:^(BOOL success, id obj) {
			[HUD hide:YES];

			if (success)
			{
				DDLog(@"发表动态成功:%@", obj);
				[[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew",@"subIndex":@(weakSelf.labelType)}];
				[weakSelf dismissViewControllerAnimated:YES completion:nil];
                
			}
			else
			{
				if (isNSDictionaryClass(obj))
				{
		            //服务器返回的错误描述
					NSString *msg = obj[kRetMsg];
					postTips(msg, @"发表动态失败");
				}
				else
				{
		            //AFN请求失败的错误描述
					postTips(obj, @"发表动态失败");
				}
			}
		}];
		return;
	}
	else
	{
		HUD.labelText = @"正在上传图片,请稍后";
		[HUD show:YES];
		//带图片的动态
//		dispatch_async(dispatch_get_global_queue(0, 0), ^{
		WeakSelf
		[[NetManager sharedInstance] postUploadOriginalPics: self.imageArray thumbnailPics: nil complete:^(BOOL success, id obj) {
			[HUD hide:YES];

			if (success)
			{
				[self.imageArray removeAllObjects];
				NSDictionary *dict = obj;
				NSArray *oriPicUrls = dict[@"originalPicUrls"];
				NSArray *thumbPicUrls = dict[@"thumbPicUrls"];

				[MBProgressHUD showHUDAddedTo:weakSelf.scrollView animated:YES];
				[[NetManager sharedInstance] postSendDynamicContent:content originalPicUrls:oriPicUrls thumbnailPicUrls:thumbPicUrls visible:DynmaicVisible_AllPeople atUsers:nil dynamicType:weakSelf.labelType complete:^(BOOL success, id obj) {
					[MBProgressHUD hideHUDForView:weakSelf.scrollView animated:YES];

					if (success)
					{
						DDLog(@"发表动态成功:%@", obj);
						[[NSNotificationCenter defaultCenter] postNotificationName:Event_RefreshDynPage object:@(RefreshPage_WorkGroup) userInfo:@{@"operation" : @"loadNew",@"subIndex":@(weakSelf.labelType)}];
						[weakSelf.view endEditing:YES];
						[weakSelf dismissViewControllerAnimated:YES completion:nil];
					}
					else
					{
						if (isNSDictionaryClass(obj))
						{
		                    //服务器返回的错误描述
							NSString *msg = obj[kRetMsg];
							postTips(msg, @"发表动态失败");
						}
						else
						{
		                    //AFN请求失败的错误描述
							postTips(obj, @"发表动态失败");
						}
					}
				}];
			}
			else
			{
				postTips(obj, @"上传图片失败");
			}
		} progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {}];
//		});
	}
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *, id> *)info
{
	//拍照上传
	DDLog(@"%@", info);
	[picker dismissViewControllerAnimated:YES completion:nil];
	UIImage *originImage = info[@"UIImagePickerControllerOriginalImage"];
	[self.imageArray addObject:originImage];

	if (self.imageArray.count > 9)
	{
		while (self.imageArray.count > 9) {
			[self.imageArray removeLastObject];
		}
	}

	[self layoutImageViewAndBtn];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark scrollView delegate
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//	[self.view endEditing:YES];
//}

#pragma mark textView delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *result;
    
    if (textView.text.length >= range.length)
    {
        result = [textView.text stringByReplacingCharactersInRange:range withString:text];
    }
    //    [textView scrollRangeToVisible:range];
    
    DDLog(@"%@",NSStringFromRange(range));
    if (self.labelType == Tax || self.labelType == News) {
        if (result.length > 15000)
        {
            return NO;
        }
    }
    if (self.labelType == CaseShare) {
        if (result.length > 15000)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	self.imagePickerVc = nil;
	// Dispose of any resources that can be recreated.
}

- (UIImage *)createThumbnailImage:(UIImage *)image
{
	@autoreleasepool {
		//将图片转换为JPG格式的二进制数据
		NSData *data = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];

		//		DDLog(@"image originalSize = %ld", data.length)
		if (data == nil)
		{
			return image;
		}
		float scale = 10 / data.length;

		NSData *data2 = UIImageJPEGRepresentation(image, scale);

		//将二进制数据生成UIImage

		UIImage *finalImage = [[UIImage alloc] initWithData:data2];

		return finalImage;
	}
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
	UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
	[image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect
{
	CGImageRef newImageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef];

	CGImageRelease(newImageRef);

	return newImage;
}

- (UIImage *)getLowQualityImage:(UIImage *)image
{
	@autoreleasepool {
		CGFloat width = image.size.width / SCREEN_WIDTH;
		CGFloat height = image.size.height / SCREEN_HEIGHT;
		CGFloat factor = fmax(width, height);

		CGFloat newWidth = image.size.width / factor;
		CGFloat newHeight = image.size.height / factor;
		CGSize newSize = CGSizeMake(newWidth, newHeight);

		UIGraphicsBeginImageContext(newSize);
		[image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImage *finalImage = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(newImage, 0.1)];

		return finalImage;
	}
}

#pragma mark
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
	if (![assets[0] isKindOfClass:[UIImage class]])
	{
		[self.imageArray addObjectsFromArray:photos];
	}
	else
	{
		[self.imageArray addObjectsFromArray:assets];
	}

	if (self.imageArray.count > 9)
	{
		while (self.imageArray.count > 9) {
			[self.imageArray removeLastObject];
		}
	}
	WeakSelf
	dispatch_async(dispatch_get_main_queue(), ^{
		[weakSelf layoutImageViewAndBtn];
	});
}

- (void)keyboardShow:(NSNotification *)sender
{
	NSDictionary *dic = sender.userInfo;

	if (dic[UIKeyboardFrameBeginUserInfoKey])
	{
//        DDLog(@"%@", dic);
		NSValue * value = dic[UIKeyboardFrameBeginUserInfoKey];
		CGRect keyboardFrame = value.CGRectValue;
		keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
		UIEdgeInsets contentInset = self.scrollView.contentInset;
		contentInset.bottom = keyboardFrame.size.height + 70;
		self.scrollView.contentInset = contentInset;
	}
}

- (void)keyboardHide:(NSNotification *)sender
{
	self.scrollView.contentInset = UIEdgeInsetsZero;
}

@end
