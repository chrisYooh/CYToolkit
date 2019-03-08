//
//  CYVoiceTestViewController.m
//  CYToolkit
//
//  Created by Chris on 2019/3/7.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "CYAvTools.h"

#import "CYVoiceTestViewController.h"

@interface CYVoiceTestViewController ()
<CYVideoRecorderDelegate,
CYVideoCompressorDelegate,
CYVideoPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *playProgress;
@property (weak, nonatomic) IBOutlet UIView *recordScreen;
@property (weak, nonatomic) IBOutlet UIView *playScreen;

@property (nonatomic, strong) CYVideoRecorder *recorder;
@property (nonatomic, strong) CYVideoCompressor *compressor;
@property (nonatomic, strong) CYVideoPlayer *player;

@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, strong) NSString *compressFilePath;

@end

@implementation CYVoiceTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recorder = [[CYVideoRecorder alloc] init];
    _recorder.delegate = self;

    _compressor = [[CYVideoCompressor alloc] init];
    _compressor.delegate = self;

    _player = [[CYVideoPlayer alloc] init];
    _player.delegate = self;
    
    NSString *tmpPath = [NSString cyTemporaryPath];
    _recordFilePath = [tmpPath stringByAppendingPathComponent:@"__testVideoRecordFile.mp4"];
    _compressFilePath = [tmpPath stringByAppendingPathComponent:@"__testVideoCompressFile.mp4"];
    
    [_recordScreen setContentMode:UIViewContentModeScaleAspectFit];
    [_recordScreen.layer insertSublayer:_recorder.previewlayer atIndex:0];
    [_recorder.previewlayer setFrame:_recordScreen.bounds];
    [_playScreen setContentMode:UIViewContentModeScaleAspectFit];
    [_playScreen.layer insertSublayer:_player.previewLayer atIndex:0];
    [_player.previewLayer setFrame:_playScreen.bounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    [_recorder startSession];
}

#pragma mark -

- (IBAction)doRecord:(id)sender {
    NSLog(@"开始录制");
    [_recorder startRecord];
}

- (IBAction)finishRecord:(id)sender {
    NSLog(@"完成录制");
    [_recorder stopRecord];
}

- (IBAction)loadRecord:(id)sender {
    NSLog(@"加载录制视频");
    [_player loadVideoFile:_recordFilePath];
}

- (IBAction)recordSize:(id)sender {
    NSLog(@"录制视频大小: %@", [_recordFilePath cyFileSize]);
}

- (IBAction)recordToAlbum:(id)sender {
    NSLog(@"录制视频存相册");
    [_recordFilePath cySaveToAlbum];
}

- (IBAction)compressLoad:(id)sender {
    NSLog(@"压缩准备");
    [_compressor loadFile:_recordFilePath];
}

- (IBAction)doCompress:(id)sender {
    NSLog(@"开始压缩");
    [_compressor startCompress];
}

- (IBAction)loadCompress:(id)sender {
    NSLog(@"加载压缩视频");
    [_player loadVideoFile:_compressFilePath];
}

- (IBAction)compressSize:(id)sender {
    NSLog(@"压缩视频大小: %@", [_compressFilePath cyFileSize]);
}

- (IBAction)compressToAlbum:(id)sender {
    NSLog(@"压缩视频存相册");
    [_compressor saveToAlbum];
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

#pragma mark - CYVideoRecorderDelegate

- (void)recorderDidStartRecord:(CYVideoRecorder *)recorder {
    NSLog(@"录制开始");
}

- (void)recorder:(CYVideoRecorder *)recorder didFinishRecordToFile:(NSString *)filePath {
    NSLog(@"录制完成: %@", filePath);
    [[NSFileManager defaultManager] removeItemAtPath:_recordFilePath error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:_recordFilePath error:nil];
    NSLog(@"录相已拷贝: %@", _recordFilePath);
}

- (void)recorder:(CYVideoRecorder *)recorder updateRecSec:(NSTimeInterval)recSec {
    NSLog(@"录制时间 %.2f", recSec);
}

#pragma mark - CYVideoCompressorDelegate

- (void)compressor:(CYVideoCompressor *)compressor reportProgress:(float)progress {
    NSLog(@"压缩进度: %.2f", progress);
}

- (void)compressor:(CYVideoCompressor *)compressor didFinishCompressToFile:(NSString *)compressFile {
    NSLog(@"压缩完成: %@", compressFile);
    [[NSFileManager defaultManager] removeItemAtPath:_compressFilePath error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:compressFile toPath:_compressFilePath error:nil];
    NSLog(@"压缩文件已拷贝: %@", _compressFilePath);
}

- (void)compressorFailed:(CYVideoCompressor *)compressor {
    NSLog(@"压缩失败！");
}

#pragma mark - CYVideoPlayerDelegate

- (void)playerReadyToPlay:(CYVideoPlayer *)player {
    NSLog(@"可以播放了");
}

- (void)playerDidFinishPlay:(CYVideoPlayer *)player {
    NSLog(@"播放完成");
}

- (void)player:(CYVideoPlayer *)player loadingSecUpdated:(NSTimeInterval)loadingSec {
}

- (void)player:(CYVideoPlayer *)player playSecUpdated:(NSTimeInterval)playSec {
    [_playProgress setText:[NSString stringWithFormat:@"%.2lf / %.2lf", playSec, _player.curVideoDuration]];
}

@end
