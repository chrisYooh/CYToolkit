//
//  CYVoiceCollector.h
//  CYToolkit
//
//  Created by Chris Yang on 2020/10/14.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CYVoiceCollector;

@protocol CYVoiceCollectorDelegate <NSObject>

- (void)collector:(CYVoiceCollector * _Nullable)tool getVoiceData:(NSData * _Nullable)voiceData;        /* 获取即时声音数据 */
- (void)collector:(CYVoiceCollector * _Nullable)tool getWavFile:(NSString * _Nullable)wavFilePath;      /* 录制结束，获取声音文件 */

@end

NS_ASSUME_NONNULL_BEGIN

@interface CYVoiceCollector : NSObject

@property (nonatomic, weak) id<CYVoiceCollectorDelegate> delegate;

/* 音频录制配置 */
@property (nonatomic, assign) NSUInteger channelNum;                /* 采样通道数 */
@property (nonatomic, assign) NSUInteger sampleRate;                /* 采样率 */

/* 操作配置 */
@property (nonatomic, assign) BOOL autoSetCategory;                 /* 是否自动设置Category, 默认YES */
@property (nonatomic, assign) BOOL autoSaveWavFile;                 /* 是否生成对应的Wav数据文件，默认YES */
@property (nonatomic, assign) float feedbackSecRate;                /* 数据反馈频率（单位：秒），比如0.01秒反馈一次，通过采样率自动计算 */

- (BOOL)start;      /* 开始收集声音 */
- (void)stop;       /* 停止收集声音 */

@end

NS_ASSUME_NONNULL_END
