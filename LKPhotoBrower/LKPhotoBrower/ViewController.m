//
//  ViewController.m
//  LKPhotoBrower
//
//  Created by LK on 2019/9/24.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import "ViewController.h"

#import "ImageDataSingleTest.h"
#import "LKPhotoBrowerVC.h"

@interface ViewController ()
{
    UIImageView *_sourceImageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        imageView;
    });
    
    [self.view addSubview:_sourceImageView];
    ImageDataSingleTest *imd = [ImageDataSingleTest new];
    [imd imageThumbnail:nil original:^(UIImage * _Nullable image, NSString * _Nullable imagePath) {
        self->_sourceImageView.image = image;
    }];
    
    _sourceImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_sourceImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:64].active = YES;
    [_sourceImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_sourceImageView.widthAnchor constraintEqualToConstant:200].active = YES;
    [_sourceImageView.heightAnchor constraintEqualToConstant:200].active = YES;
    
    
    UIButton *myButton = ({
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bt setBackgroundColor:[UIColor clearColor]];
        
        [bt addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        bt;
    });
    [self.view addSubview:myButton];
    
    myButton.translatesAutoresizingMaskIntoConstraints = NO;
    [myButton.topAnchor constraintEqualToAnchor:_sourceImageView.topAnchor].active = YES;
    [myButton.bottomAnchor constraintEqualToAnchor:_sourceImageView.bottomAnchor].active = YES;
    [myButton.leadingAnchor constraintEqualToAnchor:_sourceImageView.leadingAnchor].active = YES;
    [myButton.trailingAnchor constraintEqualToAnchor:_sourceImageView.trailingAnchor].active = YES;
    
    
}

- (void)actionButtonPressed:(id) sender{
    //(nonnull NSArray<LKPhotoBrowserImageDataSingleTestProtocol> *)
    NSMutableArray *images = [NSMutableArray new];
    
    [images addObject:[ImageDataSingleTest new]];
    [images addObject:[ImageDataSingleTest new]];
    [images addObject:[ImageDataSingleTest new]];
    [images addObject:[ImageDataSingleTest new]];
    [images addObject:[ImageDataSingleTest new]];
    
    LKPhotoBrowerVC *iv = [LKPhotoBrowerVC photoBrowserForImages:[images copy] index:0 source:@[_sourceImageView,_sourceImageView,_sourceImageView,_sourceImageView,_sourceImageView]];
    [iv showFromViewController:self];
}


@end
