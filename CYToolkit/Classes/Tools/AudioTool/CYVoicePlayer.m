//
//  CYVoicePlayer.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYVoicePlayer.h"

@interface CYVoicePlayer ()
<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign, readwrite) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *callbackTimer;

@end

@implementation CYVoicePlayer

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [_callbackTimer invalidate];
    _callbackTimer = nil;
    
    if ([_delegate respondsToSelector:@selector(playerDidFinishPlay:)]) {
        [_delegate playerDidFinishPlay:self];
    }
}

#pragma mark - Runtime info

- (NSTimeInterval)curAudioDuration {
    return _player.duration;
}

- (NSTimeInterval)curPlaySec {
    return _player.currentTime;
}

- (float)curPower {
    float power = [_player averagePowerForChannel:0];
    return power;
}

#pragma mark - MISC

- (void)__timerCallback {
    [_player updateMeters];
    
    if ([_delegate respondsToSelector:@selector(player:playSecUpdated:)]) {
        [_delegate player:self playSecUpdated:[self curPlaySec]];
    }
}

- (void)__prepareWithDataUrl:(NSURL *)dataUrl {
    
    NSError *error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:dataUrl error:&error];
    if (error) {
        NSLog(@"Init player failed， ERROR : %@", error);
        return ;
    }
    
    [_player setDelegate:self];
    [_player prepareToPlay];
    [_player setMeteringEnabled:YES];
}

#pragma mark - User Interface

- (void)loadAudioUrl:(NSURL *)audioUrl {
    [self __prepareWithDataUrl:audioUrl];
}

- (void)loadAudioFile:(NSString *)audioFilePath {
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFilePath];
    [self __prepareWithDataUrl:fileUrl];
}

- (void)loadAudioData:(NSData *)audioData {
    
    NSError *error = nil;
    _player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (error) {
        NSLog(@"Init player failed， ERROR : %@", error);
        return ;
    }
    
    [_player setDelegate:self];
    [_player prepareToPlay];
    [_player setMeteringEnabled:YES];
}

- (void)play {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    if (nil == _player) {
        return;
    }
    
    [_player play];
    _isPlaying = YES;
    
    [_callbackTimer invalidate];
    _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(__timerCallback)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)pause {
    [_player pause];
    _isPlaying = NO;
    
    [_callbackTimer invalidate];
    _callbackTimer = nil;
}

- (void)stop {
    [_player stop];
    _isPlaying = NO;
    [_player setCurrentTime:0];
    
    [_callbackTimer invalidate];
    _callbackTimer = nil;
}

- (void)setPlayOffset:(NSTimeInterval)playOffset {
    [_player setCurrentTime:playOffset];
}
@end
