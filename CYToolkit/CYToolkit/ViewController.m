//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CAAnimation+CYCategory.h"

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *tmpView;
@property (nonatomic, strong) NSArray<UIImage *> *imageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *tmpMulArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 15; i++) {
        UIImage *tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
        [tmpMulArray addObject:tmpImage];
    }
    _imageArray = tmpMulArray.copy;
    
    _tmpView = [[UIView alloc] init];
    [self.view addSubview:_tmpView];
    [_tmpView setFrame:CGRectMake(100, 300, 200, 200)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CAAnimation *tmpAni = [CAAnimation cyImgAnimationWithImageArray:_imageArray duration:1];
    [_tmpView.layer addAnimation:tmpAni forKey:nil];
}

@end
