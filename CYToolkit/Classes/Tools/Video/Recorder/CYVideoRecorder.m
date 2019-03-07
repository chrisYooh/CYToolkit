//
//  CYVideoRecorder.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYCompatible.h"
#import "UIImage+CYCategory.h"
#import "NSString+CYCategory.h"

#import "CYVideoRecorder.h"

#define __RecordFileName            @"cyToolkitVideoRecordTmpFile"

@interface CYVideoRecorder ()
<AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign, readwrite) BOOL isRecording;      /* 是否正在录制 */
@property (nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *previewlayer;      /* 预览图层 */

@property (nonatomic, strong) AVCaptureSession *avSession;                              /* 流对象，依赖cameraInput, deviceOutput */
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;                        /* 摄像头视频 设备输入 */
@property (nonatomic, retain) AVCaptureDeviceInput *voiceInput;                         /* 声音 设备输入 */
@property (nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;                     /* 数据输出，依赖videoQueue */
@property (nonatomic, retain) AVCaptureMovieFileOutput *fileOutput;                     /* 文件输出，视频录制时候需要 */
@property (nonatomic, strong) dispatch_queue_t videoQueue;                              /* 视频帧数据输出队列 */

@end

@implementation CYVideoRecorder

- (id)init {
    self = [super init];
    if (self) {
        _confFlashOn = NO;
        _confFrontCamera = YES;
        _confPreset = AVCaptureSessionPresetHigh;
    }
    
    return self;
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
        
        if ([weakSelf.delegate respondsToSelector:@selector(recorder:getSampleBuffer:)]) {
            [weakSelf.delegate recorder:weakSelf getSampleBuffer:sampleBuffer];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    /* 丢弃帧处理 */
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)                captureOutput:(AVCaptureFileOutput *)output
   didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                      fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    /* 录制开始 */
    if ([_delegate respondsToSelector:@selector(recorderDidStartRecord:)]) {
        [_delegate recorderDidStartRecord:self];
    }
}

- (void)                captureOutput:(AVCaptureFileOutput *)output
  didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                      fromConnections:(NSArray<AVCaptureConnection *> *)connections
                                error:(nullable NSError *)error {
    /* 录制结束 */
    if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordToFile:)]) {
        [_delegate recorder:self didFinishRecordToFile:[self __recordPath]];
    }
}

#pragma mark - AV Lazy Getter

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
        
        /* 添加输入（图像、音频） */
        if ([_avSession canAddInput:self.cameraInput]) {
            [_avSession addInput:self.cameraInput];
        }
        if ([_avSession canAddInput:self.voiceInput]) {
            [_avSession addInput:self.voiceInput];
        }
        
        /* 添加输出（视频队列，文件输出） */
        if ([_avSession canAddOutput:self.dataOutput]) {
            [_avSession addOutput:self.dataOutput];
        }
        
        if ([_avSession canAddOutput:self.fileOutput]) {
            [_avSession addOutput:self.fileOutput];
        }
    }
    
    return _avSession;
}

- (AVCaptureDeviceInput *)cameraInput {
    
    if (nil != _cameraInput) {
        return _cameraInput;
    }
    
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
        if ([tmpDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
            [tmpDevice setFlashMode:AVCaptureFlashModeOff];
        }
        
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
    _cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:tmpDevice error:&error];
    
    return _cameraInput;
}

- (AVCaptureDeviceInput *)voiceInput {
    
    if (nil != _voiceInput) {
        return _voiceInput;
    }
    
    NSError *error = nil;
    AVCaptureDevice *captureVoiceDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    _voiceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureVoiceDevice
                                                         error:&error];
    if (error) {
        NSLog(@"Get input(voice) device failed with reason：%@",error.localizedDescription);
        return nil;
    }
    
    return _voiceInput;
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

- (AVCaptureMovieFileOutput *)fileOutput {
    
    if (nil != _fileOutput) {
        return _fileOutput;
    }
    
    _fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _fileOutput.movieFragmentInterval = kCMTimeInvalid;
    AVCaptureConnection *tmpConn = [_fileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([tmpConn isVideoStabilizationSupported]) {
        tmpConn.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    return _fileOutput;
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
    {
        [self.avSession removeInput:self.cameraInput];
        if ([self.avSession canAddInput:newDeviceInput]) {
            [self.avSession addInput:newDeviceInput];
            self.cameraInput = newDeviceInput;
        }
    }
    [self.avSession commitConfiguration];
    
    /* 重启视频流 */
    [self.avSession startRunning];
    [self.previewlayer addAnimation:[self __cameraChangeAnimation] forKey:nil];
    
    /* 更新配置 */
    _confFrontCamera = confFrontCamera;
}

#pragma mark - Status

- (float)curRecordSec {
    CMTime curDuration = _fileOutput.recordedDuration;
    float sec = CMTimeGetSeconds(curDuration);
    return sec;
}

#pragma mark - MISC

- (AVCaptureDevice *)__frontCamera {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == AVCaptureDevicePositionFront) {
            return camera;
        }
    }
    return nil;
}

- (AVCaptureDevice *)__backCamera {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == AVCaptureDevicePositionBack) {
            return camera;
        }
    }
    return nil;
}

- (CAAnimation *)__cameraChangeAnimation {
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.25;
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromLeft;
    return animation;
}

- (NSString *)__recordPath {
    NSString *tmpPath = [NSString cyTemporaryPath];
    tmpPath = [tmpPath stringByAppendingPathComponent:__RecordFileName];
    return tmpPath;
}

#pragma mark - User Interface

- (void)startSession {
    [self.avSession startRunning];
}

- (void)stopSession {
    [self.avSession stopRunning];
}

- (void)startRecord {
    /* Set audio session */
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /* Start record */
    [[NSFileManager defaultManager] removeItemAtPath:[self __recordPath] error:nil];
    [_fileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self __recordPath]] recordingDelegate:self];
    
    /* set status */
    _isRecording = YES;
}

- (void)stopRecord {
    [_fileOutput stopRecording];
    
    /* set status */
    _isRecording = NO;
}

- (void)forcusOnView:(UIView *)view withPoint:(CGPoint)point {
    
    AVCaptureDevice *captureDevice= [self.cameraInput device];
    NSError *error = nil;
    if (NO == [captureDevice lockForConfiguration:&error]) {
        NSLog(@"Set device property failed, error: %@",error.localizedDescription);
        return;
    }
    
    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([captureDevice isFocusPointOfInterestSupported]) {
        [captureDevice setFocusPointOfInterest:point];
    }
    if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    if ([captureDevice isExposurePointOfInterestSupported]) {
        [captureDevice setExposurePointOfInterest:point];
    }
    [captureDevice unlockForConfiguration];
    
}

- (void)saveToAlbum {
    [[self __recordPath] cySaveToAlbum];
}

@end
