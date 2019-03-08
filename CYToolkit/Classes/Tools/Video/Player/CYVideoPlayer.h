//
//  CYVideoPlayer.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CYVideoPlayer;

@protocol CYVideoPlayerDelegate <NSObject>

- (void)playerReadyToPlay:(CYVideoPlayer *)player;
- (void)playerDidFinishPlay:(CYVideoPlayer *)player;
- (void)player:(CYVideoPlayer *)player loadingSecUpdated:(NSTimeInterval)loadingSec;
- (void)player:(CYVideoPlayer *)player playSecUpdated:(NSTimeInterval)playSec;

@end

@interface CYVideoPlayer : NSObject

@property (nonatomic, weak) id<CYVideoPlayerDelegate> delegate;

/* Config */
@property (nonatomic, assign, readonly) NSTimeInterval curVideoDuration;        /* 视频时长 */
@property (nonatomic, assign, readonly) NSTimeInterval curLoadingSec;           /* 当前已加载时长 */
@property (nonatomic, assign, readonly) NSTimeInterval curPlaySec;              /* 当前播放时长 */
@property (nonatomic, assign, readonly) BOOL isPlaying;                         /* 是否正在播放 */

/* Layer */
@property (nonatomic, strong) AVPlayerLayer *previewLayer;                      /* 播放层 */

//- (void)loadVideoUrl:(NSURL *)videoUrl;                 /* 加载网络视频，暂未测试 */
- (void)loadVideoFile:(NSString *)videoFilePath;        /* 加载视频文件, 需要指明文件后缀 */

- (void)play;                                           /* 播放/继续 */
- (void)pause;                                          /* 暂停 */
- (void)stop;                                           /* 停止 */
- (void)setPlayOffset:(NSTimeInterval)playOffset;       /* 播放进度调整 */

@end

