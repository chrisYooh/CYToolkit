//
//  CYVideoToolTestViewController.m
//  CYToolkit
//
//  Created by Chris on 2019/3/5.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYVideoTool.h"
#import "CYCompatible.h"

#import "CYVideoToolTestViewController.h"

@interface CYVideoToolTestViewController ()
<CYVideoToolDelegate>

@property (nonatomic, strong) CYVideoTool *vdTool;
@property (nonatomic, strong) UIImageView *testImageView;

@end

@implementation CYVideoToolTestViewController

- (id)init {
    self = [super init];
    if (self) {
        _vdTool = [[CYVideoTool alloc] init];
        _vdTool.delegate = self;
        //_vdTool.confFrontCamera = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer insertSublayer:_vdTool.previewlayer atIndex:0];
    [_vdTool.previewlayer setFrame:self.view.bounds];
    
    _testImageView = [[UIImageView alloc] init];
    [_testImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:_testImageView];
    [_testImageView setFrame:CGRectMake(10, 10, 150, 260)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_vdTool startSession];
    
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - CYVideoToolDelegate

/* 获取原始的视频帧输出 */
- (void)videoTool:(CYVideoTool *)tool getSampleBuffer:(CMSampleBufferRef)bufferRef {
}

/* 获取视频帧转化为图像的输出,
 * 仅当transToImage为YES时回调 */
- (void)videoTool:(CYVideoTool *)tool captureOutputImage:(UIImage *)outImage {
    
    cyWeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.testImageView setImage:outImage];
    });
}

@end
