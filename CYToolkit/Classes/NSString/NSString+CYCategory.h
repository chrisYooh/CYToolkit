//
//  NSString+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Regex */
#define cyRegexStrPassword      @"[0-9a-zA-Z_]{6,16}"                   /* 限制数字字母下划线，长度6--16位 */
#define cyRangeStrIdentify      @"^(\\d{14}|\\d{17})(\\d|[xX])$"        /* 身份证简易校验 */
#define cyRegexStrMobildNum     @"^1\\d{10}"                            /* 手机号简易校验，1开头，11位 */
#define cyRegexStrBankCard      @"[0-9]{16,19}"                         /* 银行卡简易校验，纯数字，16--19位 */
#define cyRegexStrNumberOnly    @"[0-9]*"                               /* 纯数字 */
#define cyRegexStrAmount        @"[1-9]\\d{0,7}(\\.\\d{0,2})?"          /* 金额数字限制，整数最多8位、小数最多2位、不能是0开头、只有一个小数点*/

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CYCategory)

#pragma mark 字符串检查

- (BOOL)cyMatchRegexStr:(NSString *)regexStr;   /* 串类型检查（基础） */

#pragma mark - 简单转化

- (NSString *)cyNoSpaceString;      /* 清除空格 */
/*
 将表情符号替换成指定字符串
 */
- (NSString *)cyStringByReplacingEmojiWithString:(NSString *)string;

/*
 pragma mark - 每隔unit个字符，加一个空格
 */
- (NSString *)cyAddSpaceWithUnit:(NSUInteger)unit;

#pragma mark - 数字串规格化

/* 【默认】如: 12334.34
 * 1. 展示2位小数
 * 注：number输入支持NSDecimalNumber，并可以保持其精度
 */
+ (NSString *)cyDefaultValueStringWithNumber:(NSNumber *)number;
+ (NSString *)cyDefaultValueStringWithValueString:(NSString *)valueStr;

/* 【标准1】如: 12,342.42
 * 1. 展示2位小数
 * 2. 每3位添加一个逗号分隔符
 * 注：number输入支持NSDecimalNumber，并可以保持其精度
 */
+ (NSString *)cyStdSeperateValueStringWithNumber:(NSNumber *)number;
+ (NSString *)cyStdSeperateValueStringWithValueString:(NSString *)valueStr;

/* 【标准2】如: 12,342
 * 1.没有小数部分
 * 2.每3位添加一个逗号分隔符
 */
+ (NSString *)cyStdSeperateValueStringWithoutDecimalWithNumber:(NSNumber *)number;
+ (NSString *)cyStdSeperateValueStringWithoutDecimalWithValueString:(NSString *)valueStr;


/* 【人民币】如: 12,342.42元
 * 1. 展示2位小数
 * 2. 每3位添加一个逗号分隔符
 * 3. 末尾加上单位"元"
 * 注：number输入支持NSDecimalNumber，并可以保持其精度
 */
+ (NSString *)cyRmbValueStringWithNumber:(NSNumber *)number;

/* 【百分比】如：37.62%
 * 1. 展示2位小数
 * 2. 末尾加上单位百分号("%")
 * 注：number输入支持NSDecimalNumber，并可以保持其精度
 */
+ (NSString *)cyPercentStringWithNumber:(NSNumber *)number;

/* 【百分比范围】如：37.62%~45.33%
 * 1. 单个百分比展示2位小数
 * 2. 单个末尾加上单位百分号("%")
 * 3. max为空或min >= max时，只展示Min
 * 4. min < max时展示x.xx%~y.yy%
 * 注：number输入支持NSDecimalNumber，并可以保持其精度
 */
+ (NSString *)cyPercentStringWithMinNumber:(NSNumber *)minNum maxNumber:(NSNumber *)maxNum;

#pragma mark - 其他

/* 安全手机号
 * 1. 从第四个数字起，中间4位使用*代替
 * 2. 小于11位的数字串不进行处理
 */
+ (NSString *)cySafePhoneNumberStringWithString:(NSString *)numberStr;

/* 安全身份证号
 * 1. 从第7个数字其，中间8位使用*代替
 * 2. 小于14位的数字串不进行处理
 */
+ (NSString *)cySafeIdNumberStringWithString:(NSString *)idNumberStr;

/* 自定义行间距串
 * 1. 可自由设置字符串的行间距
 */
+ (NSAttributedString *)cyLineSpaceStringWithString:(NSString *)inputStr
                                          lineSpace:(float)lineSpace;


/**
 * 目录遍历
 * 返回目录内文件名
 */
- (NSArray<NSString *> *)cyDirFileNames;

/**
 * 目录遍历
 * 返回目录内文件绝对路径
 */
- (NSArray<NSString *> *)cyDirFilePaths;

/* 查看文件大小
 * 字符串本身为文件路径 */
- (NSString *)cyFileSize;

/* 常用路径 */
+ (NSString *)cyMainBundlePath;
+ (NSString *)cyDocumentsPath;
+ (NSString *)cyCachesPath;
+ (NSString *)cyAppSupportPath;
+ (NSString *)cyTemporaryPath;
+ (NSString *)cyHomePath;

/**
 * 以字符串为输入创建类对象
 */
- (id)cyCreateInstance;

@end

NS_ASSUME_NONNULL_END
