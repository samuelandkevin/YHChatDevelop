////
////  YHDynamicPublishController.m
////  samuelandkevin github:https://github.com/samuelandkevin/YHChat
////
////  Created by YHIOS003 on 16/5/24.
////  Copyright © 2016年 samuelandkevin. All rights reserved.
////
//
//#import "YHDynamicPublishController.h"
//#import "YYKit.h"
//#import "TZImagePickerController.h"
//#import "NetManager+WorkGroup.h"
//#import "UIView+Extension.h"
//#import "YHActionSheet.h"
//#import "UIImage+AddCornerRadius.h"
//#import <AssetsLibrary/AssetsLibrary.h>
//#import "TZImageManager.h"
//#import <Photos/Photos.h>
//#import "YHChatDevelop-Swift.h"
//
//@interface YHDynamicPublishController () <YYTextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate>
//@property (nonatomic, strong) YYTextView *textView;
//
//@property (nonatomic, strong) UIButton *addImageBtn;
//
//@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;
//
//@property (nonatomic, strong) UIScrollView *scrollView;
//
//@property (nonatomic, strong) UIView *imageContainer;
//
//@property (nonatomic, strong) UIView *labelContainer;
//
//@property (nonatomic, strong) NSMutableArray *labelBtnArray;
//
//@property (nonatomic, assign) int labelType;
//
//@property (nonatomic, strong) TZImagePickerController *imagePickerVc;
//
//@property (nonatomic, strong) UIImagePickerController *imageTakerVC;
//
//@end
//
//#define textViewHeight (SCREEN_WIDTH - 60) / 3 * 1.5
//@implementation YHDynamicPublishController
//
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//	self.title = @"发动态";
//
//	self.navigationController.navigationBar.translucent = NO;
//
//	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
//	self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
//	self.scrollView.delegate = self;
//	[self.view addSubview:self.scrollView];
//	self.view.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
//	self.textView = [[YYTextView alloc] init];
//	self.textView.backgroundColor = [UIColor whiteColor];
//
//	CGFloat fontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
//
//	self.textView.font = [UIFont systemFontOfSize:16 + fontSize];
//	self.textView.textColor = [UIColor colorWithWhite:0.188 alpha:1.000];
//	self.textView.layer.cornerRadius = 10;
//
//	self.textView.placeholderText = @"随便说点儿什么吧,看有没有同道中人";
//	self.textView.placeholderFont = [UIFont systemFontOfSize:16 + fontSize];
//	self.textView.placeholderTextColor = [UIColor colorWithWhite:0.557 alpha:1.000];
//	self.textView.delegate = self;
//	[self.scrollView addSubview:self.textView];
//	MyWeakSelf
//	[self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//		make.top.left.equalTo(ws.scrollView).offset(15);
//		make.width.mas_equalTo(SCREEN_WIDTH - 30);
//		make.height.mas_equalTo(textViewHeight);
//	}];
//
//	self.labelContainer = [[UIView alloc] init];
//
//	[self.scrollView addSubview:self.labelContainer];
//	[self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//		make.top.equalTo(ws.textView.mas_bottom);
//		make.left.equalTo(ws.scrollView);
//		make.right.mas_equalTo(SCREEN_WIDTH);
//		make.height.mas_equalTo(65);
//	}];
//
//	self.imageContainer = [[UIView alloc] init];
//	[self.scrollView addSubview:self.imageContainer];
//	[self.imageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//		make.top.equalTo(ws.labelContainer.mas_bottom);
//		make.left.equalTo(ws.scrollView);
//		make.width.height.mas_equalTo(SCREEN_WIDTH);
//	}];
//
//	self.addImageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//
////    self.addImageBtn.backgroundColor = [UIColor blueColor];
//	[self.imageContainer addSubview:self.addImageBtn];
//	CGFloat width = (SCREEN_WIDTH - 60) / 3;
//	self.addImageBtn.frame = CGRectMake(15, 15, width, width);
//	[self.addImageBtn addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
//	UIImageView *imageView = [[UIImageView alloc] init];
//	imageView.image = [UIImage imageNamed:@"common_img_add_normal"];
//	[self.addImageBtn addSubview:imageView];
//	[imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//		make.edges.insets(UIEdgeInsetsZero);
//	}];
//
//	//navigationbar rightbtn
//	UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//	publishBtn.titleLabel.layer.masksToBounds = YES;
//
//	publishBtn.frame = CGRectMake(0, 0, 40, 40);
//	[publishBtn setTitle:@"发布" forState:UIControlStateNormal];
//	publishBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//	publishBtn.titleLabel.textColor = [UIColor whiteColor];
//	[publishBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishBtn];
//
//	//navigationbar leftbtn
//	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//	cancelBtn.titleLabel.layer.masksToBounds = YES;
//
//	cancelBtn.frame = CGRectMake(0, 0, 40, 40);
//	[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//	cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//	cancelBtn.titleLabel.textColor = [UIColor whiteColor];
//	[cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
//
//	for (int i = 0; i < 9; i++)
//	{
//		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + (width + 15) * (i % 3), 15 + (width + 15) * (i / 3), width, width)];
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//		imageView.tag = i + 200;
//		imageView.image = [UIImage imageNamed:@"0"];
//		imageView.layer.masksToBounds = YES;
//		UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//		removeBtn.frame = CGRectMake(0, 0, 20, 20);
//		[removeBtn setImage:[UIImage imageNamed:@"common_img_delete_selected"] forState:UIControlStateNormal];
//		removeBtn.tag = i + 300;
//		removeBtn.layer.masksToBounds = YES;
//		removeBtn.center = CGPointMake(imageView.x + imageView.width, imageView.y);
//		[removeBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
//		[self.imageContainer addSubview:imageView];
//		[self.imageContainer addSubview:removeBtn];
//		imageView.hidden = YES;
//		removeBtn.hidden = YES;
//	}
//
//	//test
//	if (self.labelArray.count == 0)
//	{
//		[self.labelArray addObject:@"案例分享"];
//		[self.labelArray addObject:@"政策解读"];
//		[self.labelArray addObject:@"财税说说"];
//		[self.labelArray addObject:@"花边新闻"];
//	}
//	//label初值
//	self.labelType = 0;
//
//	[self layoutLabelBtn];
//
//	[self layoutImageViewAndBtn];
//
//	// Do any additional setup after loading the view.
//}
//
//- (UIImagePickerController *)imageTakerVC
//{
//	if (!_imageTakerVC)
//	{
//		_imageTakerVC = [[UIImagePickerController alloc] init];
//		_imageTakerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
//		UIColor *color = [UIColor colorWithRed:0.f green:191.f / 255 blue:143.f / 255 alpha:1];
//		_imageTakerVC.navigationBar.barTintColor = color;
//
//		NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:18]};
//		_imageTakerVC.navigationBar.titleTextAttributes = attributes;
//	}
//	return _imageTakerVC;
//}
//
//- (TZImagePickerController *)imagePickerVc
//{
//	if (!_imagePickerVc)
//	{
//		_imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//		_imagePickerVc.allowPickingVideo = NO;
//	}
//	return _imagePickerVc;
//}
//
//#pragma mark bottonMethod
//- (void)selectDynamicLabel:(UIButton *)sender
//{
//	for (UIButton *btn in self.labelBtnArray)
//	{
//		if (sender == btn)
//		{
//			btn.selected = YES;
//			self.labelType = (int)[self.labelBtnArray indexOfObject:sender];
//			continue;
//		}
//		btn.selected = NO;
//	}
//}
//
//- (void)addImage:(id)sender
//{
//	MyWeakSelf
//
//	[self.view endEditing: YES];
//	YHActionSheet *sheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:@[@"拍照", @"从手机相册选取"]];
//	[sheet show];
//	[sheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
//		if (!isCancel)
//		{
//			if (clickedIndex == 0)
//			{
//				[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//					if (granted)
//					{
//						[ws presentViewController:ws.imageTakerVC animated:YES completion:nil];
//						DDLog(@"=====用户允许使用相机=====");
//					}
//					else
//					{
//						DDLog(@"=====用户不允许使用相机=====");
//						postTips(@"税道APP没有权限访问您的相机,请在设置中开启税道访问相机的权限", nil);
//					}
//				}];
//			}
//			else if (clickedIndex == 1)
//			{
//				MyWeakSelf
//
//				if ([[TZImageManager manager] authorizationStatusAuthorized])
//				{
//					[self presentViewController:self.imagePickerVc animated:YES completion:nil];
//
////					[self zz_presentPhotoVC:9 completeHandler:^(NSArray < PHAsset * > *_Nonnull array) {
////	                    // You can get the photos by block, the same as by delegate.
////	                    // 你可以通过block或者代理，来得到用户选择的照片.
////						PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
////						options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
////
////						for (PHAsset *asset in array)
////						{
////							[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
////								@autoreleasepool {
////									[ws.imageArray addObject:result];
////								}
////
////								if (ws.imageArray.count > 9)
////								{
////									while (ws.imageArray.count > 9) {
////										[ws.imageArray removeLastObject];
////									}
////								}
////
////								if (ws.imageArray.count == array.count)
////								{
////									dispatch_async(dispatch_get_main_queue(), ^{
////										[ws layoutImageViewAndBtn];
////									});
////								}
////							}];
////						}
////					}];
//				}
//				else
//				{
//					if (iOS8Later)
//					{
//						if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
//						{
//							return;
//						}
//					}
//					else
//					{
//						if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined)
//						{
//							return;
//						}
//					}
//					postTips(@"税道APP没有权限访问您的相册,请在设置中开启税道访问相册的权限", nil);
//				}
//			}
//		}
//	}];
//}
//
//- (void)dealloc
//{
//	DDLog(@"%@ did dealloc", self);
//	[self.imageArray removeAllObjects];
////    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark lazy init
//- (NSMutableArray *)labelArray
//{
//	if (!_labelArray)
//	{
//		_labelArray = [NSMutableArray array];
//	}
//	return _labelArray;
//}
//
//- (NSMutableArray *)imageArray
//{
//	if (!_imageArray)
//	{
//		_imageArray = [NSMutableArray array];
//	}
//	return _imageArray;
//}
//
//- (NSMutableArray *)labelBtnArray
//{
//	if (!_labelBtnArray)
//	{
//		_labelBtnArray = [NSMutableArray array];
//	}
//	return _labelBtnArray;
//}
//
//#pragma mark layoutSubView
//- (void)layoutLabelBtn
//{
//	//如果服务器没有返回label数组,那么
//	if (self.labelArray.count == 0)
//	{
//		[self.labelContainer mas_updateConstraints:^(MASConstraintMaker *make) {
//			make.height.mas_equalTo(0);
//		}];
//		return;
//	}
//	NSInteger count = self.labelArray.count;
//	CGFloat labelWidth = (SCREEN_WIDTH - 15) / count - 15;
//
//	for (int i = 0; i < count; i++)
//	{
//		UIButton *labelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//
//		labelBtn.frame = CGRectMake(15 + (labelWidth + 15) * i, 15, labelWidth, 50);
//		labelBtn.tag = 500 + i;
//		labelBtn.titleLabel.layer.masksToBounds = YES;
////        [labelBtn setTintColor:[UIColor greenColor]];
//		[labelBtn setTintColor:[UIColor colorWithRed:0.f green:191.f / 255 blue:143.f / 255 alpha:1]];
//		[labelBtn setTitleColor:[UIColor colorWithRed:0.f green:191.f / 255 blue:143.f / 255 alpha:1] forState:UIControlStateNormal];
//		[labelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//		[labelBtn addTarget:self action:@selector(selectDynamicLabel:) forControlEvents:UIControlEventTouchUpInside];
//		[labelBtn setTitle:self.labelArray[i] forState:UIControlStateNormal];
//		[self.labelContainer addSubview:labelBtn];
//		[self.labelBtnArray addObject:labelBtn];
//	}
//
//	UIButton *btn = self.labelBtnArray[0];
//	btn.selected = YES;
//}
//
//- (void)layoutImageViewAndBtn
//{
//	CGFloat width = (SCREEN_WIDTH - 60) / 3;
//
//	for (int i = 0; i < self.imageArray.count; i++)
//	{
//		UIImageView *imageView = [self.scrollView viewWithTag:i + 200];
//		UIButton *btn = [self.imageContainer viewWithTag:i + 300];
//
//		if ([self.imageArray[i] isKindOfClass:[UIImage class]])
//		{
//			UIImage *originImage = self.imageArray[i];
//			//			DDLog(@"%@", NSStringFromCGSize(originImage.size));
//
////			CGFloat imageWidth = originImage.size.width > originImage.size.height ? originImage.size.height : originImage.size.width;
////			CGFloat imageX = originImage.size.width > originImage.size.height ? (originImage.size.width - originImage.size.height) / 2 : 0;
////			CGFloat imageY = originImage.size.height > originImage.size.width ? (originImage.size.height - originImage.size.width) / 2 : 0;
//			//            if (originImage.size.width <= width) {
//			//                imageWidth = originImage.size.width;
//			//            }
//			//            if (originImage.size.height <= width) {
//			//                imageWidth = originImage.size.height;
//			//            }
////			UIImage *tempImage = [self getLowQualityImage:originImage];
//
////			UIImage *finalImage = [self imageFromImage:originImage inRect:CGRectMake(imageX, imageY, imageWidth, imageWidth)];
////			UIImage *finalImage = [self createThumbnailImage:originImage];
//			imageView.image = originImage;
//			imageView.hidden = NO;
//			btn.hidden = NO;
//		}
//	}
//
//	for (NSInteger i = self.imageArray.count; i < 9; i++)
//	{
//		UIImageView *imageView = [self.scrollView viewWithTag:i + 200];
//		UIButton *btn = [self.imageContainer viewWithTag:i + 300];
//		imageView.hidden = YES;
//		btn.hidden = YES;
//	}
//
//	self.addImageBtn.origin = CGPointMake(15 + (width + 15) * (self.imageArray.count % 3), 15 + (width + 15) * (self.imageArray.count / 3));
//
//	if (self.imageArray.count == 9)
//	{
//		self.addImageBtn.hidden = YES;
//	}
//	else
//	{
//		self.addImageBtn.hidden = NO;
//	}
//}
//
//- (void)deleteImage:(UIButton *)btn
//{
//	[self.view endEditing:YES];
//	NSInteger imageIndex = btn.tag - 300;
//	[self.imageArray removeObjectAtIndex:imageIndex];
//	[self layoutImageViewAndBtn];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////	[self.textView becomeFirstResponder];
//}
//
//- (void)touchesBegan:(NSSet <UITouch *> *)touches withEvent:(UIEvent *)event
//{
//	[self.view endEditing:YES];
//}
//
//- (void)cancel:(id)sender
//{
//	[self.view endEditing:YES];
//	[self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)publish:(id)sender
//{
//	[self.view endEditing:YES];
//	NSString *content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//	if (self.imageArray.count == 0 && content.length == 0)
//	{
//		postTips(@"随便说点儿什么吧", nil);
//		return;
//	}
//	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.scrollView];
//
//	[self.scrollView addSubview:HUD];
//
//	if (self.imageArray.count == 0)
//	{
//		[HUD show:YES];
//		//发布只有文字的动态
//		MyWeakSelf
//		[[NetManager sharedInstance] postSendDynamicContent: content originalPicUrls: nil thumbnailPicUrls: nil visible: DynmaicVisible_AllPeople atUsers: nil dynamicType: self.labelType complete:^(BOOL isOk, id obj) {
//			[HUD hide:YES];
//
//			if (isOk)
//			{
//				DDLog(@"发表动态成功:%@", obj);
//				[[NSNotificationCenter defaultCenter] postNotificationName:Event_WorkGroupDynamic_Refresh object:ws userInfo:@{@"operation" : @"loadNew"}];
//				[ws dismissViewControllerAnimated:YES completion:nil];
//			}
//			else
//			{
//				if (isNSDictionaryClass(obj))
//				{
//		            //服务器返回的错误描述
//					NSString *msg = obj[kRetMsg];
//					postTips(msg, @"发表动态失败");
//				}
//				else
//				{
//		            //AFN请求失败的错误描述
//					postTips(obj, @"发表动态失败");
//				}
//			}
//		}];
//		return;
//	}
//	else
//	{
//		HUD.labelText = @"正在上传图片,请稍后";
//		[HUD show:YES];
//		//带图片的动态
////		dispatch_async(dispatch_get_global_queue(0, 0), ^{
//		MyWeakSelf
//		[[NetManager sharedInstance] postUploadOriginalPics: self.imageArray thumbnailPics: nil complete:^(BOOL isOk, id obj) {
//			[HUD hide:YES];
//
//			if (isOk)
//			{
//                [self.imageArray removeAllObjects];
//				NSDictionary *dict = obj;
//				NSArray *oriPicUrls = dict[@"originalPicUrls"];
//				NSArray *thumbPicUrls = dict[@"thumbPicUrls"];
//
//				[MBProgressHUD showHUDAddedTo:ws.scrollView animated:YES];
//				[[NetManager sharedInstance] postSendDynamicContent:content originalPicUrls:oriPicUrls thumbnailPicUrls:thumbPicUrls visible:DynmaicVisible_AllPeople atUsers:nil dynamicType:ws.labelType complete:^(BOOL isOk, id obj) {
//					[MBProgressHUD hideHUDForView:ws.scrollView animated:YES];
//
//					if (isOk)
//					{
//						DDLog(@"发表动态成功:%@", obj);
//						[[NSNotificationCenter defaultCenter] postNotificationName:Event_WorkGroupDynamic_Refresh object:ws userInfo:@{@"operation" : @"loadNew"}];
//						[ws.view endEditing:YES];
//						[ws dismissViewControllerAnimated:YES completion:nil];
//					}
//					else
//					{
//						if (isNSDictionaryClass(obj))
//						{
//		                    //服务器返回的错误描述
//							NSString *msg = obj[kRetMsg];
//							postTips(msg, @"发表动态失败");
//						}
//						else
//						{
//		                    //AFN请求失败的错误描述
//							postTips(obj, @"发表动态失败");
//						}
//					}
//				}];
//			}
//			else
//			{
//				postTips(obj, @"上传图片失败");
//			}
//		} progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {}];
////		});
//	}
//}
//
//#pragma mark UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *, id> *)info
//{
//	//拍照上传
//	DDLog(@"%@", info);
//	[picker dismissViewControllerAnimated:YES completion:nil];
//	UIImage *originImage = info[@"UIImagePickerControllerOriginalImage"];
//	[self.imageArray addObject:originImage];
//
//	if (self.imageArray.count > 9)
//	{
//		while (self.imageArray.count > 9) {
//			[self.imageArray removeLastObject];
//		}
//	}
//
//	[self layoutImageViewAndBtn];
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//	[picker dismissViewControllerAnimated:YES completion:nil];
//}
//
//#pragma mark scrollView delegate
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//	[self.view endEditing:YES];
//}
//
//#pragma mark textView delegate
//- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//	if ([text isEqualToString:@"\n"])
//	{
////		[self.view endEditing:YES];
//	}
//	DDLog(@"%ld,%@", range.location, text);
//
//	NSString *result;
//
//	if (textView.text.length >= range.length)
//	{
//		result = [textView.text stringByReplacingCharactersInRange:range withString:text];
//	}
//
//	if (result.length > 500)
//	{
//		return NO;
//	}
//	return YES;
//}
//
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//	self.imagePickerVc = nil;
//	// Dispose of any resources that can be recreated.
//}
//
//- (UIImage *)createThumbnailImage:(UIImage *)image
//{
//	@autoreleasepool {
//		//将图片转换为JPG格式的二进制数据
//		NSData *data = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
//
//		//		DDLog(@"image originalSize = %ld", data.length)
//		if (data == nil)
//		{
//			return image;
//		}
//		float scale = 10 / data.length;
//
//		NSData *data2 = UIImageJPEGRepresentation(image, scale);
//
//		//将二进制数据生成UIImage
//
//		UIImage *finalImage = [[UIImage alloc] initWithData:data2];
//
//		return finalImage;
//	}
//}
//
//- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
//{
//	UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
//	[image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
//	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	return scaledImage;
//}
//
//- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect
//{
//	CGImageRef newImageRef = CGImageCreateWithImageInRect([image CGImage], rect);
//	UIImage *newImage = [[UIImage alloc] initWithCGImage:newImageRef];
//
//	CGImageRelease(newImageRef);
//
//	return newImage;
//}
//
//- (UIImage *)getLowQualityImage:(UIImage *)image
//{
//	@autoreleasepool {
//		CGFloat width = image.size.width / SCREEN_WIDTH;
//		CGFloat height = image.size.height / SCREEN_HEIGHT;
//		CGFloat factor = fmax(width, height);
//
//		CGFloat newWidth = image.size.width / factor;
//		CGFloat newHeight = image.size.height / factor;
//		CGSize newSize = CGSizeMake(newWidth, newHeight);
//
//		UIGraphicsBeginImageContext(newSize);
//		[image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//		UIImage *finalImage = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(newImage, 0.1)];
//
//		return finalImage;
//	}
//}
//
//#pragma mark
//- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray <UIImage *> *)photos sourceAssets:(NSArray *)assets
//{
//	if (![assets[0] isKindOfClass:[UIImage class]])
//	{
//        [self.imageArray addObjectsFromArray:photos];
//	}
//	else
//	{
//		[self.imageArray addObjectsFromArray:assets];
//	}
//
//	if (self.imageArray.count > 9)
//	{
//		while (self.imageArray.count > 9) {
//			[self.imageArray removeLastObject];
//		}
//	}
//	MyWeakSelf
//	dispatch_async(dispatch_get_main_queue(), ^{
//		[ws layoutImageViewAndBtn];
//	});
//}
//
//@end
