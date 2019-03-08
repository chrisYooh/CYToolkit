//
//  CYVideoRecorder.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CYVideoRecorder;

@protocol CYVideoRecorderDelegate <NSObject>

- (void)recorderDidStartRecord:(CYVideoRecorder *)recorder;
- (void)recorder:(CYVideoRecorder *)recorder didFinishRecordToFile:(NSString *)filePath;
- (void)recorder:(CYVideoRecorder *)recorder getSampleBuffer:(CMSampleBufferRef)bufferRef;

@end

@interface CYVideoRecorder : NSObject

/* Delegate */
@property (nonatomic, weak) id<CYVideoRecorderDelegate> delegate;

/* Config */
@property (nonatomic, assign) BOOL confFlashOn;                     /* 闪光灯是否开启，默认 NO */
@property (nonatomic, assign) BOOL confFrontCamera;                 /* 是否使用前置摄像头，默认 YES */
@property (nonatomic, strong) AVCaptureSessionPreset confPreset;    /* 分辨率设置, 默认：AVCaptureSessionPresetHigh */

/* Status */
@property (nonatomic, assign, readonly) BOOL isRecording;           /* 是否在录制 */
@property (nonatomic, assign, readonly) float curRecordSec;         /* 当前录制秒数 */

/* Layer */
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewlayer;     /* 预览图层 */

/* Operation */
- (void)startSession;       /* 开始视频流 */
- (void)stopSession;        /* 暂停视频流 */

- (void)startRecord;        /* 开始录制 */
- (void)stopRecord;         /* 结束录制 */

- (void)forcusOnView:(UIView *)view withPoint:(CGPoint)point;   /* 对焦 */
- (void)saveToAlbum;        /* 将最近完成的录制存入相册 */

@end

