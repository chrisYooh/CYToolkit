//
//  LYVideoCompresser.h
//  VideoRecorder&Player
//
//  Created by mac on 15/8/7.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class SDAVAssetExportSession;

/* Ref size is 640 * 501, 0.7828125 = 501 / 640 */
#define LY_VIDEO_COMPRESSER_DEFAULT_COMPRESS_REFER_SIZE     CGSizeMake(640, 501)
#define LY_VIDEO_COMPRESSER_DEFAULT_COMPRESS_HEIGHT_WIDTH_RATIO     0.7828125

typedef void (^videoCompressProgressCallbackBlock)(float progress);
typedef void (^videoCompressCompleteCallbackBlock)(BOOL complete);

@interface LYVideoCompresser : NSObject

@property (nonatomic, strong) SDAVAssetExportSession *exportSession;

@property (nonatomic, copy) videoCompressProgressCallbackBlock progressCallback;
@property (nonatomic, copy) videoCompressCompleteCallbackBlock finishCallback;
@property (nonatomic, retain) NSTimer *progressTimer;

@property (nonatomic, retain) NSString *sourcePath;
@property (nonatomic, retain) NSString *compressPath;

+ (LYVideoCompresser *)compresserWithSourcePath:(NSString *)sourcePath
                                   compressPath:(NSString *)compressPath
                               progressCallback:(videoCompressProgressCallbackBlock)progressCallback
                                 finishCallback:(videoCompressCompleteCallbackBlock)finishCallback;

+ (void)removeFileAtPath:(NSString *)filePath;

/* Info getting */
- (NSString *)compressConfigInfo;

/* Compress */
- (void)startQuickCompress;

/* Assistent */
- (void)sourceFileSaveToAlbum;
- (void)compressFileSaveToAlbum;
- (void)clearDestinationFile;

@end
