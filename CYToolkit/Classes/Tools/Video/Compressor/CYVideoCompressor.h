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

@class CYVideoCompressor;

@protocol CYVideoCompressorDelegate <NSObject>

- (void)compressor:(CYVideoCompressor *)compressor reportProgress:(float)progress;
- (void)compressor:(CYVideoCompressor *)compressor didFinishCompressToFile:(NSString *)compressFile;
- (void)compressorFailed:(CYVideoCompressor *)compressor;

@end

@interface CYVideoCompressor : NSObject

@property (nonatomic, weak) id<CYVideoCompressorDelegate> delegate;

@property (nonatomic, assign) CGSize confOutputSize;                    /* 输出视频大小 */

- (void)loadFile:(NSString *)srcFilePath;   /* 加载待压缩文件 */
- (void)startCompress;                      /* 开始压缩 */
- (void)stopCompress;                       /* 停止压缩 */

- (void)saveToAlbum;                        /* 将最近完成的压缩存入相册 */

@end
