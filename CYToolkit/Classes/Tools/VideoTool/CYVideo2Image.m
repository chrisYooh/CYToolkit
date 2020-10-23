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

@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *trackOutput;
@property (nonatomic, assign) NSInteger frameIndex;

@end

@implementation CYVideo2Image

- (id)init {
    self = [super init];
    if (self) {
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

#pragma mark - MISC

- (void)__fillReaderAndOutput:(NSString *)videoPath {
    
    /* 创建 Url Asset */
    NSURL *pathUrl = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *tmpAsset = [AVURLAsset assetWithURL:pathUrl];
    
    /* 创建 Reader */
    AVAssetReader *tmpReader = [[AVAssetReader alloc] initWithAsset:tmpAsset error:nil];
    
    /* Add output to Reader */
    AVAssetTrack *vtrack = [[tmpAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    NSDictionary *dictionary = @{
        (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)
    };
    AVAssetReaderTrackOutput *tmpOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:vtrack outputSettings:dictionary];
    if ([tmpReader canAddOutput:tmpOutput]) {
        [tmpReader addOutput:tmpOutput];
    }
    
    _reader = tmpReader;
    _trackOutput = tmpOutput;
}

- (UIImage *)__ImageFromBufferRef:(CMSampleBufferRef)buffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
    
    /* Image Buffer --> UIImage*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    int bitsPerComponent = 8;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width, height,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    UIImage *tmpImage = [UIImage imageWithCGImage:newImage];
    
    /* 释放内存 */
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    CFRelease(newImage);
    CFRelease(buffer);
    
    return tmpImage;
}

#pragma mark -

- (void)start {
    
    [self stop];
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
        NSString *errStr = [NSString stringWithFormat:@"视频文件不存在(%@)", _videoPath];
        [self __postErrorStr:errStr];
        return;
    }
    
    /* 填充新的 Reader output */
    [self __fillReaderAndOutput:_videoPath];

    
    /* 开始数据收集 */
    if (NO == [_reader startReading]) {
        /* 开启读取失败 */
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        while (AVAssetReaderStatusReading == [weakSelf.reader status]) {

            weakSelf.frameIndex++;
            CMSampleBufferRef buffer = [weakSelf.trackOutput copyNextSampleBuffer];
            if (!buffer) {
                continue;
            }
            UIImage *tarImage = [weakSelf __ImageFromBufferRef:buffer];
            
            if ([weakSelf.delegate respondsToSelector:@selector(v2itool:feedbackImage:frameIndex:)]) {
                [weakSelf.delegate v2itool:weakSelf feedbackImage:tarImage frameIndex:weakSelf.frameIndex];
            }
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(v2itoolDidFinishTrack:)]) {
            [weakSelf.delegate v2itoolDidFinishTrack:weakSelf];
        }
    });
    
}

- (void)stop {
    [_reader cancelReading];
    _reader = nil;
    _trackOutput = nil;
    _frameIndex = -1;
}

@end
