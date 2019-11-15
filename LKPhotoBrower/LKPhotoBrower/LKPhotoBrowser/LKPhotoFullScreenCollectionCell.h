//
//  LKPhotoFullScreenCollectionCell.h
//  LilysFriends
//
//  Created by wintel on 2017/7/24.
//  Copyright © 2017年 wintelsui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTPhotoView.h"

@protocol LKPhotoFullScreenCollectionCellDelegate <NSObject>

@optional
- (void)lkpb_singleTapGesture;

@end

@interface LKPhotoFullScreenCollectionCell : UICollectionViewCell

@property (nonatomic, assign) id <LKPhotoFullScreenCollectionCellDelegate> delegate;
@property (nonatomic, strong) WTPhotoView *photoView;
@property (nonatomic, strong) UIButton *playBtn;

- (void)loadImage:(UIImage *)image;
- (void)scaleImageMin;


@end
