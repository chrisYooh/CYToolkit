//
//  CYVideoPlayer.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYVideoPlayer.h"

@interface CYVideoPlayer ()

@property (nonatomic, assign, readwrite) BOOL isPlaying;                         /* 是否正在播放 */

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *previewLayer;

@end

@implementation CYVideoPlayer

- (id)init {
    self = [super init];
    if (self) {
        _previewLayer = [[AVPlayerLayer alloc] init];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    
    return self;
}

- (void)dealloc {
    [self removeNotifications];
    [self removePlayerObserver];
}

#pragma makr - Runtime play info

- (NSTimeInterval)curVideoDuration {
    return CMTimeGetSeconds(_playerItem.duration);
}

- (NSTimeInterval)curLoadingSec {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算缓冲总进度
    return result;
}

- (NSTimeInterval)curPlaySec {
    return CMTimeGetSeconds(_playerItem.currentTime);
}

#pragma mark -

- (void)loadVideoUrl:(NSURL *)videoUrl {
    [self __prepareWithDataUrl:videoUrl];
    [self removeNotifications];
    [self addNotifications];
}

- (void)loadVideoFile:(NSString *)videoFilePath {
    NSURL *fileUrl = [NSURL fileURLWithPath:videoFilePath];
    [self __prepareWithDataUrl:fileUrl];
    [self removeNotifications];
    [self addNotifications];
}

- (void)play {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [_player play];
    _isPlaying = YES;
}

- (void)pause {
    [_player pause];
    _isPlaying = NO;
}

- (void)stop {
    [_player pause];
    _isPlaying = NO;
    [_player seekToTime:CMTimeMake(0, 1)];
}

- (void)setPlayOffset:(NSTimeInterval)playOffset {
    
    [_player seekToTime:CMTimeMakeWithSeconds(playOffset, 30)
        toleranceBefore:CMTimeMake(1, 30)
         toleranceAfter:CMTimeMake(1, 30)
      completionHandler:^(BOOL finished) {
      }];
}

#pragma mark - Notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playDidFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playDidFinished:(NSNotification *)notification {
    [self stop];
    if ([_delegate respondsToSelector:@selector(playerDidFinishPlay:)]) {
        [_delegate playerDidFinishPlay:self];
    }
}

#pragma mark - Observer

- (void)addPlayerObserver {
    
    /* 检测视频是否准备好 */
    [_playerItem addObserver:self
                  forKeyPath:@"status"
                     options:0xf
                     context:nil];
    
    /* 读取加载进度 */
    [_playerItem addObserver:self
                  forKeyPath:@"loadedTimeRanges"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)removePlayerObserver {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *tmpItem = object;
//        NSLog(@"Status %ld", (long)tmpItem.status);
        if (AVPlayerItemStatusReadyToPlay == tmpItem.status) {
            if ([_delegate respondsToSelector:@selector(playerReadyToPlay:)]) {
                [_delegate playerReadyToPlay:self];
            }
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if ([_delegate respondsToSelector:@selector(player:loadingSecUpdated:)]) {
            [_delegate player:self loadingSecUpdated:[self curLoadingSec]];
        }
    }
}

#pragma makr - MISC

- (void)__prepareWithDataUrl:(NSURL *)dataUrl {

    _player = [AVPlayer playerWithURL:dataUrl];
    [_previewLayer setPlayer:_player];
    
    _playerItem = _player.currentItem;
    [self removePlayerObserver];
    [self addPlayerObserver];
}

@end
