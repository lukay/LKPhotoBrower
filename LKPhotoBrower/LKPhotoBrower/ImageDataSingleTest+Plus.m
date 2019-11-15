//
//  ImageDataSingleTest+Plus.m
//  LKPhotoBrower
//
//  Created by Macintosh HD on 2019/11/15.
//  Copyright © 2019 Lukay. All rights reserved.
//

#import "ImageDataSingleTest+Plus.h"

@implementation ImageDataSingleTest (Plus)

- (void)imageThumbnail:(void (^ _Nullable)(UIImage * _Nullable, NSString * _Nullable))thumbnailHander original:(void (^ _Nullable)(UIImage * _Nullable, NSString * _Nullable))originalHander {
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"th.jpg" ofType:@""]];
    originalHander(image,nil);
}

- (BOOL)videoMedeaType {
    
    return NO;
}

- (void)videoPlayerItemCompletion:(void (^ _Nullable)(AVPlayerItem * _Nullable))completion {
    completion(nil);
}

@end
