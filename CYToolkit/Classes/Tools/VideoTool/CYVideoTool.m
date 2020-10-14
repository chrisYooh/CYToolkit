//
//  CYVideoTool.m
//  CYToolkit
//
//  Created by Chris on 2019/3/5.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYCompatible.h"
#import "UIImage+CYCategory.h"

#import "CYVideoTool.h"

@interface CYVideoTool ()
<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) NSInteger frameCount;     /* 帧计数 */
@property (nonatomic, assign) NSInteger lastSec;        /* 上一秒 */

@property (nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *previewlayer;     /* 预览图层 */
@property (nonatomic, strong) AVCaptureSession *avSession;                              /* 流对象，依赖deviceInput, deviceOutput */
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;                        /* 设备输入 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;                     /* 数据输出，依赖videoQueue */
@property (nonatomic, strong) dispatch_queue_t videoQueue;

@end

@implementation CYVideoTool

- (id)init {
    self = [super init];
    if (self) {
        _confLogSecFrame = NO;
        _confTransToImage = YES;
        _confFlashOn = NO;
        _confFrontCamera = YES;
    }
    
    return self;
}

#pragma mark - Config

- (void)setConfFlashOn:(BOOL)confFlashOn {
    
    if (_confFlashOn == confFlashOn) {
        return;
    }
    
    AVCaptureDevice *tmpDevice = [self __backCamera];
    
    if (YES == confFlashOn) {
        
        if (NO == [tmpDevice hasTorch]) {
            return;
        }
        
        if (NO == [tmpDevice lockForConfiguration:nil]) {
            return;
        }
        
        [tmpDevice setTorchMode:AVCaptureTorchModeOn];
        [tmpDevice unlockForConfiguration];
        
    } else {
        
        if (NO == [tmpDevice lockForConfiguration:nil]) {
            return;
        }
        
        [tmpDevice setTorchMode:AVCaptureTorchModeOff];
        [tmpDevice unlockForConfiguration];
    }
    
    _confFlashOn = confFlashOn;
}

- (void)setConfFrontCamera:(BOOL)confFrontCamera {
    
    if (_confFrontCamera == confFrontCamera) {
        return;
    }
    
    [self.avSession stopRunning];
    
    /* 选择新摄像头 */
    AVCaptureDevice *tmpDevice = (YES == confFrontCamera) ? [self __frontCamera] : [self __backCamera];
    
    /* 构造新设备输入 */
    AVCaptureDeviceInput *newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:tmpDevice error:nil];
    
    /* 替换设备输入 */
    [self.avSession beginConfiguration];
    [self.avSession removeInput:self.deviceInput];
    [self.avSession addInput:newDeviceInput];
    [self.avSession commitConfiguration];
    self.deviceInput = newDeviceInput;
    
    [self.avSession startRunning];
    [self.previewlayer addAnimation:[self __cameraChangeAnimation] forKey:nil];
    
    _confFrontCamera = confFrontCamera;
}

#pragma mark - AV Related

- (void)startSession {
    [self.avSession startRunning];
}

- (void)stopSession {
    [self.avSession stopRunning];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    if (connection != [self.dataOutput connectionWithMediaType:AVMediaTypeVideo]) {
        return;
    }
    
    /* 获得帧 */
    
    cyWeakSelf(weakSelf);
    @synchronized(self) {
        
        /* 1 原始视频帧数据回调 */
        if ([weakSelf.delegate respondsToSelector:@selector(videoTool:getSampleBuffer:)]) {
            [weakSelf.delegate videoTool:weakSelf getSampleBuffer:sampleBuffer];
        }
        
        /* 2 UIImage 数据回调 */
        if (YES == weakSelf.confTransToImage) {
            UIImage *tmpImage = [UIImage cyImageWithSampleBuffer:sampleBuffer fromFrontCamera:weakSelf.confFrontCamera];
            if ([weakSelf.delegate respondsToSelector:@selector(videoTool:captureOutputImage:)]) {
                [weakSelf.delegate videoTool:weakSelf captureOutputImage:tmpImage];
            }
        }

        /* 3 每秒处理的帧数 */
        if (YES == weakSelf.confLogSecFrame) {
            weakSelf.frameCount++;
            NSInteger curSec = (NSInteger)[[NSDate date] timeIntervalSince1970];
            if (curSec > weakSelf.lastSec) {
                NSLog(@"Time[%ld] 帧数%ld", (long)curSec, (long)weakSelf.frameCount);
                weakSelf.lastSec = curSec;
                weakSelf.frameCount = 0;
            }
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    /* 丢弃帧处理 */
}

#pragma mark - Lazy Getter

- (AVCaptureVideoPreviewLayer *)previewlayer {
    if (nil == _previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.avSession];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewlayer;
}

- (AVCaptureSession *)avSession {
    if (nil == _avSession) {
        _avSession = [[AVCaptureSession alloc] init];
        
        /* 分辨率设置 */
        if ([_avSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _avSession.sessionPreset = AVCaptureSessionPresetHigh;
        }
        
        /* 添加输入 */
        if ([_avSession canAddInput:self.deviceInput]) {
            [_avSession addInput:self.deviceInput];
        }
        
        /* 添加输出 */
        if ([_avSession canAddOutput:self.dataOutput]) {
            [_avSession addOutput:self.dataOutput];
        }
    }
    
    return _avSession;
}

- (AVCaptureDeviceInput *)deviceInput {
    if (nil == _deviceInput) {
        
        AVCaptureDevice *tmpDevice = (YES == _confFrontCamera) ? [self __frontCamera] : [self __backCamera];
        
        /* 设置捕捉频率 */
        float frameRate = 2;
        for(AVCaptureDeviceFormat *vFormat in [tmpDevice formats] ) {
            CMFormatDescriptionRef description = vFormat.formatDescription;
            float maxRate = ((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
            if (maxRate > frameRate - 1
                && CMFormatDescriptionGetMediaSubType(description) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
                
                if ([tmpDevice lockForConfiguration:nil]) {
                    tmpDevice.activeFormat = vFormat;
                    [tmpDevice setActiveVideoMinFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [tmpDevice setActiveVideoMaxFrameDuration:CMTimeMake(10, frameRate * 10)];
                    [tmpDevice unlockForConfiguration];
                    break;
                }
            }
        }
        
        /* 设置曝光平衡 */
        if ([tmpDevice lockForConfiguration:nil]) {
            
            /* 闪光灯关闭 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([tmpDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
                [tmpDevice setFlashMode:AVCaptureFlashModeOff];
            }
#pragma clang diagnostic pop
            
            /* 自动白平衡 */
            if ([tmpDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [tmpDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            [tmpDevice unlockForConfiguration];
        }
        
        /* 自动聚焦 & 自动曝光 */
        if ([tmpDevice lockForConfiguration:nil]) {
            
            CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
            
            /* 自动聚焦 */
            AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
            BOOL canResetFocus =
            [tmpDevice isFocusPointOfInterestSupported]
            && [tmpDevice isFocusModeSupported:focusMode];
            
            if (canResetFocus) {
                tmpDevice.focusMode = focusMode;
                tmpDevice.focusPointOfInterest = centerPoint;
            }
            
            /* 曝光 */
            AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            BOOL canResetExposure =
            [tmpDevice isExposurePointOfInterestSupported]
            && [tmpDevice isExposureModeSupported:exposureMode];
            
            if (canResetExposure) {
                tmpDevice.exposureMode = exposureMode;
                tmpDevice.exposurePointOfInterest = centerPoint;
            }
            
            [tmpDevice unlockForConfiguration];
        }
        
        /* 输入设备 */
        NSError *error = nil;
        _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:tmpDevice error:&error];
    }
    
    return _deviceInput;
}

- (AVCaptureVideoDataOutput *)dataOutput {
    if (nil == _dataOutput) {
        _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _dataOutput.alwaysDiscardsLateVideoFrames = YES;
        [_dataOutput setSampleBufferDelegate:self queue:self.videoQueue];
        
        NSDictionary *videoSettingDic = @{ (id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA) };
        [_dataOutput setVideoSettings:videoSettingDic];
    }
    
    return _dataOutput;
}

- (dispatch_queue_t)videoQueue {
    if (nil == _videoQueue) {
        _videoQueue = dispatch_queue_create("com.cmcamera.videoqueue", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}

#pragma mark - AV Camera Position

- (AVCaptureDevice *)__frontCamera {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == AVCaptureDevicePositionFront) {
            return camera;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)__backCamera {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == AVCaptureDevicePositionBack) {
            return camera;
        }
    }
    return nil;
}

#pragma mark - MISC

- (CAAnimation *)__cameraChangeAnimation {
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.25;
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromLeft;
    return animation;
}

@end
