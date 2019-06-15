//
//  UIViewController+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "UIViewController+CYCategory.h"

@implementation UIViewController (CYCategory)

+ (UIViewController *)cyCurrentVc {
    
    UIViewController *rootVc = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *curVc = [self currentVcFromVc:rootVc];
    return curVc;
}

+ (UIViewController*)currentVcFromVc:(UIViewController*)inputVc {
    
    UIViewController *curVc = inputVc;
    
    if ([inputVc isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navVc = (UINavigationController *)inputVc;
        curVc = [self currentVcFromVc:navVc.viewControllers.lastObject];
        
    } else if ([inputVc isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController* tabBarController = (UITabBarController *)inputVc;
        curVc = [self currentVcFromVc:tabBarController.selectedViewController];
        
    } else if (nil != inputVc.presentedViewController) {
        
        curVc = [self currentVcFromVc:inputVc.presentedViewController];
    }
    
    return curVc;
}

- (void)cyShowAlertController:(UIAlertController *)alertController {
    
    if ([alertController respondsToSelector:@selector(popoverPresentationController)]) {
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect =
        CGRectMake(0,
                   [UIScreen mainScreen].bounds.size.height,
                   [UIScreen mainScreen].bounds.size.width,
                   [UIScreen mainScreen].bounds.size.height);
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
