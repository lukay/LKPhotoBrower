//
//  WTPhotoView.h
//  LilysFriends
//
//  Created by wintelsui on 7/29/17.
//  Copyright (c) 2017 wintelsui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^photoViewBackSingleTap)(void);
typedef void(^photoViewBackDoubleTap)(void);
typedef void(^photoViewBackLongTap)(void);


@interface WTPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImage *image;

+ (WTPhotoView *)photoViewMakeWithFrame:(CGRect)frame;

- (UIImageView *)imgView;

- (void)setup;
- (void)loadImage:(UIImage *)image;
- (void)scaleImageMin;

@property (nonatomic, copy) photoViewBackSingleTap singleTapBlock;
@property (nonatomic, copy) photoViewBackDoubleTap doubleTapBlock;
@property (nonatomic, copy) photoViewBackLongTap longTapBlock;

@property (nonatomic) BOOL rotateEnable;

@end
