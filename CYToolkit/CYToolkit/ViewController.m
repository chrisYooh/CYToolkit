//
//  ViewController.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYVideoToolTestViewController.h"
#import "CYVideoTestViewController.h"   /* 其实是Voice，代码填反了 */
#import "CYVoiceTestViewController.h"   /* 其实是Video，代码填反了 */

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CYVoiceTestViewController *tmpVc = [[CYVoiceTestViewController alloc] init];
    [self.navigationController pushViewController:tmpVc animated:YES];
}

@end
