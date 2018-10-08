//
//  NSDecimalNumber+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "NSDecimalNumber+CYCategory.h"

@implementation NSDecimalNumber (CYCategory)

#pragma mark - Base Operation

#pragma mark Decimal op Decimal

- (NSDecimalNumber *)cyAdd:(NSDecimalNumber *)inputNum {
    
    if (NO == cyDecimalIsValid(self)) {
        return cyDecimalInitVal;
    }
    
    if (NO == cyDecimalIsValid(inputNum)) {
        return self;
    }
    
    return [self decimalNumberByAdding:inputNum];
}

- (NSDecimalNumber *)cySub:(NSDecimalNumber *)inputNum {
    
    if (NO == cyDecimalIsValid(self)) {
        return cyDecimalInitVal;
    }
    
    if (NO == cyDecimalIsValid(inputNum)) {
        return self;
    }
    
    return [self decimalNumberBySubtracting:inputNum];
}

- (NSDecimalNumber *)cyMul:(NSDecimalNumber *)inputNum {
    
    if (NO == cyDecimalIsValid(self)) {
        return cyDecimalInitVal;
    }
    
    if (NO == cyDecimalIsValid(inputNum)) {
        return self;
    }
    
    return [self decimalNumberByMultiplyingBy:inputNum];
}

- (NSDecimalNumber *)cyDiv:(NSDecimalNumber *)inputNum {
    
    if (NO == cyDecimalIsValid(self)) {
        return cyDecimalInitVal;
    }
    
    if (NO == cyDecimalIsValid(inputNum)
        || 0 == inputNum.doubleValue) {
        return self;
    }
    
    return [self decimalNumberByDividingBy:inputNum];
}

#pragma mark Decimal op NSString

- (NSDecimalNumber *)cyAddStr:(NSString *)inputStr {
    return [self cyAdd:[NSDecimalNumber cyDecimalNumberFromNSString:inputStr]];
}

- (NSDecimalNumber *)cySubStr:(NSString *)inputStr {
    return [self cySub:[NSDecimalNumber cyDecimalNumberFromNSString:inputStr]];
}

- (NSDecimalNumber *)cyMulStr:(NSString *)inputStr {
    return [self cyMul:[NSDecimalNumber cyDecimalNumberFromNSString:inputStr]];
}

- (NSDecimalNumber *)cyDivStr:(NSString *)inputStr {
    return [self cyDiv:[NSDecimalNumber cyDecimalNumberFromNSString:inputStr]];
}

#pragma mark Decimal op NSNumber

- (NSDecimalNumber *)cyAddNum:(NSNumber *)inputNum {
    return [self cyAdd:[NSDecimalNumber cyDecimalNumberFromNumber:inputNum]];
}

- (NSDecimalNumber *)cySubNum:(NSNumber *)inputNum {
    return [self cySub:[NSDecimalNumber cyDecimalNumberFromNumber:inputNum]];
}

- (NSDecimalNumber *)cyMulNum:(NSNumber *)inputNum {
    return [self cyMul:[NSDecimalNumber cyDecimalNumberFromNumber:inputNum]];
}

- (NSDecimalNumber *)cyDivNum:(NSNumber *)inputNum {
    return [self cyDiv:[NSDecimalNumber cyDecimalNumberFromNumber:inputNum]];
}

#pragma mark - Base Formatter */

- (NSDecimalNumber *)cyRoundingValWithScale:(NSInteger)scale {
    
    NSDecimalNumber *tmpNum = cyDecimalValidVal(self);
    NSDecimalNumberHandler *numberHandler =
    [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                           scale:scale
                                                raiseOnExactness:NO
                                                 raiseOnOverflow:NO
                                                raiseOnUnderflow:NO
                                             raiseOnDivideByZero:YES];
    
    tmpNum = [tmpNum decimalNumberByRoundingAccordingToBehavior:numberHandler];
    return tmpNum;
}

#pragma mark - Safe Decimal Construction

+ (NSDecimalNumber *)cyDecimalNumberFromNSString:(NSString *)str {
    
    NSDecimalNumber *tmpNum = [NSDecimalNumber decimalNumberWithString:str];
    
    return cyDecimalValidVal(tmpNum);
}

+ (NSDecimalNumber *)cyDecimalNumberFromNumber:(NSNumber *)num {
    
    NSDecimal tmpDecimal = [num decimalValue];
    NSDecimalNumber *tmpNum = [NSDecimalNumber decimalNumberWithDecimal:tmpDecimal];
    
    return cyDecimalValidVal(tmpNum);
}

@end
