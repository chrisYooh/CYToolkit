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

+ (NSString *)cyPhoneInternalName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *preciseType = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return preciseType;
}

+ (NSString *)cyPhoneTypeString {
    NSString *preciseType = [self cyPhoneInternalName];
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

+ (BOOL)cyIsIphoneXFamily {
    NSString *preciseType = [self cyPhoneInternalName];
    if ([preciseType isEqualToString:@"iPhone10,3"]
        || [preciseType isEqualToString:@"iPhone10,6"]
        || [preciseType isEqualToString:@"iPhone11,2"]
        || [preciseType isEqualToString:@"iPhone11,4"]
        || [preciseType isEqualToString:@"iPhone11,6"]
        || [preciseType isEqualToString:@"iPhone11,8"]
        || [preciseType isEqualToString:@"iPhone12,1"]
        || [preciseType isEqualToString:@"iPhone12,3"]
        || [preciseType isEqualToString:@"iPhone12,5"]
        ) {
        return YES;
    }
    
    return NO;
}

#pragma mark -

#define __typePair(appleStr, publicStr) \
if ([preciseType isEqualToString:appleStr]) { return publicStr; }

+ (NSString *)iphoneAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    NSString *transType = nil;
    
    transType = [self __iphoneAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }
    
    transType = [self __ipodAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }
    
    transType = [self __ipadAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }
    
    transType = [self __ipadAirAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }

    transType = [self __ipadProAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }

    transType = [self __ipadMiniAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }

    transType = [self __simulatorAnnounceTypeWithPreciseType:preciseType];
    if (nil != transType) {
        return transType;
    }
    
    return preciseType;
}

#define __typePair(appleStr, publicStr) \
if ([preciseType isEqualToString:appleStr]) { return publicStr; }

+ (NSString *)__iphoneAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPhone1,1", @"iPhone 2G")
    __typePair(@"iPhone1,2", @"iPhone 3G")
    __typePair(@"iPhone2,1", @"iPhone 3GS")
    __typePair(@"iPhone3,1", @"iPhone 4")
    __typePair(@"iPhone3,2", @"iPhone 4")
    __typePair(@"iPhone3,3", @"iPhone 4")
    __typePair(@"iPhone4,1", @"iPhone 4S")
    __typePair(@"iPhone5,1", @"iPhone 5")
    __typePair(@"iPhone5,2", @"iPhone 5")
    __typePair(@"iPhone5,3", @"iPhone 5c")
    __typePair(@"iPhone5,4", @"iPhone 5c")
    __typePair(@"iPhone6,1", @"iPhone 5s")
    __typePair(@"iPhone6,2", @"iPhone 5s")
    
    __typePair(@"iPhone7,2", @"iPhone 6")
    __typePair(@"iPhone7,1", @"iPhone 6 Plus")
    __typePair(@"iPhone8,1", @"iPhone 6s")
    __typePair(@"iPhone8,2", @"iPhone 6s Plus")
    __typePair(@"iPhone8,4", @"iPhone SE")
    __typePair(@"iPhone9,1", @"iPhone 7")
    __typePair(@"iPhone9,3", @"iPhone 7")
    __typePair(@"iPhone9,2", @"iPhone 7 Plus")
    __typePair(@"iPhone9,4", @"iPhone 7 Plus")
    
    __typePair(@"iPhone10,1", @"iPhone 8")
    __typePair(@"iPhone10,4", @"iPhone 8")
    __typePair(@"iPhone10,2", @"iPhone 8 Plus")
    __typePair(@"iPhone10,5", @"iPhone 8 Plus")
    __typePair(@"iPhone10,3", @"iPhone X")
    __typePair(@"iPhone10,6", @"iPhone X")
    __typePair(@"iPhone11,8", @"iPhone XR")
    __typePair(@"iPhone11,2", @"iPhone XS")
    __typePair(@"iPhone11,4", @"iPhone XS Max")
    __typePair(@"iPhone11,6", @"iPhone XS Max")
    
    __typePair(@"iPhone12,1", @"iPhone 11")
    __typePair(@"iPhone12,3", @"iPhone 11 Pro")
    __typePair(@"iPhone12,5", @"iPhone 11 Pro Max")
    __typePair(@"iPhone12,8", @"iPhone SE 2G")
        
    return nil;
}

+ (NSString *)__ipodAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPod1,1", @"iPod Touch")
    __typePair(@"iPod2,1", @"iPod Touch 2G")
    __typePair(@"iPod3,1", @"iPod Touch 3G")
    __typePair(@"iPod4,1", @"iPod Touch 4G")
    __typePair(@"iPod5,1", @"iPod Touch 5G")
    __typePair(@"iPod7,1", @"iPod Touch 6G")
    __typePair(@"iPod9,1", @"iPod Touch 7G")

    return nil;
}

+ (NSString *)__ipadAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPad1,1", @"iPad 1G")
    __typePair(@"iPad2,1", @"iPad 2G")
    __typePair(@"iPad2,2", @"iPad 2G")
    __typePair(@"iPad2,3", @"iPad 2G")
    __typePair(@"iPad2,4", @"iPad 2G")
    __typePair(@"iPad3,1", @"iPad 3G")
    __typePair(@"iPad3,2", @"iPad 3G")
    __typePair(@"iPad3,3", @"iPad 3G")
    __typePair(@"iPad3,4", @"iPad 4G")
    __typePair(@"iPad3,5", @"iPad 4G")
    __typePair(@"iPad3,6", @"iPad 4G")

    __typePair(@"iPad6,11", @"iPad 5G")
    __typePair(@"iPad6,12", @"iPad 5G")
    __typePair(@"iPad7,5", @"iPad 6G")
    __typePair(@"iPad7,6", @"iPad 6G")
    __typePair(@"iPad7,11", @"iPad 7G")
    __typePair(@"iPad7,12", @"iPad 7G")
    
    return nil;
}

+ (NSString *)__ipadAirAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPad4,1", @"iPad Air")
    __typePair(@"iPad4,2", @"iPad Air")
    __typePair(@"iPad4,3", @"iPad Air")
    __typePair(@"iPad5,3", @"iPad Air 2G")
    __typePair(@"iPad5,4", @"iPad Air 2G")
    __typePair(@"iPad11,3", @"iPad Air 3G")
    __typePair(@"iPad11,4", @"iPad Air 3G")
    
    return nil;
}

+ (NSString *)__ipadProAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPad6,3", @"iPad Pro 9.7-inch")
    __typePair(@"iPad6,4", @"iPad Pro 9.7-inch")
    
    __typePair(@"iPad7,3", @"iPad Pro 10.5-inch")
    __typePair(@"iPad7,4", @"iPad Pro 10.5-inch")
    
    __typePair(@"iPad8,1", @"iPad Pro 11.0-inch")
    __typePair(@"iPad8,2", @"iPad Pro 11.0-inch")
    __typePair(@"iPad8,3", @"iPad Pro 11.0-inch")
    __typePair(@"iPad8,4", @"iPad Pro 11.0-inch")
    __typePair(@"iPad8,9", @"iPad Pro 11.0-inch 2G")
    __typePair(@"iPad8,10", @"iPad Pro 11.0-inch 2G")

    __typePair(@"iPad6,7", @"iPad Pro 12.9-inch")
    __typePair(@"iPad6,8", @"iPad Pro 12.9-inch")
    __typePair(@"iPad7,1", @"iPad Pro 12.9-inch 2G")
    __typePair(@"iPad7,2", @"iPad Pro 12.9-inch 2G")
    __typePair(@"iPad8,5", @"iPad Pro 12.9-inch 3G")
    __typePair(@"iPad8,6", @"iPad Pro 12.9-inch 3G")
    __typePair(@"iPad8,7", @"iPad Pro 12.9-inch 3G")
    __typePair(@"iPad8,8", @"iPad Pro 12.9-inch 3G")
    __typePair(@"iPad8,11", @"iPad Pro 12.9-inch 4G")
    __typePair(@"iPad8,12", @"iPad Pro 12.9-inch 4G")
    
    return nil;
}

+ (NSString *)__ipadMiniAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"iPad2,5", @"iPad Mini")
    __typePair(@"iPad2,6", @"iPad Mini")
    __typePair(@"iPad2,7", @"iPad Mini")
    __typePair(@"iPad4,4", @"iPad Mini 2G")
    __typePair(@"iPad4,5", @"iPad Mini 2G")
    __typePair(@"iPad4,6", @"iPad Mini 2G")
    
    __typePair(@"iPad4,7", @"iPad mini 3G")
    __typePair(@"iPad4,8", @"iPad mini 3G")
    __typePair(@"iPad4,9", @"iPad mini 3G")
    __typePair(@"iPad5,1", @"iPad mini 4G")
    __typePair(@"iPad5,2", @"iPad mini 4G")
    __typePair(@"iPad11,1", @"iPad mini 5G")
    __typePair(@"iPad11,2", @"iPad mini 5G")
        
    return nil;
}

+ (NSString *)__simulatorAnnounceTypeWithPreciseType:(NSString *)preciseType {
    
    __typePair(@"i386", @"iPhone Simulator")
    __typePair(@"x86_64", @"iPhone Simulator")

    return nil;
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
