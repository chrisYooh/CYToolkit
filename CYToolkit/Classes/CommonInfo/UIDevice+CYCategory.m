//
//  UIDevice+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "CYKeychain.h"
#import "CYIdfa.h"

#import "UIDevice+CYCategory.h"

/* 为避免CYIdfa非预期更新的问题，采取CYIdfa缓存策略如下：
 * 1. 首先读取keychain预存的phoneToken；
 * 1.1 phoneToken存在，直接返回
 * 1.2 phoneToken不存在，再走idfa或CYIdfa获取逻辑，并将新的phoneToken写入钥匙串
 */
static NSString *cyLogPhoneTokenKeychainKey = @"cyLogPhoneTokenKeychainKey";

@implementation UIDevice (CYCategory)

#pragma mark - Base Info

+ (NSString *)cyOSVersionString {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)cyPhoneTypeString {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *preciseType = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    NSString *announceType = [self iphoneAnnounceTypeWithPreciseType:preciseType];
    NSString *typeStr = [NSString stringWithFormat:@"%@(%@)", announceType, preciseType];
    return typeStr;
}

+ (NSString *)cyDeviceTokenString {
    
    NSString *tmpStr = @"";
    
    /* 1. keyChain操作逻辑 */
    tmpStr = [CYKeychain loadObjectForKey:cyLogPhoneTokenKeychainKey];
    if (nil != tmpStr && NO == [@"" isEqualToString:tmpStr]) {
        return tmpStr;
    }
    
    /* 2. 新phoneToken获取逻辑 */
    if (YES == [CYIdfa cyCanGetSysIdfa]) {
        tmpStr = [CYIdfa cySysIdfa];
    } else {
        /* 存在因用户手动关闭广告追踪而无法获取idfa值的问题，
         * 针对该类用户，设备唯一标识使用CYIdfa替代
         */
        tmpStr = [CYIdfa cySimulateIDFA];
    }
    
    /* 3. 新phoneToken写keyChain逻辑 */
    [CYKeychain saveObject:tmpStr forKey:cyLogPhoneTokenKeychainKey];
    
    return tmpStr;
}

+ (NSString *)cyIspInfoString {
    
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    
    /* Carrier Name在获取失败的时候会保持上次获取的信息，
     * 所以使用mobileContryCode来临时替代获取成功失败的判定 */
    if (nil == carrier.mobileCountryCode) {
        return @"";
    }
    
    return [carrier carrierName];
}

+ (NSString *)cyNetTypeString {
    struct sockaddr_in address = {
        .sin_len = sizeof(struct sockaddr_in),
        .sin_family = AF_INET,
        .sin_addr = { .s_addr = INADDR_ANY },
    };
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);
    
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
        if (flags & kSCNetworkReachabilityFlagsReachable) {
            if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
                return @"4G/3G/E";
            }
            SCNetworkReachabilityFlags interestingFlags = flags & (kSCNetworkReachabilityFlagsConnectionRequired|kSCNetworkReachabilityFlagsTransientConnection|kSCNetworkReachabilityFlagsInterventionRequired|kSCNetworkReachabilityFlagsConnectionOnTraffic|kSCNetworkReachabilityFlagsConnectionOnDemand);
            
            if (interestingFlags == (kSCNetworkReachabilityFlagsConnectionRequired|kSCNetworkReachabilityFlagsTransientConnection)) {
                return @"无服务";
            }
            
            if (interestingFlags & (kSCNetworkFlagsConnectionRequired|kSCNetworkFlagsTransientConnection)) {
                return @"Wifi";
            }
            if (interestingFlags == 0) {
                return @"Wifi";
            }
        }
    }
    return @"无服务";
}


+ (NSString *)cyInnerIpString {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    return address;
}

#pragma mark -

+ (NSString *)iphoneAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    if ([preciseType isEqualToString:@"iPhone1,1"]) { return @"iPhone 2G"; }
    if ([preciseType isEqualToString:@"iPhone1,2"]) { return @"iPhone 3G"; }
    if ([preciseType isEqualToString:@"iPhone2,1"]) { return @"iPhone 3GS"; }
    if ([preciseType isEqualToString:@"iPhone3,1"]) { return @"iPhone 4"; }
    if ([preciseType isEqualToString:@"iPhone3,2"]) { return @"iPhone 4"; }
    if ([preciseType isEqualToString:@"iPhone3,3"]) { return @"iPhone 4"; }
    if ([preciseType isEqualToString:@"iPhone4,1"]) { return @"iPhone 4S"; }
    if ([preciseType isEqualToString:@"iPhone5,1"]) { return @"iPhone 5"; }
    if ([preciseType isEqualToString:@"iPhone5,2"]) { return @"iPhone 5"; }
    if ([preciseType isEqualToString:@"iPhone5,3"]) { return @"iPhone 5c"; }
    if ([preciseType isEqualToString:@"iPhone5,4"]) { return @"iPhone 5c"; }
    if ([preciseType isEqualToString:@"iPhone6,1"]) { return @"iPhone 5s"; }
    if ([preciseType isEqualToString:@"iPhone6,2"]) { return @"iPhone 5s"; }
    
    if ([preciseType isEqualToString:@"iPhone7,1"]) { return @"iPhone 6 Plus"; }
    if ([preciseType isEqualToString:@"iPhone7,2"]) { return @"iPhone 6"; }
    if ([preciseType isEqualToString:@"iPhone8,1"]) { return @"iPhone 6s"; }
    if ([preciseType isEqualToString:@"iPhone8,2"]) { return @"iPhone 6s Plus"; }
    if ([preciseType isEqualToString:@"iPhone8,4"]) { return @"iPhone SE"; }
    if ([preciseType isEqualToString:@"iPhone9,1"]) { return @"iPhone 7"; }
    if ([preciseType isEqualToString:@"iPhone9,2"]) { return @"iPhone 7 Plus"; }
    
    if ([preciseType isEqualToString:@"iPod1,1"]) { return @"iPod Touch 1G"; }
    if ([preciseType isEqualToString:@"iPod2,1"]) { return @"iPod Touch 2G"; }
    if ([preciseType isEqualToString:@"iPod3,1"]) { return @"iPod Touch 3G"; }
    if ([preciseType isEqualToString:@"iPod4,1"]) { return @"iPod Touch 4G"; }
    if ([preciseType isEqualToString:@"iPod5,1"]) { return @"iPod Touch 5G"; }
    
    if ([preciseType isEqualToString:@"iPad1,1"]) { return @"iPad 1G"; }
    if ([preciseType isEqualToString:@"iPad2,1"]) { return @"iPad 2"; }
    if ([preciseType isEqualToString:@"iPad2,2"]) { return @"iPad 2"; }
    if ([preciseType isEqualToString:@"iPad2,3"]) { return @"iPad 2"; }
    if ([preciseType isEqualToString:@"iPad2,4"]) { return @"iPad 2"; }
    if ([preciseType isEqualToString:@"iPad2,5"]) { return @"iPad Mini 1G"; }
    if ([preciseType isEqualToString:@"iPad2,6"]) { return @"iPad Mini 1G"; }
    if ([preciseType isEqualToString:@"iPad2,7"]) { return @"iPad Mini 1G"; }
    if ([preciseType isEqualToString:@"iPad3,1"]) { return @"iPad 3"; }
    if ([preciseType isEqualToString:@"iPad3,2"]) { return @"iPad 3"; }
    if ([preciseType isEqualToString:@"iPad3,3"]) { return @"iPad 3"; }
    if ([preciseType isEqualToString:@"iPad3,4"]) { return @"iPad 4"; }
    if ([preciseType isEqualToString:@"iPad3,5"]) { return @"iPad 4"; }
    if ([preciseType isEqualToString:@"iPad3,6"]) { return @"iPad 4"; }
    
    if ([preciseType isEqualToString:@"iPad4,1"]) { return @"iPad Air"; }
    if ([preciseType isEqualToString:@"iPad4,2"]) { return @"iPad Air"; }
    if ([preciseType isEqualToString:@"iPad4,3"]) { return @"iPad Air"; }
    if ([preciseType isEqualToString:@"iPad4,4"]) { return @"iPad Mini 2G"; }
    if ([preciseType isEqualToString:@"iPad4,5"]) { return @"iPad Mini 2G"; }
    if ([preciseType isEqualToString:@"iPad4,6"]) { return @"iPad Mini 2G"; }
    if ([preciseType isEqualToString:@"i386"]) { return @"iPhone Simulator"; }
    if ([preciseType isEqualToString:@"x86_64"]) { return @"iPhone Simulator"; }
    
    return preciseType;
}

+ (NSString *)networkStrFromSystemNetworkType:(NSInteger)systemNetType {
    
    if (0 == systemNetType) { return @"无服务"; }
    if (1 == systemNetType) { return @"2G"; }
    if (2 == systemNetType) { return @"3G"; }
    if (3 == systemNetType) { return @"4G"; }
    if (4 == systemNetType) { return @"LTE"; }
    if (5 == systemNetType) { return @"Wifi"; }
    return @"";
}

@end
