//
//  UIImage+CYCategory.h
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <CoreMedia/CMSampleBuffer.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CYCategory)

/**
 * 将视频流单帧数据转化为UIImage
 * bufferRef: 视频流图像数据
 * fromFrontCamera: 是否通过前置摄像头拍着
 */
+ (UIImage *)cyImageWithSampleBuffer:(CMSampleBufferRef)bufferRef fromFrontCamera:(BOOL)fromFrontCamera;
+ (UIImage *)cyImageWithImageBuffer:(CVImageBufferRef)imgbufferRef fromFrontCamera:(BOOL)fromFrontCamera;

/**
 * 图片方向矫正
 * 将ImageOrientation非Up的转化为Up的图像
 */
- (UIImage *)cyUpOrientationImage;

@end

NS_ASSUME_NONNULL_END
