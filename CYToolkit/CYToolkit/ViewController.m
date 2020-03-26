//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "CYAlbumPhotoTraversaler.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CYAlbumPhotoTraversaler *tmpTv = [[CYAlbumPhotoTraversaler alloc] init];
    
    static int i = 0;
    [UIImage cyTraversalUserPhotosWithCallback:^(NSString * _Nonnull albumName, UIImage * _Nonnull image) {
        NSLog(@"%04d   %@", i, NSStringFromCGSize(image.size));
        i++;
    }];
    
//    [UIImage cyTraversalPhotosInAlbum:@"Favorites" withCallback:^(NSString * _Nonnull albumName, UIImage * _Nonnull image) {
//                NSLog(@"%04d   %@", i, NSStringFromCGSize(image.size));
//        i++;
//    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

@end
