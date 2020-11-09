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
        printf("【CYDebug】%s  --  %s\n",
               NSStringFromSelector(originalSelector).UTF8String,
               NSStringFromClass([self class]).UTF8String
              );
        
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
    [self __cyInstanceDebugHook:tarSel handleSuperClasses:NO];
}

+ (void)cyInstanceInheritDebugHook:(SEL)tarSel {
    [self __cyInstanceDebugHook:tarSel handleSuperClasses:YES];
}

#pragma mark -

+ (void)__cyInstanceDebugHook:(SEL)tarSel handleSuperClasses:(BOOL)handleSuperClasses {
        
    Class currentClass = [self class];
    [self __class:currentClass instanceDebugHook:tarSel];
    
    if (NO == handleSuperClasses) {
        return;
    }
    
    while ((currentClass = class_getSuperclass(currentClass))) {
        [self __class:currentClass instanceDebugHook:tarSel];
    }
}

+ (void)__class:(Class)klass instanceDebugHook:(SEL)tarSel {
    
    if (![klass instancesRespondToSelector:tarSel]) {
        printf("【Hook失败】 %s -- %s 未实现，无法Hook。 \n",
               NSStringFromSelector(tarSel).UTF8String,
               NSStringFromClass([self class]).UTF8String
              );
        return;
    }
    
    [klass __replaceSelToMsgForward:tarSel];
    [klass __replaceMsgForward];
}

+ (void)__replaceSelToMsgForward:(SEL)tarSel {
    Class klass = [self class];
    SEL selector = tarSel;
    SEL aliasSelector = __aliasSel(selector);
    
    if ([self instancesRespondToSelector:aliasSelector]) {
//        printf("【Hook失败】 %s -- %s 已Hook，无需重复Hook。 \n",
//               NSStringFromSelector(tarSel).UTF8String,
//               NSStringFromClass([self class]).UTF8String
//              );
        return;
    }
    
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);

    class_addMethod(klass, aliasSelector, targetMethodIMP, typeEncoding);
    class_replaceMethod(klass, selector, _objc_msgForward, typeEncoding);
}

+ (void)__replaceMsgForward {
    
    Class klass = [self class];
    if ([klass instancesRespondToSelector:NSSelectorFromString(__fwdInvocationSelName)]) {
        /* 方法已经进行了hook，不重复hook */
        return;
    }
    
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__cy_fwdInvocation_imp_, "v@:@");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(__fwdInvocationSelName), originalImplementation, "v@:@");
    }
}


@end
