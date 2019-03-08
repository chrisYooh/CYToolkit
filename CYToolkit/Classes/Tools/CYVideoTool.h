//
//  CYVideoTool.h
//  CYToolkit
//
//  Created by Chris on 2019/3/5.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYVideoTool;

@protocol CYVideoToolDelegate <NSObject>

/* 获取原始的视频帧输出 */
- (void)videoTool:(CYVideoTool *)tool getSampleBuffer:(CMSampleBufferRef)bufferRef;

/* 获取视频帧转化为图像的输出,
 * 仅当transToImage为YES时回调 */
- (void)videoTool:(CYVideoTool *)tool captureOutputImage:(UIImage *)outImage;

@end

@interface CYVideoTool : NSObject

/* Delegate */
@property (nonatomic, weak) id<CYVideoToolDelegate> delegate;

/* Config */
@property (nonatomic, assign) BOOL confLogSecFrame;         /* 是否打印视频的每秒帧数，默认：NO */
@property (nonatomic, assign) BOOL confTransToImage;        /* 是否转化为UIImage，默认：YES */
@property (nonatomic, assign) BOOL confFlashOn;             /* 闪光灯是否开启，默认 NO */
@property (nonatomic, assign) BOOL confFrontCamera;         /* 是否使用前置摄像头，默认 YES */

/* Layer */
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewlayer;     /* 预览图层 */

/* Operation */
- (void)startSession;       /* 开始视频流 */
- (void)stopSession;        /* 暂停视频流 */

@end

NS_ASSUME_NONNULL_END
