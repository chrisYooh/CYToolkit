//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "LYSmartImageView.h"

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_testImageView setUserInteractionEnabled:YES];
    [_testImageView cyOpenPreviewPower];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    [UIView cyShowToast:@"捂脸fff"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UIImage *tmpImage = _testImageView.image;
    
    NSLog(@"\nSIZE %@\n""OTN %lu", NSStringFromCGSize(tmpImage.size), tmpImage.imageOrientation);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, tmpImage.size.width, tmpImage.size.height);
    transform = CGAffineTransformRotate(transform, M_PI);

    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             tmpImage.size.width,
                                             tmpImage.size.height,
                                             CGImageGetBitsPerComponent(tmpImage.CGImage),
                                             0,
                                             CGImageGetColorSpace(tmpImage.CGImage),
                                             CGImageGetBitmapInfo(tmpImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0, 0, tmpImage.size.width, tmpImage.size.height), tmpImage.CGImage);

    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    _testImageView.image = img;

    NSLog(@"\nSIZE %@\n""OTN %lu", NSStringFromCGSize(img.size), img.imageOrientation);
}


@end
