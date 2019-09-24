//
//  PhotoBrowerCell.h
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoBrowerCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIScrollView *cSView;
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) UIButton *playBtn;

@end

NS_ASSUME_NONNULL_END
