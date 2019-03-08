//
//  CYVideoCompressor.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYCompatible.h"
#import "NSString+CYCategory.h"

#import "CYVideoCompressor.h"

#define __CompressFileName            @"cyToolkitVideoCompressTmpFile.mp4"


@interface CYVideoCompressor ()

@property (nonatomic, strong) SDAVAssetExportSession *exportSession;
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation CYVideoCompressor

- (id)init {
    self = [super init];
    if (self) {
        _confOutputSize = CGSizeZero;
    }
    
    return self;
}

#pragma mark - Compress Config

- (void)__prepareWithSrcFile:(NSString *)srcFilePath dstFile:(NSString *)dstFilePath {
    
    /* 清除目标文件 */
    [[NSFileManager defaultManager] removeItemAtPath:[self __compressFilePath] error:nil];
    
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:srcFilePath]];
    CMTime assetDuration = [avAsset duration];
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetDuration)
                         ofAsset:avAsset
                          atTime:kCMTimeZero
                           error:nil];
    
    /* Organize a AVMutableVideoComposition */
    AVMutableVideoComposition *avMutableVideoComposition = [self __videoCompositionWithAVAssset:avAsset];
    
    CGRect renderRect = [self __clipRectFromVideoSize:avAsset];
    NSString *randerWidth = [NSString stringWithFormat:@"%f",renderRect.size.width];
    NSString *randerHeight = [NSString stringWithFormat:@"%f",renderRect.size.height];
    
    _exportSession = [SDAVAssetExportSession.alloc initWithAsset:composition];
    _exportSession.videoComposition = avMutableVideoComposition;
    _exportSession.outputFileType = AVFileTypeMPEG4;
    _exportSession.shouldOptimizeForNetworkUse = YES;
    _exportSession.outputURL = [NSURL fileURLWithPath:[self __compressFilePath]];;
    _exportSession.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: randerWidth,
    AVVideoHeightKey: randerHeight,
    AVVideoCompressionPropertiesKey: @
        {
            /* max->Height  min->Low */
        AVVideoAverageBitRateKey: @350000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    _exportSession.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [_exportSession setTimeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
}

- (AVMutableVideoComposition *)__videoCompositionWithAVAssset:(AVAsset *)asset {
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGRect renderRect = [self __clipRectFromVideoSize:asset];
    
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
    
    /* Set clip range */
    avMutableVideoComposition.renderSize =  renderRect.size;
    
    /* Set frameDuration */
    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    /* Set Instructions */
    avMutableVideoComposition.instructions =
    [NSArray arrayWithObject:[self __clipInstructionWithTrack:videoTrack
                                                     duration:asset.duration
                                                  transOffset:renderRect.origin]];
    
    /* Set Animation Tool (水印) */
    avMutableVideoComposition.animationTool = nil;
    
    return avMutableVideoComposition;
}

/* Caculate the right rect of screen */
- (CGRect)__clipRectFromVideoSize:(AVAsset *)asset {
    
    /* 不剪裁 */
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize pixelSize = videoTrack.naturalSize;
    CGRect retRect = CGRectZero;
    
    retRect.size.width = pixelSize.height;
    retRect.size.height = pixelSize.width;
    return retRect;
}

- (AVMutableVideoCompositionInstruction *)__clipInstructionWithTrack:(AVAssetTrack *)videoTrack
                                                            duration:(CMTime)duration
                                                         transOffset:(CGPoint)transOffset {
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    /* Set transform */
    CGAffineTransform transform = videoTrack.preferredTransform;
    transform = CGAffineTransformTranslate(transform, -1 * transOffset.y, transOffset.x);
    [videoLayerInstruction setTransform:transform atTime:kCMTimeZero];
    
    /* Add layerInstruction to Instruction */
    AVMutableVideoCompositionInstruction *videoInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [videoInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, duration)];
    videoInstruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    
    return videoInstruction;
}

#pragma mark - MISC

- (NSString *)__compressFilePath {
    NSString *tmpPath = [NSString cyTemporaryPath];
    tmpPath = [tmpPath stringByAppendingPathComponent:__CompressFileName];
    return tmpPath;
}

- (void)__compressProgressHandle {
    if ([_delegate respondsToSelector:@selector(compressor:reportProgress:)]) {
        [_delegate compressor:self reportProgress:_exportSession.progress];
    }
}

- (void)__compressCompletedHandle {
    
    if (AVAssetExportSessionStatusCompleted != _exportSession.status) {
        if ([_delegate respondsToSelector:@selector(compressorFailed:)]) {
            [_delegate compressorFailed:self];
        }
        return;
    }
    
    [_progressTimer invalidate];
    _progressTimer = nil;
    
    if ([_delegate respondsToSelector:@selector(compressor:didFinishCompressToFile:)]) {
        [_delegate compressor:self didFinishCompressToFile:[self __compressFilePath]];
    }
}

#pragma mark - User Interface

- (void)loadFile:(NSString *)srcFilePath {
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:srcFilePath]) {
        NSLog(@"未找到待压缩文件.\n");
        return;
    }
    
    [self __prepareWithSrcFile:srcFilePath dstFile:[self __compressFilePath]];
}

- (void)startCompress {
    
    cyWeakSelf(weakSelf);
    [_exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        [weakSelf __compressCompletedHandle];
    }];
    
    /* Timer syn */
    [_progressTimer invalidate];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(__compressProgressHandle)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopCompress {
    [_exportSession cancelExport];
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)saveToAlbum {
    [[self __compressFilePath] cyVideoSaveToAlbum];
}

@end
