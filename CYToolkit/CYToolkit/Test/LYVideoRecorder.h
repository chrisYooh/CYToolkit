//
//  LYVideoRecorder.h
//  VideoRecorder&Player
//
//  Created by mac on 15/8/7.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^videoRecordCallbackBlock)(float recordTime, float curPower);
typedef void (^videoRecordFileCompleteWirteCallbackBlock)(void);

@interface LYVideoRecorder : NSObject

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureDeviceInput *imageInput;
@property (nonatomic, retain) AVCaptureDeviceInput *voiceInput;
@property (nonatomic, retain) AVCaptureMovieFileOutput *fileOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) videoRecordCallbackBlock callbackBlock;
@property (nonatomic, copy) videoRecordFileCompleteWirteCallbackBlock fileCompleteCallback;
@property (nonatomic, retain) NSTimer *callbackTimer;

@property (nonatomic, retain) NSString *savedPath;
@property (nonatomic, retain) UIView *captureScreen;
@property (nonatomic, retain) UIImageView *forcusCursor;

+ (LYVideoRecorder *)recorderWithSavedPath:(NSString *)savedPath
                             captureScreen:(UIView *)captureScreen
                              forcutCursor:(UIImageView *)forcusCursor
                                  callback:(videoRecordCallbackBlock)callbackBlock
                      fileCompleteCallback:(videoRecordFileCompleteWirteCallbackBlock)fileCompleteCallback;

- (NSString *)recordConfigInfo;
- (NSString *)recordFileInfo;

- (void)changeCamera;

- (void)startCapture;
- (void)stopCapture;

- (BOOL)startRecord;
- (void)stopRecord;

- (NSTimeInterval)curRecordTime;

@end
