//
//  CYCompatible.m
//  CYToolkit
//
//  Created by Chris on 2018/10/10.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYCompatible.h"

@implementation NSArray (CYCompatible)

- (id)cyObjectAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.count) {
        return nil;
    }
    
    return self[index];
}

@end

@implementation NSMutableArray(CYCompatible)

- (BOOL)cyAddObject:(id)anObject {
    
    if (nil == anObject) {
        return NO;
    }
    
    [self addObject:anObject];
    return YES;
}

@end

@implementation NSMutableDictionary(CYCompatible)

- (BOOL)cySetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (nil == anObject || nil == aKey) {
        return NO;
    }
    
    [self setObject:anObject forKey:aKey];
    return YES;
}

@end
