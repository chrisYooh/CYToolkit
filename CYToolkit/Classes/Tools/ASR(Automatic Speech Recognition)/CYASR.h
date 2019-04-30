//
//  CYASR.h
//  CYToolkit
//
//  Created by Chris on 2019/4/30.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * Sleeping -- [startSpeech()] --> WaitFirstWord
 * WaitFirstWord -- 超过[noAudioThre]秒未检测到语音 --> [asrExpectFirstWord]
 * WaitFirstWord -- 检测到语音 --> Speaking
 * WaitFirstWord -- [stopSpeech] --> Sleeping
 * Speaking -- 超过[audioFinishThre]秒未检测到语音 --> [ardAudioMayCutoff]
 * Speaking -- [stopSpeech] --> Sleeping
 */
typedef NS_ENUM(NSInteger, CYASRStatus) {
    CYASRStatusUnknown = -1,
    CYASRStatusSleeping,            /* 休眠中（stop） */
    CYASRStatusWaitFirstWord,       /* 等待语音输入 */
    CYASRStatusSpeaking,            /* 语音输入中 */
};

@class CYASR;

@protocol CYASRDelegate <NSObject>

- (void)asrExpectFirstWord:(CYASR *)asr;                            /* 等待语音输入, 每隔一段时间提示，通过 noAudioThre 配置提示间隔时间 */
- (void)asrCatchedFirstWord:(CYASR *)asr;                           /* 捕获到第一个单词 */
- (void)asr:(CYASR *)asr updateSpeech:(NSString *)speechStr;        /* 语音识别信息更新 */
- (void)asrAudioMayCutoff:(CYASR *)asr;                             /* 说话停顿超时，提示语音可能中断，通过 audioFinishThre 配置 */
- (void)asr:(CYASR *)asr getFinalSpeech:(NSString *)speechStr;      /* 获得最终结果，主动结束语音识别时获取 */

@end

API_AVAILABLE(ios(10.0))
@interface CYASR : NSObject

@property (nonatomic, weak) id<CYASRDelegate> delegate;

@property (nonatomic, assign) CYASRStatus status;       /* 当前状态 */
@property (nonatomic, assign) float noAudioThre;        /* 超过该阈值未检测到语音，进行提示， 默认8秒 */
@property (nonatomic, assign) float audioFinishThre;    /* 检测到语音后，超过该阈值未检测到语音，提示语音可能中断，默认0.75秒 */

+ (CYASR *)sharedInstance;

- (void)startSpeech;
- (void)stopSpeech;

@end

NS_ASSUME_NONNULL_END
