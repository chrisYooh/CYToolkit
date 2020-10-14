//
//  CYVoiceCollector.m
//  CYToolkit
//
//  Created by Chris Yang on 2020/10/14.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CYWavHeaderCreater.h"

#import "CYVoiceCollector.h"

// Frame（通过深度 + channelNum 计算） = bytePerSample * channelNum    /* 帧 */
// Package（只考虑PCM数据，不需要压缩，所以与Frame概念相同） = Frame        /* 包 */

#define __BUFFER_NUM            (3)
#define __TMP_FILE_NAME         @"CYAudioTool_TmpAudio.wav"

@interface CYVoiceCollector () {
    AudioStreamBasicDescription     _dataFormat;                    /* 数据流描述 */
    AudioQueueRef                   _mQueue;                        /* 队列 */
    AudioQueueBufferRef             _mBuffers[__BUFFER_NUM];        /* Buffers */
}

@property (nonatomic, assign) NSUInteger bytesPerChannel;       /* 每个Channel的字节数 */
@property (nonatomic, assign) NSUInteger bufferSize;            /* 每个buffer的大小（单位：字节） */

@property (nonatomic, strong) NSMutableData *curAudioData;      /* 当前的音频数据，只有autoSaveWavFile开启才有效 */

@end

static void __aqInputCallback(void * __nullable inUserData,         // 收集声音的对象
                              AudioQueueRef inAQ,                   // 声音队列
                              AudioQueueBufferRef inBuffer,         // 隐僻数据缓冲区
                              const AudioTimeStamp *inStartTime,    // 时间戳
                              UInt32 inNumberPacketDescriptions,    // 描述
                              const AudioStreamPacketDescription *__nullable inPacketDescs) {

    if (!inUserData) {
        NSLog(@"Error : inUserData is null.");
        return;
    }

    CYVoiceCollector *collector = (__bridge CYVoiceCollector *)inUserData;
        
    /* 音频数据转NSData */
    void *bufferData = inBuffer->mAudioData;
    UInt32 buffersize = inBuffer->mAudioDataByteSize;
    NSData *tmpData = [[NSData alloc] initWithBytes:bufferData length:buffersize];
    
    /* 累积音频数据 */
    if (YES == collector.autoSaveWavFile) {
        [collector.curAudioData appendData:tmpData];
    }
    
    /* 回调音频数据 */
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([collector.delegate respondsToSelector:@selector(collector:getVoiceData:)]) {
            [collector.delegate collector:collector getVoiceData:tmpData.copy];
        }
    });
    
    /* 将音频数据塞入声音队列 */
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

@implementation CYVoiceCollector

- (id)init {
    self = [super init];
    if (self) {
        
        /* 公开配置默认值 */
        _channelNum = 1;
        _sampleRate = 16000;
        _autoSetCategory = YES;
        _autoSaveWavFile = YES;
        _feedbackSecRate = 0.02;
        
        /* 私有配置 */
        _bytesPerChannel = 2;
        _bufferSize = 640; /* 16000 * 1 * 2 * 0.02 */
        
        _curAudioData = [[NSMutableData alloc] init];
    }
    
    return self;
}

#pragma mark - Getter & Setter

- (void)setChannelNum:(NSUInteger)channelNum {
    _channelNum = channelNum;
    [self __updataBufferSize];
}

- (void)setSampleRate:(NSUInteger)sampleRate {
    _sampleRate = sampleRate;
    [self __updataBufferSize];
}

- (void)setBytesPerChannel:(NSUInteger)bytesPerChannel {
    _bytesPerChannel = bytesPerChannel;
    [self __updataBufferSize];
}

- (void)setFeedbackSecRate:(float)feedbackSecRate {
    _feedbackSecRate = feedbackSecRate;
    [self __updataBufferSize];
}

#pragma mark - MISC

- (void)__updataBufferSize {
    _bufferSize = _sampleRate * _channelNum * _bytesPerChannel * _feedbackSecRate;
}

- (void)__createAudioSession {
    
    NSError *error = nil;
    BOOL ret = NO;

    if (YES == _autoSetCategory) {
        ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
        if (!ret) {
            NSLog(@"ERROR : Setting AVAudioSession category failed.");
            return;
        }
    }
    
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret) {
        NSLog(@"ERROR : Start audio session failed.");
        return;
    }
}

- (AudioStreamBasicDescription)__createAudioFormat {
    
    AudioStreamBasicDescription format;
    memset(&format, 0, sizeof(format));
    
    /* 采样频率 */
    UInt32 size = sizeof(format.mSampleRate);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
                            &size,
                            &format.mSampleRate);
#pragma clang diagnostic pop
    format.mSampleRate = _sampleRate;
    
    /* 通道数 */
    size = sizeof(format.mChannelsPerFrame);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels,
                            &size,
                            &format.mChannelsPerFrame);
#pragma clang diagnostic pop
    
    format.mFormatID = kAudioFormatLinearPCM;
    format.mChannelsPerFrame = (UInt32)_channelNum;
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format.mBitsPerChannel = (UInt32)_bytesPerChannel * 8;
    format.mBytesPerFrame = (UInt32)_bytesPerChannel * (UInt32)_channelNum;
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    
    return format;
}

- (void)__settingCallbackFunc {
    
    OSStatus status = 0;
    status = AudioQueueNewInput(&_dataFormat,
                                __aqInputCallback,
                                (__bridge void *)self,
                                NULL,
                                NULL,
                                0,
                                &_mQueue);
    if (status != noErr) {
        NSLog(@"Error : AudioQueueNewInput failed status:%d ", (int)status);
    }
    
    for (int i = 0 ; i < __BUFFER_NUM; i++) {
        status = AudioQueueAllocateBuffer(_mQueue,
                                          (UInt32)_bufferSize,
                                          &_mBuffers[i]);
        if (status != noErr) {
            NSLog(@"Error : AudioQueueAllocateBuffer failed status:%d ", (int)status);
        }

        status = AudioQueueEnqueueBuffer(_mQueue,
                                         _mBuffers[i],
                                         0,
                                         NULL);
        if (status != noErr) {
            NSLog(@"Error : AudioQueueEnqueueBuffer failed status:%d ", (int)status);
        }
    }
}

- (void)__setupProperty {
    /* 无需设置：一般场景的录音无须音量信息 */
}

- (NSString *)__randomFilePath {
    NSString *fileName = [NSString stringWithFormat:@"%d", rand() %0xffffffff];
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    return tmpPath;
}

#pragma mark - User Interface

- (BOOL)start {
    
    [self stop];
    
    if (_autoSaveWavFile) {
        _curAudioData = [[NSMutableData alloc] init];
    }
    
    /* Config */
    [self __createAudioSession];
    _dataFormat = [self __createAudioFormat];
    [self __settingCallbackFunc];
    [self __setupProperty];
    
    /* Start */
    OSStatus status = AudioQueueStart(_mQueue, NULL);
    if (status != noErr) {
        NSLog(@"Error : AudioQueueStart failed status:%d  ", (int)status);
        return NO;
    }
    
    return YES;
}

- (void)stop {
    
    if (NULL == _mQueue) {
        return;
    }
    
    OSStatus stopRes = AudioQueueStop(_mQueue, true);
    if (stopRes == noErr) {
        for (int i = 0; i < __BUFFER_NUM; i++) {
            AudioQueueFreeBuffer(_mQueue, _mBuffers[i]);
        }
    } else {
        NSLog(@"Errod : Stop AudioQueue failed.");
        return;
    }
    AudioQueueDispose(_mQueue, true);
    _mQueue = NULL;
    
    if (YES == _autoSaveWavFile && 0 != _curAudioData.length) {
        NSData *headerData = [CYWavHeaderCreater createWavHeaderWithData:_curAudioData.copy channel:_channelNum sampleRate:_sampleRate];
        NSMutableData *tarData = headerData.mutableCopy;
        [tarData appendData:_curAudioData];
        
        NSString *tmpPath = [self __randomFilePath];
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
        [tarData writeToFile:tmpPath atomically:YES];
        
        if ([_delegate respondsToSelector:@selector(collector:getWavFile:)]) {
            [_delegate collector:self getWavFile:tmpPath];
        }
    }
}

#pragma mark -

- (NSString *)description {
    NSString *tmpStr = [NSString stringWithFormat:
                        @"通道数: %d\n"
                        "采样率: %d\n"
                        "自动设置Category: %d\n"
                        "自动保存wav文件: %d\n"
                        "数据反馈频率: %.2f 秒\n"
                        "Buffer大小: %d 字节\n"
                        "Buffer数量: %d 个\n",
                        (int)_channelNum,
                        (int)_sampleRate,
                        (int)_autoSetCategory,
                        (int)_autoSaveWavFile,
                        _feedbackSecRate,
                        (int)_bufferSize,
                        __BUFFER_NUM
                        ];
    return tmpStr;
}

@end
