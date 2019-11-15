//
//  LKPhotoBrowerVC.m
//  QingQing
//
//  Created by LK on 2019/8/23.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import "LKPhotoBrowerVC.h"
#import "PhotoBrowerCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "LKPhotoFullScreenCollectionCell.h"

#define isPortrait ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)

@interface LKPhotoBrowerVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate,LKPhotoFullScreenCollectionCellDelegate>
{
    UICollectionViewFlowLayout *_layout;
    CGPoint _startLocation;
    CGRect _startFrame;
    CGPoint velocity;
    BOOL _isShow;
    UILabel *_fileSizeLabel;
    AVPlayer *_player;
    AVPlayerViewController *_playerController;
    
    UIPageControl *_pageControl;
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

+ (instancetype)photoBrowserForImages:(NSArray<LKPhotoBrowserImageDataProtocol> *)dataArray index:(int)currentIndex source:(UIImageView *)sourceImgView{
    
    LKPhotoBrowerVC *iv = [[LKPhotoBrowerVC alloc] init];
    iv.dataArray = [dataArray copy];
    iv.currentIndex = currentIndex;
    iv.sourceImgView = sourceImgView;
    
    return iv;
}

- (void)showFromViewController:(UIViewController *)rootViewController{
    [rootViewController presentViewController:self animated:YES completion:nil];
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
    
    _pageControl = ({
        UIPageControl *pc = [[UIPageControl alloc] init];
        pc.hidesForSinglePage = YES;
        
        [self.view addSubview:pc];
        
        pc.translatesAutoresizingMaskIntoConstraints = NO;
        [pc.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20].active = YES;
        [pc.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20].active = YES;
        [pc.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
        [pc.heightAnchor constraintEqualToConstant:20].active = YES;
        
        pc;
    });
    _pageControl.numberOfPages = [self.dataArray count];
    _pageControl.currentPage = self.currentIndex;
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20].active = YES;
    [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [label.bottomAnchor constraintEqualToAnchor:_pageControl.topAnchor constant:-5].active = YES;
    [label.heightAnchor constraintEqualToConstant:20].active = YES;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [_layout setItemSize:(CGSize){self.view.frame.size.width,self.view.frame.size.height}];
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    
    [_collectionView setFrame:(CGRect){{0,0},{self.view.frame.size.width,self.view.frame.size.height}}];
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
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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

//LKPhotoFullScreenCollectionCellDelegate <NSObject>
- (void)lkpb_singleTapGesture{
    [self scrollViewDidTap];
}
- (void)addGesture {
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDidGesture:)]];
}

- (void)panDidGesture:(UIPanGestureRecognizer *)pan {
    
    if(!isPortrait) return;
    
    CGPoint point       = CGPointZero;
    CGPoint location    = CGPointZero;
    CGPoint velocity    = CGPointZero;
    
    UIImageView *imageView;
    
    CGPoint p = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    LKPhotoFullScreenCollectionCell *cell = (LKPhotoFullScreenCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    imageView = [cell.photoView imgView];
    
    if(cell.photoView.zoomScale > 1.f) return;
    point       = [pan translationInView:self.view];
    location    = [pan locationInView:cell.photoView];
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
                CGRect rectOld = [imageView.superview convertRect:imageView.frame toView:self.view];
                UIImageView *imgVeiw = [[UIImageView alloc] initWithFrame:rectOld];
                imgVeiw.image = imageView.image;
                
                imgVeiw.contentMode = self.sourceImgView.contentMode;
                imgVeiw.clipsToBounds = self.sourceImgView.clipsToBounds;
                
                [self.view addSubview:imgVeiw];
                self.collectionView.hidden = YES;
                self.view.backgroundColor = [UIColor clearColor];
                CGRect rect = [self.sourceImgView.superview convertRect:self.sourceImgView.frame toView:self.view];
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
    LKPhotoFullScreenCollectionCell *cell = (LKPhotoFullScreenCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *imageView = [cell.photoView imgView];
    
    CGRect rectOld = [[cell.photoView imgView].superview convertRect:[cell.photoView imgView].frame toView:self.view];
    
    UIImageView *imgVeiw = [[UIImageView alloc] initWithFrame:rectOld];
    imgVeiw.image = imageView.image;
    
    imgVeiw.contentMode = self.sourceImgView.contentMode;
    imgVeiw.clipsToBounds = self.sourceImgView.clipsToBounds;
    
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
}

- (void)scrollViewDidTap{
    [self dismissController];
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

    [self.collectionView registerClass:[LKPhotoFullScreenCollectionCell class] forCellWithReuseIdentifier:@"PhotoBrowerCellID"];
    
    [self.view addSubview:self.collectionView];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(updateCurrentImageFileSize) withObject:nil afterDelay:0.2];
}

- (void)updateCurrentImageFileSize {
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems].firstObject;
    id asset = [self.dataArray objectAtIndex:indexPath.item];
    if ([asset respondsToSelector:@selector(mediaFileSizeStrCompletion:)]){
        
        [asset mediaFileSizeStrCompletion:^(NSString * _Nullable sizeStr) {
            if (sizeStr != nil) {
                self ->_fileSizeLabel.text = sizeStr;
            }else{
                self ->_fileSizeLabel.text = @"";
            }
        }];
    }
    _pageControl.currentPage = indexPath.item;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LKPhotoFullScreenCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoBrowerCellID" forIndexPath:indexPath];
    cell.delegate = self;
    id asset = [self.dataArray objectAtIndex:indexPath.item];

    __weak typeof(cell)weakCell = cell;
    
    [asset imageThumbnail:^(UIImage * _Nullable image, NSString * _Nullable imagePath) {
        if (image){
            [weakCell loadImage:image];
        }else if (imagePath != nil && imagePath.length > 0) {
            if ([imagePath hasPrefix:@"http"] || [imagePath hasPrefix:@"ftp"]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSURL *url = [NSURL URLWithString:imagePath];
                    if (url) {
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        UIImage *imageFinal = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakCell loadImage:imageFinal];
                        });
                    }
                });
            }else{
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [weakCell loadImage:image];
            }
        }else{
            [weakCell loadImage:nil];
        }
    } original:^(UIImage * _Nullable image, NSString * _Nullable imagePath) {
        if (image){
            [weakCell loadImage:image];
        }else if (imagePath != nil && imagePath.length > 0) {
            if ([imagePath hasPrefix:@"http"] || [imagePath hasPrefix:@"ftp"]) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSURL *url = [NSURL URLWithString:imagePath];
                    if (url) {
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        UIImage *imageFinal = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakCell loadImage:imageFinal];
                        });
                    }
                });
            }else{
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [weakCell loadImage:image];
            }
        }else{
            [weakCell loadImage:nil];
        }
    }];
    if ([asset videoMedeaType]) {
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
    id asset = [self.dataArray objectAtIndex:indexPath.item];
    if (![asset videoMedeaType]) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    [asset videoPlayerItemCompletion:^(AVPlayerItem * _Nullable playerItem) {
        if(playerItem){
            [weakSelf player:playerItem];
        }
    }];
}

- (void)player:(AVPlayerItem *)playerItem {
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

@end
