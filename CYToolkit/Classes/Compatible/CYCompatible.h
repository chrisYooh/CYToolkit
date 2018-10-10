//
//  CYCompatible.h
//  CYToolkit
//
//  Created by Chris on 2018/10/10.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Safe Object */
#define cySafeStr(inputStr)         ((YES == [inputStr isKindOfClass:[NSString class]]) ? inputStr : @"")
#define cySafeArray(inputArray)     ((YES == [inputArray isKindOfClass:[NSArray class]]) ? inputArray : @[])
#define cySafeDic(inputDic)         ((YES == [inputDic isKindOfClass:[NSDictionary class]]) ? inputDic : @{})
#define cySafeDecimal(inputNum)     \
((YES == [inputNum isKindOfClass:[NSDecimalNumber class]]) \
&& (NO == isnan(inputNum.doubleValue))  \
? inputNum \
: [NSDecimalNumber decimalNumberWithString:@"0"])

/* Safe Check */
#define cyIsEmptyStr(inputStr)          (0 == inputStr.length)
#define cyIsEmptyArray(inputArray)      (0 == inputArray.count)
#define cyIsEmptyDic(inputDic)          (0 == inputDic.allKeys.count)
#define cyIsZeroDecimal(inputNum)       (nil == inputNum || isnan(inputNum.doubleValue) || 0 == inputNum.doubleValue)

/* Safe Callback */
#define cySafeCallback(cb, para...) \
do { \
if (nil != cb) { \
cb(para); \
} \
} while(0)

/* Weak Self */
#define cyWeakSelf(weakSelf)    __weak __typeof(&*self) weakSelf = self

@interface NSArray(CYCompatible)

- (id)cyObjectAtIndex:(NSInteger)index;

@end

@interface NSMutableArray(CYCompatible)

- (BOOL)cyAddObject:(id)anObject;

@end

@interface NSMutableDictionary(CYCompatible)

- (BOOL)cySetObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
