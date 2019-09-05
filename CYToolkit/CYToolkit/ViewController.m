//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToolkit.h"

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *tmpView;
@property (nonatomic, strong) NSArray<UIImage *> *imageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [@"测试" cyBundleCopy];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", [NSString cyCopyedStr]);
    NSLog(@"%@", [NSString cyBundleCopyedStr]);
}

@end
