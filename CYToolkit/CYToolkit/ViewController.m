//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToolkit.h"
#import "CYFifoBuffer.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [@"111" cyCacheSaveForKey:@"1"];
    [@"222" cyCacheSaveForKey:@"2"];
    [@"333" cyCacheSaveForKey:@"3"];
    [@"444" cyCacheSaveForKey:@"4"];
    [@"555" cyCacheSaveForKey:@"5"];
    
    NSLog(@"%d", [[CYFifoBuffer sharedBuffer] curCachedNumber]);
    NSLog(@"%@", [[CYFifoBuffer sharedBuffer] curObjects]);

    [[CYFifoBuffer sharedBuffer] refreshKey:@"3"];

    NSLog(@"%d", [[CYFifoBuffer sharedBuffer] curCachedNumber]);
    NSLog(@"%@", [[CYFifoBuffer sharedBuffer] curObjects]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

@end
