//
//  CYVoiceCompressor.h
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CYVoiceCompressor;

@protocol CYVoiceCompressorDelegate <NSObject>

- (void)compressor:(CYVoiceCompressor *)compressor didFinishCompressToFile:(NSString *)compressFile;
- (void)compressor:(CYVoiceCompressor *)compressor failedWithError:(NSError *)error;

@end

@interface CYVoiceCompressor : NSObject

@property (nonatomic, weak) id<CYVoiceCompressorDelegate> delegate;

- (void)compressPcmFileToMp3:(NSString *)srcFilePath;    

@end

NS_ASSUME_NONNULL_END
