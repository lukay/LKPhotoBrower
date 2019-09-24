//
//  PhotoBrowerCell.m
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import "PhotoBrowerCell.h"

@interface PhotoBrowerCell () <UIScrollViewDelegate>

@end

@implementation PhotoBrowerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(0, 0, 60, 60);
    [self.playBtn setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    [self.imgView addSubview:_playBtn];
    
}

-(void)layoutSubviews {
    self.imgView.frame = CGRectMake(-10, 0, self.frame.size.width, self.frame.size.height);
    self.playBtn.center = CGPointMake(self.imgView.frame.size.width/2, self.imgView.frame.size.height/2);
}

- (void)setImage:(UIImage *)image {
    self.imgView.image = image;
}

- (void)reloadFrames{
    CGRect frame = _cSView.frame;
    if(_imgView.image){
        
        CGSize imageSize = _imgView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (frame.size.width <= frame.size.height) { // if scrollView.width <= height
            // let width of the image set as width of scrollView, height become radio
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = frame.size.width;
        }else{
            // let width of the image set as width of scrollView, height become radio
            CGFloat ratio = frame.size.height / imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        [_imgView setFrame:(CGRect){CGPointZero,imageFrame.size}];
        
        // set scrollView contentsize
        _cSView.contentSize = _imgView.frame.size;
        
        // set scrollView.contentsize as image.size , and get center of the image
        _imgView.center = [self centerOfScrollViewContent:_cSView];
        // get the radio of scrollView.height and image.height
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        // get radio of the width
        CGFloat widthRadit = frame.size.width / imageFrame.size.width;
        
        // get the max radio
        maxScale = widthRadit > maxScale?widthRadit:maxScale;
        // if the max radio >= PhotoBrowerImageMaxScale, get max radio , else PhotoBrowerImageMaxScale
        maxScale = maxScale > 2.0f?maxScale:2.0f;
        
        // set max and min radio of scrollView
        _cSView.minimumZoomScale = 1.f;
        _cSView.maximumZoomScale = maxScale;
        
        // set scrollView zoom original
        _cSView.zoomScale = 1.0f;
        
    }else{
        frame.origin = CGPointZero;
        _imgView.frame = frame;
        _cSView.contentSize = _imgView.frame.size;
    }
    _cSView.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView{
    // scrollView.bounds.size.width > scrollView.contentSize.width :that means scrollView.size > image.size
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    // zoom the subviews of the scrollView
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // reset the center of image when dragging everytime
    _imgView.center = [self centerOfScrollViewContent:scrollView];
}

@end
