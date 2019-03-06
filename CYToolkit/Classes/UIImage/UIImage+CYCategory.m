//
//  UIImage+CYCategory.m
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "UIImage+CYCategory.h"

@implementation UIImage (CYCategory)

+ (UIImage *)cyImageWithSampleBuffer:(CMSampleBufferRef)bufferRef fromFrontCamera:(BOOL)fromFrontCamera {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(bufferRef);
    return [self cyImageWithImageBuffer:imageBuffer fromFrontCamera:fromFrontCamera];
}

+ (UIImage *)cyImageWithImageBuffer:(CVImageBufferRef)imgbufferRef fromFrontCamera:(BOOL)fromFrontCamera {
    
    CVImageBufferRef imageBuffer = imgbufferRef;
    
    CGImageRef quartzImage = nil;
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    {
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context =
        CGBitmapContextCreate(baseAddress,
                              width,
                              height,
                              8,
                              bytesPerRow,
                              colorSpace,
                              kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                              );
        quartzImage = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    /* 前摄像头取 LeftMirrored， 后摄像头取Right */
    UIImage *tmpImage = nil;
    if (fromFrontCamera) {
        tmpImage = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationLeftMirrored];
    } else {
        tmpImage = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationRight];
    }
    CGImageRelease(quartzImage);
    
    return tmpImage;
}

- (UIImage *)cyUpOrientationImage {
    
    if (UIImageOrientationUp == self.imageOrientation) {
        return self;
    }
    
    CGAffineTransform toUpTransform = [self toUpTransform];
    CGRect toUpRect = [self toUpRect];
    
    CGContextRef ctx =
    CGBitmapContextCreate(NULL,                                     /* Data */
                          self.size.width,                          /* Width */
                          self.size.height,                         /* Height */
                          CGImageGetBitsPerComponent(self.CGImage), /* BitsPerComponent */
                          0,                                        /* bytesPerRow */
                          CGImageGetColorSpace(self.CGImage),       /* ColorSpace */
                          CGImageGetBitmapInfo(self.CGImage)        /* BigmapInfo */
                          );
    
    CGContextConcatCTM(ctx, toUpTransform);
    
    /* 绘制图像 */
    CGContextDrawImage(ctx, toUpRect, self.CGImage);
    
    /* 提取图像 */
    CGImageRef tarImgRef = CGBitmapContextCreateImage(ctx);
    UIImage *upImage = [UIImage imageWithCGImage:tarImgRef];
    
    /* 释放内存 */
    CGContextRelease(ctx);
    CGImageRelease(tarImgRef);
    
    /* 返回新图 */
    return upImage;
}

#pragma mark - MISC

- (CGAffineTransform)toUpTransform {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    /* 旋转 - Down 处理 */
    if (UIImageOrientationDown == self.imageOrientation
        || UIImageOrientationDownMirrored == self.imageOrientation) {
        transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }
    
    /* 旋转 - Left 处理 */
    else if (UIImageOrientationLeft == self.imageOrientation
             || UIImageOrientationLeftMirrored == self.imageOrientation) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    
    /* 旋转 - Right 处理 */
    else if (UIImageOrientationRight == self.imageOrientation
             || UIImageOrientationRightMirrored == self.imageOrientation) {
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    
    /* 镜像 - Up / Down 方向 */
    if (UIImageOrientationUpMirrored == self.imageOrientation
        || UIImageOrientationDownMirrored == self.imageOrientation) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    /* 镜像 - Left / Right 方向 */
    else if (UIImageOrientationLeftMirrored == self.imageOrientation
             || UIImageOrientationRightMirrored == self.imageOrientation) {
        transform = CGAffineTransformTranslate(transform, self.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    return transform;
}

- (CGRect)toUpRect {
    
    CGRect tarRect = CGRectZero;
    
    /* 左右方向，长宽颠倒 */
    if (UIImageOrientationLeft == self.imageOrientation
        || UIImageOrientationLeftMirrored == self.imageOrientation
        || UIImageOrientationRight == self.imageOrientation
        || UIImageOrientationRightMirrored == self.imageOrientation) {
        tarRect = CGRectMake(0, 0, self.size.height, self.size.width);
    }
    
    /* 上下方向，长宽一致 */
    else {
        tarRect = CGRectMake(0, 0, self.size.width, self.size.height);
    }
    
    return tarRect;
}

@end
