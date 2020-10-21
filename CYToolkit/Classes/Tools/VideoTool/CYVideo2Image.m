//
//  CYVideo2Image.m
//  CYToolkit
//
//  Created by Chris Yang on 2020/10/20.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CYVideo2Image.h"

@interface CYVideo2Image()

@property (nonatomic, strong) AVAssetImageGenerator *generator;

@end

@implementation CYVideo2Image

- (id)init {
    self = [super init];
    if (self) {
        _framePerSecond = 25;
    }
    
    return self;
}

#pragma mark - MISC

- (void)__postErrorStr:(NSString *)errStr {
    NSError *tmpErr = [NSError errorWithDomain:errStr code:-1 userInfo:nil];
    if ([_delegate respondsToSelector:@selector(v2itool:postError:)]) {
        [_delegate v2itool:self postError:tmpErr];
    }
}

- (NSArray *)__timeArrayWithDuration:(CMTime)duration fps:(NSInteger)fps {
    
    NSUInteger totalFrameCount = CMTimeGetSeconds(duration) * fps;
    NSMutableArray *tmpMulArray = [NSMutableArray arrayWithCapacity:totalFrameCount];
    for (NSUInteger i = 0; i < totalFrameCount; i++) {
        CMTime timeFrame = CMTimeMake(i, (int32_t)fps);
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [tmpMulArray addObject:timeValue];
    }
    
    return tmpMulArray.copy;;
}

#pragma mark -

- (void)start {
    
    [self stop];
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
        NSString *errStr = [NSString stringWithFormat:@"视频文件不存在(%@)", _videoPath];
        [self __postErrorStr:errStr];
        return;
    }
    
    /* 创建Url Asset */
    NSURL *pathUrl = [NSURL fileURLWithPath:_videoPath];
    AVURLAsset *tmpAsset = [AVURLAsset assetWithURL:pathUrl];
    
    /* 创建Generator */
    _generator = [[AVAssetImageGenerator alloc] initWithAsset:tmpAsset];
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;

    /* 开始数据收集 */
    NSArray *timeArray = [self __timeArrayWithDuration:tmpAsset.duration fps:_framePerSecond];
    __weak typeof(self) weakSelf = self;
    [_generator
     generateCGImagesAsynchronouslyForTimes:timeArray
     completionHandler:^(CMTime requestedTime,
                         CGImageRef  _Nullable image,
                         CMTime actualTime,
                         AVAssetImageGeneratorResult result,
                         NSError * _Nullable error) {
        UIImage *tmpImage = [UIImage imageWithCGImage:image];
        
        if ([weakSelf.delegate respondsToSelector:@selector(v2itool:feedbackImage:frameTime:)]) {
            [weakSelf.delegate v2itool:self feedbackImage:tmpImage frameTime:CMTimeGetSeconds(actualTime)];
        }
    }];
}

- (void)stop {
    [_generator cancelAllCGImageGeneration];
    _generator = nil;
}

@end
