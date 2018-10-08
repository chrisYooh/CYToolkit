//
//  NSDate+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (CYCategory)

/* 字符串 转 时间
 * 格式支持
 * yyyy-MM-dd
 * HH:mm:ss
 * yyyy-MM-dd HH:mm:ss
 * 时间戳
 */
+ (NSDate *)cyDateFromDateStr:(NSString *)dateStr;

/* 规格化字符串 */
- (NSString *)cyDateString;
- (NSString *)cyTimeString;
- (NSString *)cyDateTimeString;
- (NSString *)cyStringWithFormatStr:(NSString *)formatStr;

@end

NS_ASSUME_NONNULL_END
