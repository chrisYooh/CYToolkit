//
//  LYVideoRecorder.m
//  VideoRecorder&Player
//
//  Created by mac on 15/8/7.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "LYVideoRecorder.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface LYVideoRecorder()
<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic) BOOL onRecord;

@end

@implementation LYVideoRecorder

+ (LYVideoRecorder *)recorderWithSavedPath:(NSString *)savedPath
                             captureScreen:(UIView *)captureScreen
                              forcutCursor:(UIImageView *)forcusCursor
                                  callback:(videoRecordCallbackBlock)callbackBlock
                      fileCompleteCallback:(videoRecordFileCompleteWirteCallbackBlock)fileCompleteCallback
{
    LYVideoRecorder *videoRecord = [[LYVideoRecorder alloc] init];
    videoRecord.savedPath = savedPath;
    videoRecord.captureScreen = captureScreen;
    videoRecord.forcusCursor = forcusCursor;
    videoRecord.callbackBlock = callbackBlock;
    videoRecord.fileCompleteCallback = fileCompleteCallback;
  
    if (NO == [videoRecord initRecordInfo]) {
        return nil;
    }
    
    return videoRecord;
}

- (NSString *)recordConfigInfo
{
    return @"The function has not inplement";
}

- (NSString *)recordFileInfo
{
    /* TODO: 测试需求：打印出视频文件的大小，为后期确认音频文件的配置信息做准备 */
    NSDictionary *dicAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:_savedPath error:nil];
    float fileSize = [[dicAttr objectForKey:@"NSFileSize"] floatValue] / (1024 * 1024);
    NSString *infoStr = [NSString stringWithFormat:@"Record size = %.2f", fileSize];
    return infoStr;
}

- (void)changeCamera
{
    AVCaptureDevice *currentDevice = [_imageInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    
    /* Orginized target device and target position */
    AVCaptureDevice *targetDevice = nil;
    AVCaptureDevicePosition targetPosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified
        || currentPosition == AVCaptureDevicePositionFront) {
        
        targetPosition = AVCaptureDevicePositionBack;
    }
    targetDevice = [self getCameraDeviceWithPosition:targetPosition];
    
    AVCaptureDeviceInput *targetDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:targetDevice error:nil];
    
    /* Start configuration */
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_imageInput];
    
    if ([_captureSession canAddInput:targetDeviceInput]) {
        [_captureSession addInput:targetDeviceInput];
        _imageInput = targetDeviceInput;
    }
    
    [self.captureSession commitConfiguration];
}

- (void)startCapture
{
    [_captureSession startRunning];
}

- (void)stopCapture
{
    [_captureSession stopRunning];
}

- (BOOL)startRecord
{
    /* Set audio session */
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /* Start record */
    [_fileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:_savedPath]
                                recordingDelegate:self];
    
    /* set status */
    _onRecord = YES;
    
    /* Timer syn */
    [_callbackTimer invalidate];
    _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(timerCallback)
                                                    userInfo:nil
                                                     repeats:YES];
    return YES;
}

- (void)stopRecord
{
    [_fileOutput stopRecording];
    
    /* set status */
    _onRecord = NO;
    
    /* Timer syn */
    [_callbackTimer invalidate];
    _callbackTimer = nil;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)                captureOutput:(AVCaptureFileOutput *)captureOutput
   didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                      fromConnections:(NSArray *)connections
{
    NSLog(@"Record did start");
}

- (void)                    captureOutput:(AVCaptureFileOutput *)captureOutput
      didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                          fromConnections:(NSArray *)connections
                                    error:(NSError *)error
{
    NSLog(@"Record did stop");
    _fileCompleteCallback();
}

#pragma mark - 
- (void)timerCallback
{
    CMTime curDuration = _fileOutput.recordedDuration;
    float sec = CMTimeGetSeconds(curDuration);
    
    _callbackBlock(sec, 0);
}

- (BOOL)initRecordInfo
{
    /* Alloc object */
    _captureSession = [[AVCaptureSession alloc] init];
    _imageInput = nil;
    _voiceInput = nil;
    _fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    
    NSError *error = nil;
    /* Input setting */
    /* .1 Image */
    AVCaptureDevice *captureImageDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (nil == captureImageDevice) {
        NSLog(@"Get background camera failed");
    }
    _imageInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureImageDevice
                                                         error:&error];
    if (error) {
        NSLog(@"Get input(image) device failed with reason：%@",error.localizedDescription);
        return NO;
    }
    
    /* .2 Voice */
    AVCaptureDevice *captureVoiceDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    _voiceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureVoiceDevice
                                                         error:&error];
    if (error) {
        NSLog(@"Get input(voice) device failed with reason：%@",error.localizedDescription);
        return NO;
    }
    
    /* Output setting */
    
    /* Session setting */
    /* .1 RP */
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    /* .2 Add input */
    if (NO == [_captureSession canAddInput:_imageInput]
        || NO ==[_captureSession canAddInput:_voiceInput]) {
        
        NSLog(@"Can't add input to capture session");
        return NO;
    }
    [_captureSession addInput:_imageInput];
    [_captureSession addInput:_voiceInput];

    /* Config FileOutPut 
     * Or the video more than 10 second will have no sound */
    _fileOutput.movieFragmentInterval = kCMTimeInvalid;
    
    /* .3 Add output */
    AVCaptureConnection *captureConnection = [_fileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    if (NO == [_captureSession canAddOutput:_fileOutput]) {

        NSLog(@"Can't add output to capture session");
        return NO;
    }
    [_captureSession addOutput:_fileOutput];
    
    CALayer *baseLayer = _captureScreen.layer;
    baseLayer.masksToBounds = YES;
    /* View display */
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.frame = baseLayer.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [baseLayer insertSublayer:_previewLayer below:_forcusCursor.layer];
    
    /* Add norification to Image capture */
    [self addNotificationToCaptureDevice:captureImageDevice];
    [self addGenstureRecognizer];
    
    return YES;
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (position == camera.position) {
            return camera;
        }
    }
    
    return nil;
}

- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice
{
    /* TODO: 区域改变捕获通知 */
}

- (void)addGenstureRecognizer
{
    /* TODO: 主要完成聚焦按钮的变位操作 */
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [_captureScreen addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point= [tapGesture locationInView:_captureScreen];
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [_previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus
           exposureMode:AVCaptureExposureModeAutoExpose
                atPoint:cameraPoint];
}

- (void)setFocusCursorWithPoint:(CGPoint)point
{
    _forcusCursor.center = point;
    _forcusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    _forcusCursor.alpha = 1.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        _forcusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _forcusCursor.alpha = 0;
    }];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
        exposureMode:(AVCaptureExposureMode)exposureMode
             atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice= [_imageInput device];
    NSError *error = nil;
    
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if (YES == [captureDevice lockForConfiguration:&error]) {
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
    } else {
        
        NSLog(@"Set device property failed, error: %@",error.localizedDescription);
    }
}

- (NSTimeInterval)curRecordTime
{
    CMTime curDuration = _fileOutput.recordedDuration;
    float sec = CMTimeGetSeconds(curDuration);
    
    return sec;
}

@end
