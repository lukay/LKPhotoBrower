//
//  LKPhotoBrowerVC.h
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;
@import AVKit;

@protocol LKPhotoBrowserImageDataProtocol <NSObject>

@required

/// 原始图片
- (void)imageThumbnail:(void (^ __nullable)(UIImage *_Nullable image, NSString *_Nullable imagePath))thumbnailHander
              original:(void (^ __nullable)(UIImage *_Nullable image, NSString *_Nullable imagePath))originalHander;

- (BOOL)videoMedeaType;
- (void)videoPlayerItemCompletion:(void (^ __nullable)(AVPlayerItem * _Nullable playerItem))completion;

@optional

- (void)mediaFileSizeStrCompletion:(void (^ __nullable)(NSString * _Nullable sizeStr))completion;
/// 保存副本
- (BOOL)saveEctype;
- (BOOL)saveReplace;
- (void)replaceByImage:(UIImage *_Nonnull)image;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LKPhotoBrowerVC : UIViewController

+ (instancetype)photoBrowserForImages:(NSArray<LKPhotoBrowserImageDataProtocol> *)dataArray
                                index:(NSInteger)currentIndex
                               source:(NSArray<UIImageView *> *)sourceImgViews;

- (void)showFromViewController:(UIViewController * _Nonnull)rootViewController;

@property (nonatomic, strong) NSArray<LKPhotoBrowserImageDataProtocol> *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray<UIImageView *> *sourceImgViews;

@end

NS_ASSUME_NONNULL_END
