//
//  NSDate+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "NSDate+CYCategory.h"

static NSString * const _dateFormatStr = @"yyyy-MM-dd";
static NSString * const _timeFormatStr = @"HH:mm:ss";
static NSString * const _dateTimeFormatStr = @"yyyy-MM-dd HH:mm:ss";
static NSString * const _timeStampFormatStr = @"timeStamp";

@implementation NSDate (CYCategory)

#pragma mark - Constructor

+ (NSDate *)cyDateFromDateStr:(NSString *)dateStr {
    
    NSDate *tmpDate = nil;
    
    tmpDate = [self _cyDateWithDate:tmpDate dateStr:dateStr formatStr:_dateTimeFormatStr];
    tmpDate = [self _cyDateWithDate:tmpDate dateStr:dateStr formatStr:_dateFormatStr];
    tmpDate = [self _cyDateWithDate:tmpDate dateStr:dateStr formatStr:_timeFormatStr];
    tmpDate = [self _cyDateWithDate:tmpDate dateStr:dateStr formatStr:_timeStampFormatStr];
    
    return tmpDate;
}

#pragma mark - Format

- (NSString *)cyDateString {
    return [[self class] _cyDateStringFromDate:self formatStr:_dateFormatStr];
}

- (NSString *)cyTimeString {
    return [[self class] _cyDateStringFromDate:self formatStr:_timeFormatStr];
}

- (NSString *)cyDateTimeString {
    return [[self class] _cyDateStringFromDate:self formatStr:_dateTimeFormatStr];
}

- (NSString *)cyStringWithFormatStr:(NSString *)formatStr {
    return [[self class] _cyDateStringFromDate:self formatStr:formatStr];
}

#pragma mark - MISC

+ (BOOL)validedDate:(NSDate *)date {
    
    if (0 != [date timeIntervalSince1970]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)_cyDateStringFromDate:(NSDate *)date formatStr:(NSString *)fromatStr {
    
    if (nil == date) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    NSDateFormatter *tmpFormatter = [[NSDateFormatter alloc] init];
    [tmpFormatter setDateFormat:fromatStr];
    
    return [tmpFormatter stringFromDate:date];
}

+ (NSDate *)_cyDateWithDate:(NSDate *)date dateStr:(NSString *)dateStr formatStr:(NSString *)formatStr {
    
    if (YES == [self validedDate:date]) {
        return date;
    }
    
    NSDate *tmpDate = nil;
    if ([_timeStampFormatStr isEqualToString:formatStr]) {
        /* 时间戳 */
        tmpDate = [NSDate dateWithTimeIntervalSince1970:[dateStr longLongValue]];
    } else {
        /* 字符串规格化 */
        NSDateFormatter *tmpFormatter = [[NSDateFormatter alloc] init];
        [tmpFormatter setDateFormat:formatStr];
        tmpDate = [tmpFormatter dateFromString:dateStr];
    }
    
    return tmpDate;
}
@end
