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
    _tool.framePerSecond = 100;
    _tool.delegate = self;
//    _tool.videoPath = [[NSBundle mainBundle] pathForResource:@"customer" ofType:@"mp4"];
    _tool.videoPath = [[NSBundle mainBundle] pathForResource:@"testmovie" ofType:@"MOV"];
    
    _imageView = [[UIImageView alloc] init];
    [_imageView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:_imageView];
    [_imageView setFrame:CGRectMake(100, 100, 200, 200)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_tool start];
}

#pragma mark - CYVideo2ImageDelegate

- (void)v2itool:(CYVideo2Image *)tool postError:(NSError *)error {
    
}

- (void)v2itool:(CYVideo2Image *)tool feedbackImage:(UIImage *)image frameTime:(NSTimeInterval)frameTime {
    
    static int i = 0;
    NSLog(@"%.4f, %d", frameTime, i++);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imageView setImage:image];
    });
}

@end
