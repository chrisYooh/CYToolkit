//
//  CYVideoCompressor.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"

NS_ASSUME_NONNULL_BEGIN

@class CYVideoCompressor;

@protocol CYVideoCompressorDelegate <NSObject>

- (void)compressor:(CYVideoCompressor *)compressor reportProgress:(float)progress;
- (void)compressor:(CYVideoCompressor *)compressor didFinishCompressToFile:(NSString *)compressFile;
- (void)compressorFailed:(CYVideoCompressor *)compressor;

@end

@interface CYVideoCompressor : NSObject

@property (nonatomic, weak) id<CYVideoCompressorDelegate> delegate;
@property (nonatomic, assign) CGSize confOutputSize;                    /* 输出视频大小 */

- (void)compressFile:(NSString *)srcFilePath;

@end

NS_ASSUME_NONNULL_END