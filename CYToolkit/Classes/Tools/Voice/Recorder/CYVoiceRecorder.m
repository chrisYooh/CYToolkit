//
//  CYVoiceRecorder.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "NSString+CYCategory.h"

#import "CYVoiceRecorder.h"

#define __RecordFileName            @"cyToolkitVoiceRecordTmpFile"

@interface CYVoiceRecorder ()

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation CYVoiceRecorder

- (id)init {
    self = [super init];
    if (self) {
        
        _settingDic =
        @{
          AVFormatIDKey: @(kAudioFormatLinearPCM),      // 设置录音格式
          AVSampleRateKey: @(11025.0),                  // 设置录音采样率，8000是电话采样率，对于一般录音已经够了
          AVNumberOfChannelsKey: @(2),                  // 设置通道
          AVLinearPCMBitDepthKey: @(16),                // 每个采样点位数,分为8、16、24、32
//          AVLinearPCMIsFloatKey: @(YES),                 // 是否使用浮点数采样(否，和压缩匹配)
          };
    }
    
    return self;
}

#pragma mark - Runtime Info

- (NSTimeInterval)curRecordTime {
    [_recorder updateMeters];
    return _recorder.currentTime;
}

#pragma mark - MISC

- (NSString *)__recordPath {
    NSString *tmpPath = [NSString cyTemporaryPath];
    tmpPath = [tmpPath stringByAppendingPathComponent:__RecordFileName];
    return tmpPath;
}

#pragma mark - User Interface

- (BOOL)startRecord {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /* Recorder on check */
    if (nil != _recorder) {
        NSLog(@"Last record still on");
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[self __recordPath] error:nil];
    
    /* Config recorder */
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[self __recordPath]]
                                            settings:_settingDic
                                               error:&error];
    if (nil != error) {
        NSLog(@"Create AVAudioRecorder object failed");
        return NO;
    }
    
    _recorder.meteringEnabled = YES;
    if (NO == [_recorder prepareToRecord]) {
        NSLog(@"Record prepare failed");
        _recorder = nil;
        return NO;
    };
    
    [_recorder record];
    if ([_delegate respondsToSelector:@selector(recorderDidStartRecord:)]) {
        [_delegate recorderDidStartRecord:self];
    }
    
    return YES;
}

- (void)stopRecord {
    [_recorder stop];
    _recorder = nil;
    
    if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordToFile:)]) {
        [_delegate recorder:self didFinishRecordToFile:[self __recordPath]];
    }
}

@end
