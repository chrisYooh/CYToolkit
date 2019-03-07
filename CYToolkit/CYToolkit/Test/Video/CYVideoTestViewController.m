//
//  CYVideoTestViewController.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "CYAvTools.h"

#import "CYVideoTestViewController.h"

@interface CYVideoTestViewController ()
<CYVoiceRecorderDelegate,
CYVoiceCompressorDelegate,
CYVoicePlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (nonatomic, strong) CYVoiceRecorder *recorder;
@property (nonatomic, strong) CYVoiceCompressor *compressor;
@property (nonatomic, strong) CYVoicePlayer *player;

@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, strong) NSString *compressFilePath;

@end

@implementation CYVideoTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recorder = [[CYVoiceRecorder alloc] init];
    _recorder.delegate = self;
    
    _compressor = [[CYVoiceCompressor alloc] init];
    _compressor.delegate = self;
    
    _player = [[CYVoicePlayer alloc] init];
    _player.delegate = self;
    
    NSString *tmpPath = [NSString cyTemporaryPath];
    _recordFilePath = [tmpPath stringByAppendingPathComponent:@"__testRecordFile"];
    _compressFilePath = [tmpPath stringByAppendingPathComponent:@"__testCompressFile"];
}

#pragma mark -

- (IBAction)doRecord:(id)sender {
    NSLog(@"录制开始");
    [_recorder startRecord];
}

- (IBAction)finishRecord:(id)sender {
    NSLog(@"录制完成");
    [_recorder stopRecord];
}

- (IBAction)loadRecord:(id)sender {
    NSLog(@"加载录音");
    //[_player loadAudioFile:_recordFilePath];
    NSURL *tmpUrl = [NSURL URLWithString:@"https://github.com/chrisYooh/chrisLife/raw/master/18年12月%20唱歌比赛/可乐-杨一凡.mp3"];
    [_player loadAudioUrl:tmpUrl];
}

- (IBAction)recordSize:(id)sender {
    NSLog(@"%@", [_recordFilePath cyFileSize]);
}

- (IBAction)DoCompress:(id)sender {
    NSLog(@"压缩录音");
    [_compressor compressPcmFileToMp3:_recordFilePath];
}

- (IBAction)loadCompressFile:(id)sender {
    NSLog(@"加载压缩录音");
    [_player loadAudioFile:_compressFilePath];
}

- (IBAction)compressFileSIze:(id)sender {
    NSLog(@"%@", [_compressFilePath cyFileSize]);
}

- (IBAction)doPlay:(id)sender {
    NSLog(@"播放");
    [_player play];
}

- (IBAction)doPause:(id)sender {
    NSLog(@"暂停");
    [_player pause];
}

- (IBAction)doStop:(id)sender {
    NSLog(@"停止");
    [_player stop];
}

#pragma mark - CYVoiceRecorderDelegate

- (void)recorderDidStartRecord:(CYVoiceRecorder *)recorder {
    NSLog(@"录音开始了");
}

- (void)recorder:(CYVoiceRecorder *)recorder didFinishRecordToFile:(NSString *)filePath {
    NSLog(@"录音完成了: %@", filePath);
    [[NSFileManager defaultManager] removeItemAtPath:_recordFilePath error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:_recordFilePath error:nil];
    NSLog(@"录音已拷贝: %@", _recordFilePath);
}

#pragma mark - CYVoiceCompressorDelegate

- (void)compressor:(CYVoiceCompressor *)compressor didFinishCompressToFile:(NSString *)compressFile {
    NSLog(@"压缩完成: %@", compressFile);
    [[NSFileManager defaultManager] removeItemAtPath:_compressFilePath error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:compressFile toPath:_compressFilePath error:nil];
    NSLog(@"压缩文件已拷贝: %@", _compressFilePath);
}

- (void)compressor:(CYVoiceCompressor *)compressor failedWithError:(NSError *)error {
    NSLog(@"压缩失败！");
}

#pragma mark - CYVoicePlayerDelegate

- (void)playerDidFinishPlay:(CYVoicePlayer *)player {
    NSLog(@"播放完成");
}

- (void)player:(CYVoicePlayer *)player playSecUpdated:(NSTimeInterval)playSec {
    [_progressLabel setText:[NSString stringWithFormat:@"%.2lf / %.2lf", playSec, _player.curAudioDuration]];
}

@end
