//
//  NSObject+CYCategory.m
//  CYToolkit
//
//  Created by Chris on 2018/11/5.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "NSObject+CYCategory.h"

@implementation NSObject (CYCategory)

- (BOOL)cySaveForKey:(NSString *)objKey {
    
    if (0 == objKey.length) {
        return NO;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *aCoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
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
        NSKeyedUnarchiver *acoder = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        //从包中取出数据
        id<NSCoding> info = [acoder decodeObjectForKey:objKey];
        //结束解归档
        [acoder finishDecoding];
        return info;
    }
    return nil;
}

#pragma mark - MISC

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

@end
