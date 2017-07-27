//
//  YHWorkGroupPhotoContainer.h
//  HKPTimeLine
//
//  Created by samuelandkevin on 16/9/20.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YHWorkGroupPhotoContainer : UIView

@property (nonatomic, strong) NSArray *picUrlArray;//缩略图URL
@property (nonatomic, strong) NSArray *picOriArray;//原图url

- (instancetype)initWithWidth:(CGFloat)width;

- (CGFloat)setupPicUrlArray:(NSArray *)picUrlArray;

@end
