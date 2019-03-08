//
//  LYVideoCompresser.m
//  VideoRecorder&Player
//
//  Created by mac on 15/8/7.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SDAVAssetExportSession.h"

#import "LYVideoCompresser.h"

@implementation LYVideoCompresser

#pragma mark - User interface
+ (LYVideoCompresser *)compresserWithSourcePath:(NSString *)sourcePath
                                   compressPath:(NSString *)compressPath
                               progressCallback:(videoCompressProgressCallbackBlock)progressCallback
                                 finishCallback:(videoCompressCompleteCallbackBlock)finishCallback
{
    /* Source file and destination file check */
    if ((NO == [[NSFileManager defaultManager] fileExistsAtPath:sourcePath])
        || (YES == [[NSFileManager defaultManager] fileExistsAtPath:compressPath])) {
        NSLog(@"Source file not exist or destination file already exist!");
        return nil;
    }
    
    LYVideoCompresser *compressor = [[LYVideoCompresser alloc] init];
    compressor.sourcePath = sourcePath;
    compressor.compressPath = compressPath;
    compressor.progressCallback = progressCallback;
    compressor.finishCallback = finishCallback;
    
    [compressor prepare];
    
    return compressor;
}

+ (void)removeFileAtPath:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

/* Info getting */
- (NSString *)compressConfigInfo
{
    return nil;
}

/* Compress */
- (void)startQuickCompress
{
    [_exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self compressCompletedHandle];
        });
    }];
    
    /* Timer syn */
    [_progressTimer invalidate];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(compressCallBack)
                                                    userInfo:nil
                                                     repeats:YES];

}

/* Assistent */
- (void)sourceFileSaveToAlbum
{
    /* Source file check */
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:_sourcePath]) {
        NSLog(@"Source file not exist.");
        return;
    }
    
    [self saveToAlbumWithPath:_sourcePath];
}

- (void)compressFileSaveToAlbum
{
    /* Destination file check */
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:_compressPath]) {
        NSLog(@"Destination file not exist.");
        return;
    }
    
    [self saveToAlbumWithPath:_compressPath];
}

- (void)clearDestinationFile
{
    [[NSFileManager defaultManager] removeItemAtPath:_compressPath error:nil];
}

#pragma mark - MISC
- (void)prepare
{
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_sourcePath]];
    CMTime assetDuration = [avAsset duration];
    
    /* Organize a AVMutableComposition */
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetDuration)
                         ofAsset:avAsset
                          atTime:kCMTimeZero
                           error:nil];
    
    /* Organize a AVMutableVideoComposition */
    AVMutableVideoComposition *avMutableVideoComposition = [self videoCompositionWithAVAssset:avAsset];
    CGRect renderRect = [self clipRectFromVideoSize:avAsset];
    NSString *randerWidth = [NSString stringWithFormat:@"%f",renderRect.size.width];
    NSString *randerHeight = [NSString stringWithFormat:@"%f",renderRect.size.height];
    
    _exportSession = [SDAVAssetExportSession.alloc initWithAsset:composition];
    _exportSession.videoComposition = avMutableVideoComposition;
    _exportSession.outputFileType = AVFileTypeMPEG4;
    _exportSession.shouldOptimizeForNetworkUse = YES;
    _exportSession.outputURL = [NSURL fileURLWithPath:_compressPath];;
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

    
    /* Make video a little short,
     * to jump across the whole black images */
//    CMTime adjustTime = assetDuration;
//    adjustTime.value = assetDuration.value - assetDuration.timescale * 3 / 30;
    [_exportSession setTimeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
}



- (AVMutableVideoComposition *)videoCompositionWithAVAssset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGRect renderRect = [self clipRectFromVideoSize:asset];
    
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
    
    /* Set clip range */
    avMutableVideoComposition.renderSize =  renderRect.size;
    
    /* Set frameDuration */
    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    /* Set Instructions */
    avMutableVideoComposition.instructions = [NSArray arrayWithObject:[self clipInstructionWithTrack:videoTrack duration:asset.duration transOffset:renderRect.origin]];
    
    /* Set Animation Tool */
    avMutableVideoComposition.animationTool = [self musicianAnimationToolWithParentSize:avMutableVideoComposition.renderSize asset:asset];
    
    return avMutableVideoComposition;
}

/* Caculate the right rect of screen */
- (CGRect)clipRectFromVideoSize:(AVAsset *)asset

{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize pixelSize = videoTrack.naturalSize;
    CGRect retRect = CGRectZero;
    
    /* Current screen size is 626 x 640 */
    CGSize videoScreenSize = LY_VIDEO_COMPRESSER_DEFAULT_COMPRESS_REFER_SIZE;
    retRect.size.width = pixelSize.height;
    retRect.size.height = pixelSize.width;
    
    /* pixelSize.height / videoScreenSize.height > pixelSize.width / videoScreenSize.width */
    if (retRect.size.height * videoScreenSize.width > retRect.size.width * videoScreenSize.height) {
        /* Real size is too high */
        CGFloat tmpHeight = retRect.size.width * videoScreenSize.height / videoScreenSize.width;
        retRect.origin.y = (retRect.size.height - tmpHeight) / 2;
        retRect.size.height = tmpHeight;
    } else {
        /* Real size is too wide */
        CGFloat tmpWidth = retRect.size.height * videoScreenSize.width / videoScreenSize.height;
        retRect.origin.x = (retRect.size.width - tmpWidth) / 2;
        retRect.size.width = tmpWidth;
    }
    
    retRect.size.width = (int)retRect.size.width;
    retRect.size.height = (int)retRect.size.height;
    
    NSLog(@"Pixel size : %@", NSStringFromCGSize(pixelSize));
    NSLog(@"Clip size : %@", NSStringFromCGRect(retRect));
    
    return retRect;
}

- (AVMutableVideoCompositionInstruction *)clipInstructionWithTrack:(AVAssetTrack *)videoTrack duration:(CMTime)duration transOffset:(CGPoint)transOffset
{
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

- (void)compressCompletedHandle
{
    if (AVAssetExportSessionStatusCompleted != _exportSession.status)
    {
        NSLog(@"compress failed.");
        _finishCallback(NO);
        return;
    }

    NSLog(@"%@",[self recordFileInfo]);
    [_progressTimer invalidate];
    _progressTimer = nil;

    _finishCallback(YES);
}

- (NSString *)recordFileInfo
{
    NSDictionary *dicAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:_compressPath error:nil];
    float musicSize = [[dicAttr objectForKey:@"NSFileSize"] floatValue] / (1024 * 1024);
    
    NSString *infoStr = [NSString stringWithFormat:@"Record size = %.2f", musicSize];
    return infoStr;
}

- (void)compressCallBack
{
    _progressCallback(_exportSession.progress);
}

- (void)saveToAlbumWithPath:(NSString *)path
{
    /* 测试用 */
    //视频录入完成之后在后台将视频存储到相簿
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum: fileUrl
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          if (error) {
                                              NSLog(@"Save to album failed, ERROR：%@",error.localizedDescription);
                                          } else {
                                              NSLog(@"Save video to album succeed!");
                                          }
                                      }];
}

#pragma mark High Level handle
- (AVVideoCompositionCoreAnimationTool *)musicianAnimationToolWithParentSize:(CGSize)parentSize asset:(AVAsset *)asset
{
    CGRect tmpRect = CGRectZero;
    
    /* Glass layer */
    CALayer *glassLayer = [CALayer layer];
    [glassLayer setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.8].CGColor];
    [glassLayer setMasksToBounds:YES];
    [glassLayer setOpacity:0];
    
    tmpRect.origin = CGPointZero;
    tmpRect.size = parentSize;
    [glassLayer setFrame:tmpRect];
    
    /* Logo layer */
    CALayer *logoLayer = [CALayer layer];
    [logoLayer setContents:(id)[[UIImage imageNamed:@"logo"] CGImage]];
    [logoLayer setMasksToBounds:YES];
    [logoLayer setOpacity:0];
    
    CGFloat logoWidht = 260;
    CGFloat logoHeight = 160;
    tmpRect.origin.x = (parentSize.width - logoWidht) / 2;
    tmpRect.origin.y = (parentSize.height - logoHeight) / 2;
    tmpRect.size = CGSizeMake(logoWidht, logoHeight);
    logoLayer.frame = tmpRect;
    
    /* Video layer */
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, parentSize.width, parentSize.height);
    
    /* Parent Layer */
    CALayer *parentLayer = [CALayer layer];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:glassLayer];
    [parentLayer addSublayer:logoLayer];
    parentLayer.frame = CGRectMake(0, 0, parentSize.width, parentSize.height);
    
    
    /* Animation */
    CMTime duration = asset.duration;
    CFTimeInterval beginTime = CMTimeGetSeconds(duration) - 1.8;
    
    [glassLayer addAnimation:[self musicianAnimationWithBeginTime:beginTime] forKey:@"opacity"];
    [logoLayer addAnimation:[self musicianAnimationWithBeginTime:beginTime] forKey:@"opacity"];
    
    AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                                                                                                                      inLayer:parentLayer];
    return animationTool;
}

- (CAAnimation *)musicianAnimationWithBeginTime:(CFTimeInterval)beginTime
{
    CAKeyframeAnimation *keyAn = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [keyAn setDuration:5.0f];
    NSArray *array = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0],
                      [NSNumber numberWithFloat:1],
                      [NSNumber numberWithFloat:1],
                      nil];
    [keyAn setValues:array];
    
    NSArray *times = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0],
                      [NSNumber numberWithFloat:0.2f],
                      [NSNumber numberWithFloat:1.0f],
                      nil];
    [keyAn setKeyTimes:times];
    [keyAn setBeginTime:beginTime];
    
    return keyAn;
}

@end
