//
//  NSObject+CYMethodSwizzling.h
//  CYToolkit
//
//  Created by Chris Yang on 2020/11/3.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CYMethodSwizzling)

/* 替换实例方法 */
+ (void)cySwizzlingInstanceMethodWithOriginalSel:(SEL)orignalSel swizzledSel:(SEL)swizzledSel;

/* 替换类方法 */
+ (void)cySwizzlingClassMethodWithOriginalSel:(SEL)orignalSel swizzledSel:(SEL)swizzledSel;

/* 替换对应的实例方法，在方法调用前打印对应的调用信息。 */
+ (void)cyInstanceDebugHook:(SEL)tarSel;

@end

NS_ASSUME_NONNULL_END
