//
//  CYVoiceRecorder.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYVoiceRecorder;

@protocol CYVoiceRecorderDelegate <NSObject>

- (void)recorderDidStartRecord:(CYVoiceRecorder *)recorder;
- (void)recorder:(CYVoiceRecorder *)recorder didFinishRecordToFile:(NSString *)filePath;

@end

@interface CYVoiceRecorder : NSObject

@property (nonatomic, weak) id<CYVoiceRecorderDelegate> delegate;

@property (nonatomic, strong) NSDictionary *settingDic;                 /* 录音配置 */
@property (nonatomic, assign, readonly) NSTimeInterval curRecordTime;   /* 当前录音时间 */

- (BOOL)startRecord;    /* 开始录音 */
- (void)stopRecord;     /* 结束录音 */

@end

NS_ASSUME_NONNULL_END
