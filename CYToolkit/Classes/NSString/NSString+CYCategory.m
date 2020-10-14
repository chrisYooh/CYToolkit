//
//  NSString+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDecimalNumber+CYCategory.h"

#import "NSString+CYCategory.h"

#define __defaultRoundingScale      2

@implementation NSString (CYCategory)

- (BOOL)cyMatchRegexStr:(NSString *)regexStr {
    
    if (0 == regexStr.length) {
        /* 表示任何条件都通过 */
        return YES;
    }
    
    NSPredicate *tmpPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexStr];
    return [tmpPred evaluateWithObject:self];
}

#pragma mark - 简单转化

- (NSString *)cyNoSpaceString {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)cyStringByReplacingEmojiWithString:(NSString *)string{
    
    NSString *outString=[self copy];
    NSRange range;
    NSMutableSet *emojiSet = [NSMutableSet set];
    
    //找出emoji
    for (NSInteger i = 0; i < self.length; i += range.length) {
        
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *codeString = [self substringWithRange:range];
        
        NSMutableString *hexString = [NSMutableString string];
        for (int i = 0; i < codeString.length; ++i) {
            
            [hexString appendFormat:@"%02x", [codeString characterAtIndex:i]];
        }
        
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        UInt64 code = 0x00;
        [scanner scanHexLongLong: &code];
        if (![self cyIsNotEmoji:code]) {
            
            [emojiSet addObject:codeString];
        }
    }
    
    //替换emoji
    for (NSString* emojiString in emojiSet) {
        
        outString = [outString stringByReplacingOccurrencesOfString:emojiString withString:string];
    }
    return outString;
}

- (BOOL)cyIsNotEmoji:(UInt64) codePoint {
    
    return (codePoint == 0x0)
    || (codePoint == 0x9)
    || (codePoint == 0xA)
    || (codePoint == 0xD)
    || ((codePoint >= 0x20) && (codePoint <= 0xD7FF))
    || ((codePoint >= 0xFF00) && (codePoint <= 0xFFFF));
}

#pragma mark - 每隔unit个字符，加一个空格
- (NSString *)cyAddSpaceWithUnit:(NSUInteger)unit{
    NSString *separatedByString=[NSString stringWithString:self];
    if (separatedByString.length < unit) {
        return separatedByString;
    }
    
    NSUInteger counts = [separatedByString length] / unit;
    NSUInteger remainderCounts = [separatedByString length] % unit;
    
    NSMutableArray *unitStrArray = [NSMutableArray array ];
    
    for (NSInteger i = 0 ; i < counts; i++) {
        [unitStrArray addObject:[separatedByString substringWithRange:NSMakeRange(i * unit, unit)]];
    }
    
    if (remainderCounts > 0) {
        [unitStrArray addObject:[separatedByString substringWithRange:NSMakeRange(counts * unit, remainderCounts)]];
    }
    
    return [unitStrArray componentsJoinedByString:@" "];
}

#pragma mark - 默认数字串

+ (NSString *)cyDefaultValueStringWithNumber:(NSNumber *)number {
    
    NSDecimalNumber *tmpNum = [NSDecimalNumber cyDecimalNumberFromNumber:number];
    return [self _defaultValueStringWithDecimalNumber:tmpNum];
}

+ (NSString *)cyDefaultValueStringWithValueString:(NSString *)valueStr {
    
    NSDecimalNumber *tmpNum = [NSDecimalNumber cyDecimalNumberFromNSString:valueStr];
    return [self _defaultValueStringWithDecimalNumber:tmpNum];
}

+ (NSString *)_defaultValueStringWithDecimalNumber:(NSDecimalNumber *)decimalNumber {
    
    NSDecimalNumber *tmpNum = [decimalNumber cyRoundingValWithScale:__defaultRoundingScale];
    NSString *tmpStr = [tmpNum stringValue];
    return [self zeroDecimalStringWithString:tmpStr withDecimalNumber:__defaultRoundingScale];
}

#pragma mark - 标准数字串

+ (NSString *)cyStdSeperateValueStringWithNumber:(NSNumber *)number {
    
    NSDecimalNumber *tmpNum = [NSDecimalNumber cyDecimalNumberFromNumber:number];
    return [self cyStdSeperateValueStringWithValueString:tmpNum.stringValue];
}

+ (NSString *)cyStdSeperateValueStringWithValueString:(NSString *)valueStr {
    
    valueStr = (0 == [valueStr doubleValue]) ? @"0" : valueStr;
    
    /* 高精度保留小数处理 */
    NSDecimalNumber *tmpDecimal = [NSDecimalNumber cyDecimalNumberFromNSString:valueStr];
    tmpDecimal = [tmpDecimal cyRoundingValWithScale:__defaultRoundingScale];
    valueStr = tmpDecimal.stringValue;
    
    NSArray *strArray = [valueStr componentsSeparatedByString:@"."];
    NSString *stdString = valueStr;
    if (1 == strArray.count) {
        
        stdString = [self addStdCommaToString:strArray[0]];
        
    } else if (2 == strArray.count) {
        
        stdString = [NSString stringWithFormat:@"%@.%@", [self addStdCommaToString:strArray[0]], strArray[1]];
    }
    
    stdString = [self zeroDecimalStringWithString:stdString withDecimalNumber:__defaultRoundingScale];
    return stdString;
}

+ (NSString *)cyStdSeperateValueStringWithoutDecimalWithNumber:(NSNumber *)number{
    return [self cyStdSeperateValueStringWithoutDecimalWithValueString:number.stringValue];
}

+ (NSString *)cyStdSeperateValueStringWithoutDecimalWithValueString:(NSString *)valueStr{
    NSMutableString *stdString = [valueStr mutableCopy];
    NSRange range=[stdString rangeOfString:@"."];
    if (range.location != NSNotFound) {
        NSRange deleteRange=NSMakeRange(range.location, stdString.length-range.location);
        [stdString deleteCharactersInRange:deleteRange];
    }
    return [[self addStdCommaToString:stdString] copy];
}


/* 整数部分每三位添加分隔符. */
+ (NSString *)addStdCommaToString:(NSString *)valStr
{
    valStr = [NSString stringWithFormat:@"%ld", (long)[valStr integerValue]];
    
    NSMutableString *tmpMutStr = [NSMutableString stringWithString:valStr];
    NSInteger strLength = valStr.length;
    NSInteger componLength = 3;
    
    for (int i = 1; i <= (int)((strLength - 1) / componLength); i++) {
        NSInteger tmpIndex = strLength - (i * componLength);
        [tmpMutStr insertString:@"," atIndex:tmpIndex];
    }
    
    return [NSString stringWithString:tmpMutStr];
}

/* 针对整数进行小输点补0处理 */
+ (NSString *)zeroDecimalStringWithString:(NSString *)inputStr withDecimalNumber:(NSInteger)decimalNumber {
    
    /* Add Zero */
    NSString *tmpStr = @"";
    NSArray *strArray = [inputStr componentsSeparatedByString:@"."];
    if (1 >= strArray.count && 0 != decimalNumber) {
        inputStr = [inputStr stringByAppendingString:@"."];
    } else {
        tmpStr = strArray[1];
    }
    
    for (int i = (int)tmpStr.length; i < decimalNumber; i++) {
        inputStr = [inputStr stringByAppendingString:@"0"];
    }
    
    return inputStr;
}

#pragma mark - 人民币

+ (NSString *)cyRmbValueStringWithNumber:(NSNumber *)number {
    
    NSString *valStr = [self cyStdSeperateValueStringWithNumber:number];
    NSString *tmpStr = [NSString stringWithFormat:@"%@元", valStr];
    return tmpStr;
}

#pragma mark - 百分比

+ (NSString *)cyPercentStringWithNumber:(NSNumber *)number {
    
    NSString *valStr = [self cyDefaultValueStringWithNumber:number];
    NSString *tmpStr = [NSString stringWithFormat:@"%@%%", valStr];
    return tmpStr;
}

+ (NSString *)cyPercentStringWithMinNumber:(NSNumber *)minNum maxNumber:(NSNumber *)maxNum {
    
    NSString *tmpStr = @"";
    
    if (nil == maxNum || minNum.doubleValue >= maxNum.doubleValue) {
        tmpStr = [NSString stringWithFormat:@"%@", [self cyPercentStringWithNumber:minNum]];
    } else {
        tmpStr = [NSString stringWithFormat:@"%@~%@",
                  [self cyPercentStringWithNumber:minNum],
                  [self cyPercentStringWithNumber:maxNum]];
    }
    
    return tmpStr;
}

#pragma mark - 功能（拷贝粘贴）

- (void)cyCopy {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self;
}

- (void)cyBundleCopy {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = [infoDic objectForKey:@"CFBundleIdentifier"];
    UIPasteboard * myPasteboard = [UIPasteboard pasteboardWithName:bundleId create:YES];
    myPasteboard.string = self;
}

+ (NSString *)cyCopyedStr {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    return pasteboard.string;
}

+ (NSString *)cyBundleCopyedStr {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = [infoDic objectForKey:@"CFBundleIdentifier"];
    UIPasteboard * myPasteboard = [UIPasteboard pasteboardWithName:bundleId create:NO];
    return myPasteboard.string;
}

#pragma mark - 安全手机号

+ (NSString *)cySafePhoneNumberStringWithString:(NSString *)numberStr {
    
    if (numberStr.length < 11) {
        return numberStr;
    }
    
    NSString *tmpStr = [numberStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    return tmpStr;
}

+ (NSString *)cySafeIdNumberStringWithString:(NSString *)idNumberStr {
    
    if (idNumberStr.length < 14) {
        return idNumberStr;
    }
    
    NSString *tmpStr = [idNumberStr stringByReplacingCharactersInRange:NSMakeRange(6, 8) withString:@"********"];
    return tmpStr;
}

#pragma mark - 自定义行间距字符串

+ (NSAttributedString *)cyLineSpaceStringWithString:(NSString *)inputStr
                                          lineSpace:(float)lineSpace {
    
    NSString *fixStr = [inputStr length] ? inputStr : @"";
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:fixStr];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [fixStr length])];
    
    return attributedString;
}

#pragma mark - 目录操作

- (NSArray<NSString *> *)cyDirFileNames {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:self];
    NSMutableArray *tmpMulArray = [[NSMutableArray alloc] init];
    NSString *tmpFileName;
    while ((tmpFileName = [dirEnum nextObject]) != nil) {
        [tmpMulArray addObject:tmpFileName];
    }
    return tmpMulArray.copy;
}

- (NSArray<NSString *> *)cyDirFilePaths {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:self];
    NSMutableArray *tmpMulArray = [[NSMutableArray alloc] init];
    NSString *tmpFileName = nil;
    while ((tmpFileName = [dirEnum nextObject]) != nil) {
        [tmpMulArray addObject:[self stringByAppendingPathComponent:tmpFileName]];
    }
    return tmpMulArray.copy;
}

- (NSString *)cyFileSize {
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:self]) {
        return nil;
    }
    
    NSDictionary *dicAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil];
    float fileSize = [[dicAttr objectForKey:@"NSFileSize"] floatValue];
    
    NSString *fileSizeStr = nil;
    if (fileSize < 100) {
        fileSizeStr = [NSString stringWithFormat:@"%.0f B", fileSize];
    } else if (fileSize < 100 * 1024) {
        fileSizeStr = [NSString stringWithFormat:@"%.2f KB", fileSize / 1024];
    } else if (fileSize < 100 * 1024 * 1024) {
        fileSizeStr = [NSString stringWithFormat:@"%.2f MB", fileSize / (1024 * 1024)];
    } else if (fileSize < 100.0 * 1024 * 1024 * 1024) {
        fileSizeStr = [NSString stringWithFormat:@"%.2f GB", fileSize / (1024 * 1024 * 1024)];
    } else if (fileSize < 100.0 * 1024 * 1024 * 1024 * 1024) {
        fileSizeStr = [NSString stringWithFormat:@"%.2f TB", fileSize / (1024 * 1024 * 1024 * 1024)];
    }
    
    return fileSizeStr;
}

- (void)cyVideoSaveToAlbum {
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:self]) {
        NSLog(@"目标文件不存在");
        return;
    }
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSURL *fileUrl = [NSURL fileURLWithPath:self];
    
    if (NO == [assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:fileUrl]) {
        NSLog(@"该文件无法被写入相册");
    }
    
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum: fileUrl
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          if (error) {
                                              NSLog(@"Save to album failed, ERROR：%@", error.localizedDescription);
                                          } else {
                                              NSLog(@"Save to album succeed!");
                                          }
                                      }];
#pragma clang diagnostic pop
    
}

+ (NSString *)cyMainBundlePath {
    NSString *tmpPath = [[NSBundle mainBundle] bundlePath];
    return tmpPath;
}

+ (NSString *)cyDocumentsPath {
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return tmpPath;
}

+ (NSString *)cyCachesPath {
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return tmpPath;
}

+ (NSString *)cyAppSupportPath {
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    return tmpPath;
}

+ (NSString *)cyTemporaryPath {
    NSString *tmpPath = NSTemporaryDirectory();
    return tmpPath;
}

+ (NSString *)cyHomePath {
    NSString *tmpPath = NSHomeDirectory();
    return tmpPath;
}

- (id)cyCreateInstance {
    Class strClass = NSClassFromString(self);
    id tmpObj = [[strClass alloc] init];
    return tmpObj;
}

@end
