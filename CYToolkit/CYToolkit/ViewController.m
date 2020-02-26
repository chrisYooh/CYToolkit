//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "CYTTS.h"

#import "ViewController.h"

@interface ViewController ()
<CYTTSDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%d", CYDefIsIphoneX);
    
    [CYTTS sharedInstance].delegate = self;
    [[CYTTS sharedInstance] speak:@"hello"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

- (void)ttsDidFinishedSpeak:(CYTTS *)tts {
    NSLog(@"999");
}
@end
