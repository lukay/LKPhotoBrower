//
//  LKPhotoFullScreenCollectionCell.m
//  LilysFriends
//
//  Created by wintel on 2017/7/24.
//  Copyright © 2017年 wintelsui. All rights reserved.
//

#import "LKPhotoFullScreenCollectionCell.h"

#import "WTPhotoView.h"

@interface LKPhotoFullScreenCollectionCell ()
<
UIScrollViewDelegate,
UIGestureRecognizerDelegate
>
{
    
}
@end

@implementation LKPhotoFullScreenCollectionCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat sW = self.frame.size.width;
        CGFloat sH = self.frame.size.height;
        
        __weak typeof(self)weakself = self;
        
        
        _photoView = [WTPhotoView photoViewMakeWithFrame:CGRectMake(0, 0, sW, sH)];
        [self.contentView addSubview:_photoView];
        _photoView.singleTapBlock = ^{
            if (weakself.delegate != nil && [weakself.delegate respondsToSelector:@selector(lkpb_singleTapGesture)]) {
                [weakself.delegate lkpb_singleTapGesture];
            }
        };
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtn.frame = CGRectMake(0, 0, 60, 60);
        [self.playBtn setImage:[LKPhotoFullScreenCollectionCell playButtonImage] forState:UIControlStateNormal];
        [self.contentView addSubview:_playBtn];
        
        self.playBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.playBtn.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [self.playBtn.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [self.playBtn.widthAnchor constraintEqualToConstant:60].active = YES;
        [self.playBtn.heightAnchor constraintEqualToConstant:60].active = YES;
    }
    return self;
}

- (void)loadImage:(UIImage *)image{
    if (image) {
        [_photoView loadImage:image];
    }
}

- (void)scaleImageMin{
    [_photoView scaleImageMin];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
//    NSLog(@"handleSingleTap");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(lkpb_singleTapGesture)]) {
        [self.delegate lkpb_singleTapGesture];
    }
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        NSLog(@"handleLongTap");
    }
}


+ (UIImage *)playButtonImage{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(104,104), 0, [UIScreen mainScreen].scale);
    
    UIColor* fillColor = [UIColor colorWithRed: 0.726 green: 0.726 blue: 0.726 alpha: 0.839];

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(52, 1)];
    [bezierPath addCurveToPoint: CGPointMake(1, 52) controlPoint1: CGPointMake(23.83, 1) controlPoint2: CGPointMake(1, 23.83)];
    [bezierPath addCurveToPoint: CGPointMake(52, 103) controlPoint1: CGPointMake(1, 80.17) controlPoint2: CGPointMake(23.83, 103)];
    [bezierPath addCurveToPoint: CGPointMake(103, 52) controlPoint1: CGPointMake(80.17, 103) controlPoint2: CGPointMake(103, 80.17)];
    [bezierPath addCurveToPoint: CGPointMake(52, 1) controlPoint1: CGPointMake(103, 23.83) controlPoint2: CGPointMake(80.17, 1)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(76.91, 53)];
    [bezierPath addCurveToPoint: CGPointMake(42.5, 73.08) controlPoint1: CGPointMake(74.32, 54.51) controlPoint2: CGPointMake(44.02, 72.2)];
    [bezierPath addCurveToPoint: CGPointMake(38.7, 70.91) controlPoint1: CGPointMake(40.61, 74.17) controlPoint2: CGPointMake(38.7, 72.78)];
    [bezierPath addLineToPoint: CGPointMake(38.7, 30.67)];
    [bezierPath addCurveToPoint: CGPointMake(42.42, 28.51) controlPoint1: CGPointMake(38.7, 28.61) controlPoint2: CGPointMake(40.81, 27.61)];
    [bezierPath addCurveToPoint: CGPointMake(76.91, 48.64) controlPoint1: CGPointMake(44.63, 29.75) controlPoint2: CGPointMake(75.05, 47.53)];
    [bezierPath addCurveToPoint: CGPointMake(76.91, 53) controlPoint1: CGPointMake(78.58, 49.64) controlPoint2: CGPointMake(78.61, 52.01)];
    [bezierPath closePath];
    [fillColor setFill];
    [bezierPath fill];

    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
    
}
@end
