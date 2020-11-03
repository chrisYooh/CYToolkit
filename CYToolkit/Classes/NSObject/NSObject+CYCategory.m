//
//  NSObject+CYCategory.m
//  CYToolkit
//
//  Created by Chris on 2018/11/5.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <objc/runtime.h>
#import "CYFifoBuffer.h"

#import "NSObject+CYCategory.h"

@implementation NSObject (CYCategory)

#pragma mark - Instance Save & Load

- (BOOL)cySaveForKey:(NSString *)objKey {
    
    if (0 == objKey.length) {
        return NO;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSKeyedArchiver *aCoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
#pragma clang diagnostic pop
    [aCoder encodeObject:self forKey:objKey];
    [aCoder finishEncoding];
    
    NSString *sourcePath = [NSObject cyArchiverPath];
    if (0 == sourcePath.length) {
        //如果根目录没有创建出来，直接返回保存失败
        return false;
    }
    
    NSString *path = [[NSObject cyArchiverPath] stringByAppendingFormat:@"/cy-%@", objKey];
    NSFileManager *fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        BOOL isYes = [fm removeItemAtPath:path error:nil];
        if (isYes) {
            //删除成功创建目录
            return [fm createFileAtPath:path contents:data attributes:nil];
        } else {
            //删除失败直接返回保存失败
            return isYes;
        }
    } else {
        return [fm createFileAtPath:path contents:data attributes:nil];
    }
}

+ (id)cyLoadObjForKey:(NSString *)objKey {
    if (0 == objKey.length) {
        return nil;
    }
    NSString *sourcePath = [self cyArchiverPath];
    if (0 == sourcePath.length) {
        //如果根目录没有创建出来，直接返回nil
        return nil;
    }
    NSString *path = [[self cyArchiverPath] stringByAppendingFormat:@"/cy-%@", objKey];
    //先读出文件
    NSFileManager * fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
        if (nil == fh) {
            //NSFileHandle  没有创建成功直接返回nil
            return nil;
        }
        NSData *data = [fh readDataToEndOfFile];
        if (0 == data.length) {
            return nil;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSKeyedUnarchiver *acoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
#pragma clang diagnostic pop
        //从包中取出数据
        id<NSCoding> info = [acoder decodeObjectForKey:objKey];
        //结束解归档
        [acoder finishDecoding];
        return info;
    }
    return nil;
}

- (void)cyReadAllAttrWithDecoder:(NSCoder *)aDecoder {
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [aDecoder decodeObjectForKey:key];
        if (nil != value) {
            [self setValue:value forKey:key];
        }
    }
    free(ivars);
}

- (void)cySaveAllAttrWithCoder:(NSCoder *)aCoder {
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        if ([value respondsToSelector:@selector(encodeWithCoder:)]) {
            [aCoder encodeObject:value forKey:key];
        }
    }
    free(ivars);
}

#pragma mark -

+ (NSString *)cyArchiverPath{
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/CYArchiver"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = true;
    if (![fm fileExistsAtPath:path isDirectory:&isDir]) {
        BOOL isYes = [fm createDirectoryAtPath:path withIntermediateDirectories:false attributes:nil error:nil];
        if (!isYes) {
            return @"";
        }
    }
    return path;
}

#pragma mark - Instance Cache & Cache Load

- (void)cyCacheSaveForKey:(NSString *)objKey {
    [[CYFifoBuffer sharedBuffer] pushObject:self forKey:objKey];
}

- (id)cyCacheLoadForKey:(NSString *)objKey {
    return [[CYFifoBuffer sharedBuffer] objectForKey:objKey];
}

#pragma mark - String runtime

- (id)cyPerformSelStr:(NSString *)selecterStr {
    
    id retObj = nil;
    
    SEL tmpSel = NSSelectorFromString(selecterStr);
    if ([self respondsToSelector:tmpSel]) {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
        retObj = [self performSelector:tmpSel];
        _Pragma("clang diagnostic pop")
    }
    
    return retObj;
}

- (id)cyPerformSelStr:(NSString *)selecterStr withObject:(nonnull id)object {
    
    id retObj = nil;
    
    SEL tmpSel = NSSelectorFromString(selecterStr);
    if ([self respondsToSelector:tmpSel]) {
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
        retObj = [self performSelector:tmpSel withObject:object];
        _Pragma("clang diagnostic pop")
    }
    
    return retObj;
}

static SEL aspect_aliasForSelector(SEL selector) {
    NSCParameterAssert(selector);
    return NSSelectorFromString([@"cy" stringByAppendingFormat:@"_%@", NSStringFromSelector(selector)]);
}


@end
