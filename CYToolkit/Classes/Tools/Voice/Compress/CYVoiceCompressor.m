//
//  CYVoiceCompressor.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "lame.h"
#import "NSString+CYCategory.h"

#import "CYVoiceCompressor.h"

#define __CompressFileName            @"cyToolkitVoiceCompressTmpFile"

@implementation CYVoiceCompressor

#pragma mark - MISC

- (NSString *)__compressPath {
    NSString *tmpPath = [NSString cyTemporaryPath];
    tmpPath = [tmpPath stringByAppendingPathComponent:__CompressFileName];
    return tmpPath;
}

#pragma mark - User Interface

- (void)compressPcmFileToMp3:(NSString *)srcFilePath {
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:srcFilePath]) {
        NSLog(@"待压缩文件不存在");
        return;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[self __compressPath] error:nil];
    
    @try {
        size_t read = 0, write = 0;
        
        FILE *pcmFile = fopen([srcFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcmFile, 4 * 1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([[self __compressPath] cStringUsingEncoding:1], "wb");    //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcmFile);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, (int)read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcmFile);
    }
    @catch (NSException *exception) {
        NSError *error = [NSError errorWithDomain:[exception description] code:-1 userInfo:nil];
        if ([_delegate respondsToSelector:@selector(compressor:failedWithError:)]) {
            [_delegate compressor:self failedWithError:error];
        }
    }
    @finally {
        if ([_delegate respondsToSelector:@selector(compressor:didFinishCompressToFile:)]) {
            [_delegate compressor:self didFinishCompressToFile:[self __compressPath]];
        }
    }
}

@end
