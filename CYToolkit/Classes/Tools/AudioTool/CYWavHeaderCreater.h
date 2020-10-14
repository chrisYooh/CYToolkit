//
//  CYWavHeaderCreater.h
//  GmesTest
//
//  Created by Chris Yang on 2020/10/13.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* 默认信息：
 * 1 每个 Sample 为 uint16
 * 2 不进行压缩
 * 参数：
 * 1 pcmData : pcm的音频数据
 * 2 channel : pcm录制时的通道数
 * 3 sampleRate : pcm录制时候的采样频率
 * */

@interface CYWavHeaderCreater : NSObject

+ (NSData *)createWavHeaderWithData:(NSData *)pcmData channel:(NSInteger)channel sampleRate:(NSInteger)sampleRate;

@end

NS_ASSUME_NONNULL_END
