//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYVoiceCollector.h"
#import "CYVoicePlayer.h"
#import "CYVideo2Image.h"

#import "ViewController.h"

@interface ViewController ()
<CYVideo2ImageDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CYVideo2Image *tool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _tool = [[CYVideo2Image alloc] init];
    _tool.delegate = self;
    _tool.videoPath = [[NSBundle mainBundle] pathForResource:@"customer" ofType:@"mp4"];
//    _tool.videoPath = [[NSBundle mainBundle] pathForResource:@"testmovie" ofType:@"MOV"];
        
    _imageView = [[UIImageView alloc] init];
    [_imageView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:_imageView];
    [_imageView setFrame:CGRectMake(100, 100, 200, 200)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"执行任务");
    [_tool start];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"停止任务");
        [weakSelf.tool stop];
    });
}

#pragma mark - CYVideo2ImageDelegate

- (void)v2itool:(CYVideo2Image *)tool postError:(NSError *)error {
    
}

- (void)v2itool:(CYVideo2Image *)tool feedbackImage:(UIImage *)image frameIndex:(NSTimeInterval)frameTime {
    
    static int i = 0;
    NSLog(@"%.4f, %d  %@", frameTime, i++, NSStringFromCGSize(image.size));
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imageView setImage:image];
    });
}

- (void)v2itoolDidFinishTrack:(CYVideo2Image *)tool {
    NSLog(@"结束分析");
}

@end
