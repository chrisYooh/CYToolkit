//
//  CYTTS.h
//  CYToolkit
//
// Text To Speech
// 基于Apple AVFoundation实现的轻量级读文本工具
//
//  Created by Chris on 2019/4/30.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYTTS : NSObject

@property (nonatomic, assign) float tone;       /* 音调，0.5 ~ 2.0, 默认 1 */
@property (nonatomic, assign) float volume;     /* 音量，0 ~ 1， 默认 1 */
@property (nonatomic, assign) float rate;       /* 语速，0 ~ 1， 默认 0.5 */

+ (CYTTS *)sharedInstance;
- (void)speak:(NSString *)speechStr;

@end

NS_ASSUME_NONNULL_END
