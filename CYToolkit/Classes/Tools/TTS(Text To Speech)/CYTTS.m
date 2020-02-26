//
//  CYTTS.m
//  CYToolkit
//
//  Created by Chris on 2019/4/30.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CYTTS.h"

@interface CYTTS ()
<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *voice;

@end

@implementation CYTTS

+ (CYTTS *)sharedInstance {
    
    static CYTTS *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CYTTS alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
        _voice = [[AVSpeechSynthesizer alloc] init];
        _voice.delegate = self;
        
        _tone = 1;
        _volume = 1;
        _rate = 0.5;
    }
    
    return self;
}

- (void)speak:(NSString *)speechStr {
    
    AVSpeechSynthesisVoice *language = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    AVSpeechUtterance *speech = [[AVSpeechUtterance alloc] initWithString:speechStr];
    speech.pitchMultiplier = _tone;
    speech.volume = _volume;
    speech.rate = _rate;
    speech.voice = language;
    
    [_voice speakUtterance:speech];
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Start Speech");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Speech Finish");
    if ([_delegate respondsToSelector:@selector(ttsDidFinishedSpeak:)]) {
        [_delegate ttsDidFinishedSpeak:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Pause Speech");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Continue Speech");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Cancel Speech");
    if ([_delegate respondsToSelector:@selector(ttsDidFinishedSpeak:)]) {
        [_delegate ttsDidFinishedSpeak:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //    NSLog(@"Will Speak Range Of String");
}

@end
