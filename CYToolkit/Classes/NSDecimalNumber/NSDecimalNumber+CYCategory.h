//
//  NSDecimalNumber+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Compare */
#define cyDecimalMin(num1, num2)    (([num1 doubleValue] < [num2 doubleValue]) ? num1 : num2)
#define cyDecimalMax(num1, num2)    (([num1 doubleValue] > [num2 doubleValue]) ? num1 : num2)

/* 完整性支持 (初始值/nan值判定/有效值判定/有效值转化)*/
#define cyDecimalInitVal                [NSDecimalNumber decimalNumberWithString:@"0"]
#define cyDecimalIsNaN(decimalNum)      isnan(decimalNum.doubleValue)
#define cyDecimalIsValid(decimalNum)    (((nil == decimalNum) || cyDecimalIsNaN(decimalNum)) ? NO : YES)
#define cyDecimalValidVal(decimalNum)   ((YES == cyDecimalIsValid(decimalNum)) ? decimalNum : cyDecimalInitVal)

NS_ASSUME_NONNULL_BEGIN

@interface NSDecimalNumber (CYCategory)

/*
 * 1. 简化DecimalNumber的操作接口
 * 2. 针对操作值进行异常默认处理
 *  2.1 运算符左值错误：不进行操作，直接返回默认值（0）
 *  2.2 运算符右值错误：不进行操作，直接返回左值
 *  2.3 运算符右值(除数0)：不进行操作，直接返回左值
 * 3. self值不进行改变，需要通过赋值改变
 */
- (NSDecimalNumber *)cyAdd:(NSDecimalNumber *)inputNum;
- (NSDecimalNumber *)cySub:(NSDecimalNumber *)inputNum;
- (NSDecimalNumber *)cyMul:(NSDecimalNumber *)inputNum;
- (NSDecimalNumber *)cyDiv:(NSDecimalNumber *)inputNum;

/* Decimal(self)与String的快捷安全运算 */
- (NSDecimalNumber *)cyAddStr:(NSString *)inputStr;
- (NSDecimalNumber *)cySubStr:(NSString *)inputStr;
- (NSDecimalNumber *)cyMulStr:(NSString *)inputStr;
- (NSDecimalNumber *)cyDivStr:(NSString *)inputStr;

/* Decimal(self)与NSNumber的快捷安全运算 */
- (NSDecimalNumber *)cyAddNum:(NSNumber *)inputNum;
- (NSDecimalNumber *)cySubNum:(NSNumber *)inputNum;
- (NSDecimalNumber *)cyMulNum:(NSNumber *)inputNum;
- (NSDecimalNumber *)cyDivNum:(NSNumber *)inputNum;

/** 精度保留
 * 1. 保留输入的小数位数的精度(非规格化)
 */
- (NSDecimalNumber *)cyRoundingValWithScale:(NSInteger)scale;

/* DecimalNumber的安全转化：
 * 1. 保证输出值为可操作的值
 */
+ (NSDecimalNumber *)cyDecimalNumberFromNSString:(NSString *)str;
+ (NSDecimalNumber *)cyDecimalNumberFromNumber:(NSNumber *)num;

@end

NS_ASSUME_NONNULL_END
