//
//  NSObject+CYMethodSwizzling.m
//  CYToolkit
//
//  Created by Chris Yang on 2020/11/3.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSObject+CYMethodSwizzling.h"

static NSString *const __selPrefix = @"cy_";
static NSString *const __fwdInvocationSelName = @"__cy_forwardInvocation:";

static inline SEL __aliasSel(SEL inputSel) {
    return NSSelectorFromString([__selPrefix stringByAppendingString:NSStringFromSelector(inputSel)]);
}

static void __cy_fwdInvocation_imp_(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    
    SEL originalSelector = invocation.selector;
    SEL aliasSelector = __aliasSel(originalSelector);
    Class klass = object_getClass(invocation.target);

    BOOL isHooked = [klass instancesRespondToSelector:aliasSelector];
    
    /* 执行 hook 逻辑 */
    if (isHooked) {
        NSLog(@"%@ %@ called",
              NSStringFromClass([self class]),
              NSStringFromSelector(originalSelector));
        invocation.selector = aliasSelector;
        [invocation invoke];
    }
    
    /* 没有进行方法Hook，执行原逻辑 */
    else {
        SEL originalForwardInvocationSEL = NSSelectorFromString(__fwdInvocationSelName);
        if ([self respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSEL, invocation);
        } else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }
}

@implementation NSObject (CYMethodSwizzling)

+ (void)cySwizzlingInstanceMethodWithOriginalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel {
    
    Class class = [self class];
    
    SEL originalSelector = originalSel;
    SEL swizzledSelector = swizzledSel;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)cySwizzlingClassMethodWithOriginalSel:(SEL)originalSel swizzledSel:(SEL)swizzledSel {
    
    Class class = [self class];
    
    SEL originalSelector = originalSel;
    SEL swizzledSelector = swizzledSel;
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

#pragma mark -

+ (void)cyInstanceDebugHook:(SEL)tarSel {
    NSLog(@"注意！！！该方法仅做调试用，未考虑过多边界条件！！！请勿在正式代码中调用！！！");
    [self __replaceSelToMsgForward:tarSel];
    [self __replaceMsgForward];
}

#pragma mark -

+ (void)__replaceSelToMsgForward:(SEL)tarSel {
    Class klass = [self class];
    SEL selector = tarSel;
    SEL aliasSelector = __aliasSel(selector);
    
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);

    class_addMethod(klass, aliasSelector, targetMethodIMP, typeEncoding);
    class_replaceMethod(klass, selector, _objc_msgForward, typeEncoding);
}

+ (void)__replaceMsgForward {
    Class klass = [self class];
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__cy_fwdInvocation_imp_, "v@:@");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(__fwdInvocationSelName), originalImplementation, "v@:@");
    }
}


@end
