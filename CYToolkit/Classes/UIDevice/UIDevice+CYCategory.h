//
//  UIDevice+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (CYCategory)

+ (NSString *)cyOSVersionString;        /* 系统版本 */
+ (NSString *)cyPhoneTypeString;        /* 手机型号 */
+ (NSString *)cyDeviceTokenString;      /* 设备标签（IDFA/类IDFA） */
+ (NSString *)cyIspInfoString;          /* 运营商信息 */
+ (NSString *)cyNetTypeString;          /* 网络类型，如：4G */
+ (NSString *)cyInnerIpString;          /* 内网IP */

@end

NS_ASSUME_NONNULL_END
