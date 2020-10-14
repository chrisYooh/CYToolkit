//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYVoiceCollector.h"
#import "CYVoicePlayer.h"

#import "ViewController.h"

@interface ViewController ()
<CYVoiceCollectorDelegate,
CYVoicePlayerDelegate>

@property (nonatomic, strong) CYVoiceCollector *collector;
@property (nonatomic, strong) CYVoicePlayer *player;

@property (nonatomic, strong) NSString *curAudioPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _collector = [[CYVoiceCollector alloc] init];
    _collector.channelNum = 1;
    _collector.sampleRate = 44100;
    _collector.feedbackSecRate = 0.05;
    _collector.autoSaveWavFile = YES;
    _collector.delegate = self;
    
    _player = [[CYVoicePlayer alloc] init];
    _player.delegate = self;
    
    _curAudioPath = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    static int iii = 0;
    
    if (0 == iii) {
        NSLog(@"开始录音...");
        [_collector start];
        
    } else if (1 == iii) {
        NSLog(@"结束录音...");
        [_collector stop];

    } else if (2 == iii) {

        NSLog(@"播放录音...");
        [_player loadAudioFile:_curAudioPath];
        [_player play];
    }

    iii = (++iii % 3);
}

#pragma mark - CYVoiceCollectorDelegate

- (void)collector:(CYVoiceCollector *)tool getVoiceData:(NSData *)voiceData {
    NSLog(@"获得数据 %d", (int)voiceData.length);
}

- (void)collector:(CYVoiceCollector *)tool getWavFile:(NSString *)wavFilePath {
    _curAudioPath = wavFilePath;
}

#pragma mark - CYVoicePlayerDelegate

- (void)playerDidFinishPlay:(CYVoicePlayer *)player {
    
}

- (void)player:(CYVoicePlayer *)player playSecUpdated:(NSTimeInterval)playSec {
    
}

@end
