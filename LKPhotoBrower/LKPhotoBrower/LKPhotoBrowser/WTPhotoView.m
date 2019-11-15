//
//  WTPhotoView.m
//  LilysFriends
//
//  Created by wintelsui on 7/29/17.
//  Copyright (c) 2017 wintelsui. All rights reserved.
//

#import "WTPhotoView.h"

@interface UIImage (WTUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (WTUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
//    CGSize imageSize = CGSizeMake(self.size.width / self.scale,self.size.height / self.scale);
    
    CGSize imageSize = self.size;
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (WTUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (WTUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.frame.size];
}

@end

@interface WTPhotoView () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic) BOOL rotating;
@property (nonatomic) CGSize minSize;

@end

@implementation WTPhotoView

+ (WTPhotoView *)photoViewMakeWithFrame:(CGRect)frame{
    return [[WTPhotoView alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (UIImageView *)imgView{
    return _imageView;
}

- (void)setup{
    self.delegate = self;
    self.bouncesZoom = YES;
    
    // Add container view
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    _containerView = containerView;
    
    // Add image view
    UIImageView *imageView = [[UIImageView alloc] init];
    [containerView addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView = imageView;
    
    // Setup other events
    [self setupGestureRecognizer];
    [self setupRotationNotification];
}

- (void)loadImage:(UIImage *)image{
    self.minimumZoomScale = 1.0;
    [self setZoomScale:self.minimumZoomScale animated:YES];
    
    self.containerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _image = image;
    _imageView.image = image;
    _imageView.frame = _containerView.bounds;
    
    // Fit container view's size to image size
    CGSize imageSize = _imageView.contentSize;
    self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
    
    self.contentSize = imageSize;
    self.minSize = imageSize;
    
    [self setMaxZoomScale];
    
    // Center containerView by set insets
    [self centerContent];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotateEnable) {
        if (self.rotating) {
            self.rotating = NO;
            
            // update container view frame
            CGSize containerSize = self.containerView.frame.size;
            BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
            
            CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
            CGFloat minZoomScale = imageSize.width / self.minSize.width;
            self.minimumZoomScale = minZoomScale;
            if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
                self.zoomScale = minZoomScale;
            }
            
            // Center container view
            [self centerContent];
        }
    }else{
        self.rotating = NO;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)setupGestureRecognizer
{
    //双击
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [_containerView addGestureRecognizer:doubleTapGesture];
    
    //单击
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [_containerView addGestureRecognizer:singleTapGesture];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    //长按
    UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleLongTap:)];
    longTapGesture.delegate = self;
    [longTapGesture setMinimumPressDuration:1.0];
    [_containerView addGestureRecognizer:longTapGesture];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}

#pragma mark - GestureRecognizer

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 100, 100);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
    
    if (_doubleTapBlock) {
        _doubleTapBlock();
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
    NSLog(@"handleSingleTap");
    if (_singleTapBlock) {
        _singleTapBlock();
    }
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        NSLog(@"handleLongTap");
        if (_longTapBlock) {
            _longTapBlock();
        }
    }
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = self.imageView.contentSize;
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(3, maxScale); // Should not less than 3
}

- (void)centerContent
{
    CGRect frame = self.containerView.frame;
    
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    
    top -= frame.origin.y;
    left -= frame.origin.x;
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

- (void)scaleImageMin{
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}
@end
