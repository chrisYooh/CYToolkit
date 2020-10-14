//
//  CYVoicePlayer.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class CYVoicePlayer;

@protocol CYVoicePlayerDelegate <NSObject>

- (void)playerDidFinishPlay:(CYVoicePlayer *)player;
- (void)player:(CYVoicePlayer *)player playSecUpdated:(NSTimeInterval)playSec;

@end

@interface CYVoicePlayer : NSObject

@property (nonatomic, weak) id<CYVoicePlayerDelegate> delegate;

/* Config */
@property (nonatomic, assign, readonly) NSTimeInterval curAudioDuration;        /* 音频时长 */
@property (nonatomic, assign, readonly) NSTimeInterval curPlaySec;              /* 当前播放时长 */
@property (nonatomic, assign, readonly) float curPower;                         /* 当前音量 */
@property (nonatomic, assign, readonly) BOOL isPlaying;                         /* 是否正在播放 */

//- (void)loadAudioUrl:(NSURL *)audioUrl;               /* 加载网络音频，暂未测试 */
- (void)loadAudioFile:(NSString *)audioFilePath;        /* 加载音频文件 */
- (void)loadAudioData:(NSData *)audioData;              /* 通过音频数据加载 */

- (void)play;                                           /* 播放/继续 */
- (void)pause;                                          /* 暂停 */
- (void)stop;                                           /* 停止 */
- (void)setPlayOffset:(NSTimeInterval)playOffset;       /* 播放进度调整 */

@end
