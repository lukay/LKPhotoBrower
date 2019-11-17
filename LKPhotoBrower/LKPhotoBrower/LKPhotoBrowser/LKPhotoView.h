//
//  LKPhotoView.h
//  LilysFriends
//
//  Created by wintelsui on 7/29/17.
//  Copyright (c) 2017 wintelsui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhotoViewCallSingleTap)(void);
typedef void(^PhotoViewCallDoubleTap)(void);
typedef void(^PhotoViewCallLongTap)(void);


@interface LKPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImage *image;

+ (LKPhotoView *)photoViewMakeWithFrame:(CGRect)frame;

- (UIImageView *)imgView;

- (void)setup;
- (void)loadImage:(UIImage *)image;
- (void)scaleImageMin;

@property (nonatomic, copy) PhotoViewCallSingleTap singleTapBlock;
@property (nonatomic, copy) PhotoViewCallDoubleTap doubleTapBlock;
@property (nonatomic, copy) PhotoViewCallLongTap longTapBlock;

@property (nonatomic) BOOL rotateEnable;

@end
