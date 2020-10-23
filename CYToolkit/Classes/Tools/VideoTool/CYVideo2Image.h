//
//  CYVideo2Image.h
//  CYToolkit
//
//  Created by Chris Yang on 2020/10/20.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 解析视频需要时间，根据配置、机型的不同，每秒生成的帧数一般保持在 10 ~ 50 帧之间 */
NS_ASSUME_NONNULL_BEGIN

@class CYVideo2Image;

@protocol CYVideo2ImageDelegate <NSObject>

- (void)v2itool:(CYVideo2Image *)tool postError:(NSError *)error;
- (void)v2itool:(CYVideo2Image *)tool feedbackImage:(UIImage *)image frameIndex:(NSTimeInterval)frameIndex;
- (void)v2itoolDidFinishTrack:(CYVideo2Image *)tool;

@end

@interface CYVideo2Image : NSObject

@property (nonatomic, strong) id<CYVideo2ImageDelegate> delegate;

@property (nonatomic, strong) NSString *videoPath;          /* 视频路径 */

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
