//
//  CYASR.m
//  CYToolkit
//
//  Created by Chris on 2019/4/30.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import<Speech/Speech.h>

#import "CYASR.h"

@interface CYASR()

@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

/* */
@property (nonatomic, strong) NSDate *refDate;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CYASR

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

+ (CYASR *)sharedInstance {
    static CYASR *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CYASR alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _status = CYASRStatusSleeping;
        _noAudioThre = 8.0f;
        _audioFinishThre = 1.00f;
    }
    
    return self;
}

- (void)startSpeech {
    
    if (CYASRStatusSleeping != _status) {
        [self stopSpeech];
    }
    
    [self __prepare];
    [_audioEngine startAndReturnError:nil];
    _status = CYASRStatusWaitFirstWord;
    
    _refDate = [NSDate date];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(__timerCallback)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopSpeech {
    
    [_timer invalidate];
    _timer = nil;
    
    [[_audioEngine inputNode] removeTapOnBus:0];
    [_audioEngine stop];
    
    [_recognitionRequest endAudio];
    _recognitionRequest = nil;
    
    _status = CYASRStatusSleeping;
}

#pragma mark - Timer Callback

- (void)__timerCallback {
    
    if (CYASRStatusSleeping == _status) {
        /* 不应该出现 */
    }
    
    else if (CYASRStatusWaitFirstWord == _status) {
        NSDate *curDate = [NSDate date];
        if ([curDate timeIntervalSinceDate:_refDate] > _noAudioThre) {
            _refDate = curDate;
            if ([_delegate respondsToSelector:@selector(asrExpectFirstWord:)]) {
                [_delegate asrExpectFirstWord:self];
            }
        }
    }
    
    else if (CYASRStatusSpeaking == _status) {
        NSDate *curDate = [NSDate date];
        if ([curDate timeIntervalSinceDate:_refDate] > _audioFinishThre) {
            _refDate = curDate;
            if ([_delegate respondsToSelector:@selector(asrAudioMayCutoff:)]) {
                [_delegate asrAudioMayCutoff:self];
            }
        }
    }
}

#pragma mark -

- (void)__prepare {
    
    /* 授权 */
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if (SFSpeechRecognizerAuthorizationStatusAuthorized != status) {
            /* 授权失败 */
        } else {
            /* 授权成功 */
        }
    }];
    
    /* 模式 */
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /* 预备 */
    __weak CYASR *weakSelf = self;
    _recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    _recognitionRequest.shouldReportPartialResults = YES;
    
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    SFSpeechRecognizer *speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    [speechRecognizer
     recognitionTaskWithRequest:_recognitionRequest
     resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
         
         if (NO == result.isFinal) {
             
             /* 每次识别更新时间 */
             weakSelf.refDate = [NSDate date];
             
             /* 首次识别 */
             if (CYASRStatusWaitFirstWord == weakSelf.status) {
                 weakSelf.status = CYASRStatusSpeaking;
                 if ([weakSelf.delegate respondsToSelector:@selector(asrCatchedFirstWord:)]) {
                     [weakSelf.delegate asrCatchedFirstWord:self];
                 }
             }
             
             /* 过程结果 */
//             NSLog(@"CYASR过程结果：%@", result.bestTranscription.formattedString);
             if ([weakSelf.delegate respondsToSelector:@selector(asr:updateSpeech:)]) {
                 [weakSelf.delegate asr:self updateSpeech:result.bestTranscription.formattedString];
             }
             
         } else {
             /* 最终结果 */
//             NSLog(@"CYASR识别结果：%@", result.bestTranscription.formattedString);
             if ([weakSelf.delegate respondsToSelector:@selector(asr:getFinalSpeech:)]) {
                 [weakSelf.delegate asr:self getFinalSpeech:result.bestTranscription.formattedString];
             }
         }
     }];
    
    _audioEngine = [[AVAudioEngine alloc] init];
    [[_audioEngine inputNode]
     installTapOnBus:0
     bufferSize:1024
     format:[[self.audioEngine inputNode] outputFormatForBus:0]
     block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
         [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
     }];
    
    [_audioEngine prepare];
}

@end
