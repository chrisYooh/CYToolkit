//
//  UIWebView+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "UIWebView+CYCategory.h"

@implementation UIWebView (CYCategory)

+(void)cyConfigUserAgentWithDeviceIdentifier:(NSString *)deviceIdentifier
                             withNetworkType:(NSString *)networkType {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *phoneBrand = @"apple";
    UIWebView *tmpWebView = [[UIWebView alloc] init];
    NSString* userAgent = [tmpWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *ua = [NSString stringWithFormat:@"%@ | "
                    "{\"deviceIdentifier\":\"%@\","
                    "\"appVersion\":\"%@\","
                    "\"phoneBrand\":\"%@\","
                    "\"networkType\":\"%@\"}",
                    userAgent,
                    deviceIdentifier,
                    appVersion,
                    phoneBrand,
                    networkType];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : ua, @"User-Agent" : ua}];
}

@end
