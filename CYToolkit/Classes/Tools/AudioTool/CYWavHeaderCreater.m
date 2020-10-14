//
//  CYWavHeaderCreater.m
//  GmesTest
//
//  Created by Chris Yang on 2020/10/13.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import "CYWavHeaderCreater.h"

#define __BYTE_PER_SAMPLE           2

@implementation CYWavHeaderCreater

+ (NSData *)createWavHeaderWithData:(NSData *)pcmData channel:(NSInteger)channel sampleRate:(NSInteger)sampleRate {
    
    /* 音频数据的总长度 */
    NSUInteger totalAudioLen = pcmData.length;
    
    /* 数据的总长度 */
    NSUInteger totalDataLen = totalAudioLen + 36; // 36 = 44 - 8
    
    /* 每秒字节数：*/
    NSUInteger byteRate = channel * sampleRate * __BYTE_PER_SAMPLE;
    
    char header[44] = {0};
    
    // RIFF header
    header[0] = 'R';
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    
    // 从第8个字节到末尾的文件长度
    header[4] = totalDataLen & 0xff;
    header[5] = (totalDataLen >> 8) & 0xff;
    header[6] = (totalDataLen >> 16) & 0xff;
    header[7] = (totalDataLen >> 24) & 0xff;
    
    // WAVE
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    
    // fmt chunk
    header[12] = 'f';
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    
    // size of 'fmt ' chunk
    header[16] = 16;
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    
    // format = 1 表示非压缩格式，fmt块长4，fact块长度0
    header[20] = 1;
    header[21] = 0;
    
    // channel num
    header[22] = channel & 0xff;
    header[23] = (channel >> 8) & 0xff;
    
    // sample rate（表示每秒的采样个数）
    header[24] = sampleRate & 0xff;
    header[25] = (sampleRate >> 8) & 0xff;
    header[26] = (sampleRate >> 16) & 0xff;
    header[27] = (sampleRate >> 24) & 0xff;

    // byte rate（数据传输速率，表示每秒生产的数据量，单位字节：声道数×采样频率×每样本的数据位数/8）
    header[28] = byteRate & 0xff;
    header[29] = (byteRate >> 8) & 0xff;
    header[30] = (byteRate >> 16) & 0xff;
    header[31] = (byteRate >> 24) & 0xff;

    // block align（数据块对齐单位：声道数 * 每个sample比特数）
    header[32] = channel * __BYTE_PER_SAMPLE;
    header[33] = 0;
    
    // bits per sample（每个采样值占的二进制位数）
    header[34] = __BYTE_PER_SAMPLE * 8;
    header[35] = 0;
    
    // data
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    
    // Audio Len (从44字节到末尾的数据长度）
    header[40] = totalAudioLen & 0xff;
    header[41] = (totalAudioLen >> 8) & 0xff;
    header[42] = (totalAudioLen >> 16) & 0xff;
    header[43] = (totalAudioLen >> 24) & 0xff;
    
    NSData *headerData = [NSData dataWithBytes:header length:44];
    return headerData;
}

@end
