//
//  LKPhotoBrowerVC.h
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKPhotoBrowerVC : UIViewController

@property (nonatomic, weak) NSArray *dataArray;
@property (nonatomic, assign) int currentIndex;

@property (nonatomic, weak) UIImageView *sourceImgView;

@end

NS_ASSUME_NONNULL_END
