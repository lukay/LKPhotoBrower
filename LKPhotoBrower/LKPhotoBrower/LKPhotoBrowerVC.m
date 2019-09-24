//
//  LKPhotoBrowerVC.m
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import "LKPhotoBrowerVC.h"
#import "PhotoBrowerCell.h"
//#import "UIColor+Cus.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@import Photos;

#define isPortrait ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)

@interface LKPhotoBrowerVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate>
{
    UICollectionViewFlowLayout *_layout;
    CGPoint _startLocation;
    CGRect _startFrame;
    CGPoint velocity;
    BOOL _isShow;
    UILabel *_fileSizeLabel;
    AVPlayer *_player;
    AVPlayerViewController *_playerController;
}
@property (nonatomic, strong) UICollectionView *collectionView;


@end

@implementation LKPhotoBrowerVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCollectionView];
    [self addGesture];
    self.view.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 20)];
    label.text = @"";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
    label.shadowOffset = CGSizeMake(0.5, 0.5);
    [self.view addSubview:label];
    _fileSizeLabel = label;

}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [_layout setItemSize:(CGSize){self.view.frame.size.width + 20,self.view.frame.size.height}];
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    
    [_collectionView setFrame:(CGRect){{-10,0},{self.view.frame.size.width + 20,self.view.frame.size.height}}];
    [_collectionView setCollectionViewLayout:_layout];
    if (!_isShow) {
        [self photoBrowserWillShowWithAnimated];
        _isShow = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self updateCurrentImageFileSize];
}

- (void)photoBrowserWillShowWithAnimated {
    [_collectionView setContentOffset:(CGPoint){_currentIndex * _layout.itemSize.width,0} animated:false];
    
    CGRect rect = [self.sourceImgView.superview convertRect:self.sourceImgView.frame toView:self.view];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.image = self.sourceImgView.image;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];
    
    [_collectionView setHidden:true];
    self.view.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [imgView setCenter:[self.view center]];
        [imgView setBounds:(CGRect){CGPointZero,CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)}];
        [self->_collectionView setAlpha:1];
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self->_collectionView setHidden:false];
        
        [UIView animateWithDuration:0.15 animations:^{
            [imgView setAlpha:0.f];
        } completion:^(BOOL finished) {
            [imgView removeFromSuperview];
        }];
    }];
    
}

- (void)addGesture {
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDidGesture:)]];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(scrollViewDidTap)];
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(scrollViewDidDoubleTap:)];
    
    
    // 2.set gesture require
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    
    // 3.conflict resolution
    [tap requireGestureRecognizerToFail:doubleTap];
    
    // 4.add gesture
    [self.view addGestureRecognizer:tap];
    [self.view addGestureRecognizer:doubleTap];
}

- (void)panDidGesture:(UIPanGestureRecognizer *)pan {
    
    if(!isPortrait) return;
    
    CGPoint point       = CGPointZero;
    CGPoint location    = CGPointZero;
    CGPoint velocity    = CGPointZero;
    
    UIImageView *imageView;
    
    CGPoint p = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    PhotoBrowerCell *cell = (PhotoBrowerCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    imageView = cell.imgView;
    
    if(cell.cSView.zoomScale > 1.f) return;
    point       = [pan translationInView:self.view];
    location    = [pan locationInView:cell.cSView];
    velocity    = [pan velocityInView:self.view];
    
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            _startLocation  = location;
            _startFrame = imageView.frame;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            double s = MAX(percent, 0.3);
            
            CGFloat width = _startFrame.size.width * s;
            CGFloat height = _startFrame.size.height * s;
            
            CGFloat rateX = (_startLocation.x - _startFrame.origin.x) / _startFrame.size.width;
            CGFloat x = location.x - width * rateX;
            
            CGFloat rateY = (_startLocation.y - _startFrame.origin.y) / _startFrame.size.height;
            CGFloat y = location.y - height * rateY;
            imageView.frame = CGRectMake(x, y, width, height);

            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:percent];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            if(fabs(point.y) > 200 || fabs(velocity.y) > 500){
                // dismiss
                _startFrame = imageView.frame;
//                [self dismissController];
                UIImageView *imgVeiw = [[UIImageView alloc] initWithFrame:imageView.frame];
                imgVeiw.image = imageView.image;
                [self.view addSubview:imgVeiw];
                self.collectionView.hidden = YES;
                self.view.backgroundColor = [UIColor clearColor];
                CGRect rect = [self.sourceImgView.superview convertRect:self.sourceImgView.frame toView:self.view];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    imgVeiw.frame = rect;
                    self->_collectionView.alpha = 0.f;
                } completion:^(BOOL finished) {
                    self->_startFrame = CGRectZero;
                    [imgVeiw removeFromSuperview];
                    [self dismissViewControllerAnimated:false completion:nil];
                }];
            }else{
                [self cancelAnimation:imageView];
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)cancelAnimation:(UIImageView *)imageView{
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = self->_startFrame;
    } completion:^(BOOL finished) {
        self.view.backgroundColor = [UIColor blackColor];
    }];
}

- (void)dismissController {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->_collectionView.alpha = 0.f;
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:false completion:nil];
    }];
}

#pragma mark - 长按
- (void)longPressDidPress:(UILongPressGestureRecognizer *)longPress{
    if(longPress.state == UIGestureRecognizerStateBegan){
    
    }
}

- (void)scrollViewDidTap{
    [self dismissController];
}

#pragma mark - 双击
- (void)scrollViewDidDoubleTap:(UITapGestureRecognizer *)doubleTap{
    // if image is download, if not ,just return;
    
    
    CGPoint p = [doubleTap locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
        return;
    }
    
    PHAsset *asset = [self.dataArray objectAtIndex:indexPath.item];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        return;
    }
    
    PhotoBrowerCell *cell = (PhotoBrowerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if(!cell || !cell.imgView.image) {
        return;
    }

    if(cell.cSView.zoomScale <= 1){
        // 1.catch the postion of the gesture
        // 2.contentOffset.x of scrollView  + location x of gesture
        CGFloat x = [doubleTap locationInView:cell].x + cell.cSView.contentOffset.x;
        // 3.contentOffset.y + location y of gesture
        CGFloat y = [doubleTap locationInView:cell].y + cell.cSView.contentOffset.y;
        [cell.cSView zoomToRect:(CGRect){{x,y},CGSizeZero} animated:true];
    }else{
        // set scrollView zoom to original
        [cell.cSView setZoomScale:1.f animated:true];
    }
}

- (void)setupCollectionView {
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(self.view.frame.size.width+20, self.view.frame.size.height);
    _layout = layout;
    CGRect collectionRect = CGRectMake(-10, 0, self.view.frame.size.width+20, self.view.frame.size.height);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionRect collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setPagingEnabled:true];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setScrollsToTop:false];
    [_collectionView setShowsHorizontalScrollIndicator:false];
    [_collectionView setContentOffset:CGPointZero];
    [_collectionView setAlpha:1.f];
    [_collectionView setBounces:true];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoBrowerCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoBrowerCellID"];
    [self.view addSubview:self.collectionView];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (void)updateFileSizeLabel:(float)fileSize {
    if (fileSize <= 0) {
        _fileSizeLabel.text = @"";
        return;
    }
    float ns = fileSize;
    NSString *unitStr = @"Kb";
    if (fileSize > 1024) {
        ns = fileSize/1024;
        unitStr = @"Mb";
        if (ns > 1024) {
            ns = ns/1024;
            unitStr = @"Gb";
        }
    }
    _fileSizeLabel.text = [NSString stringWithFormat:@"%.1f%@", ns, unitStr];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(updateCurrentImageFileSize) withObject:nil afterDelay:0.2];
}

- (void)updateCurrentImageFileSize {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    PHAsset *asset = [self.dataArray objectAtIndex:indexPath.item];
//    [LKPhotoManager getAssetSize:asset callback:^(float length) {
//        [self updateFileSizeLabel:length];
//    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoBrowerCellID" forIndexPath:indexPath];
    PHAsset *asset = [self.dataArray objectAtIndex:indexPath.item];
//    [LKPhotoManager getOrignalImageFromAlAsset:asset callback:^(UIImage * image) {
//        cell.imgView.image = image;
//    }];
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.playBtn.hidden = NO;
        if (![cell.playBtn.allTargets containsObject:self]) {
               [cell.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
           }
    }else {
        cell.playBtn.hidden = YES;
        [cell.playBtn removeTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (void)playBtnClick:(UIButton *)playBtn {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    PHAsset *asset = [self.dataArray objectAtIndex:indexPath.item];
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        return;
    }
//    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset.asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
//        [self player:playerItem];
//    }];
}

- (void)player:(AVPlayerItem *)playerItem {
    
//    AVPlayerViewController *a= nil;
    if (_player) {
        [_player pause];
        
    }
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    _playerController = [[AVPlayerViewController alloc] init];
    _playerController.player = _player;
    _playerController.view.frame = self.view.bounds;
    _playerController.showsPlaybackControls = YES;
    
    [self presentViewController:_playerController animated:YES completion:^{
        [self->_playerController.player play];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
