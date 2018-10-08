//
//  UIWebView+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (CYCategory)

+ (void)cyConfigUserAgentWithDeviceIdentifier:(NSString *)deviceIdentifier
                              withNetworkType:(NSString *)networkType;

@end

NS_ASSUME_NONNULL_END
