//
//  CYKeychain.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYKeychain.h"

@implementation CYKeychain

#pragma mark - MISC

+ (NSDictionary *)baseQueryDicFromObjectKey:(NSString *)objKey {
    
    NSDictionary *tmpDic = @{
                             (id)kSecClass:(id)kSecClassGenericPassword,
                             (id)kSecAttrService:objKey,
                             (id)kSecAttrAccount:objKey,
                             (id)kSecAttrAccessible:(id)kSecAttrAccessibleAfterFirstUnlock,
                             };
    return tmpDic;
}

#pragma mark - User Interface

+ (void)saveObject:(id)object forKey:(NSString *)key {
    
    /* 1. Delete Old Item */
    NSDictionary *baseQueryDic = [self baseQueryDicFromObjectKey:key];
    SecItemDelete((CFDictionaryRef)baseQueryDic);
    
    /* 2. Add New Item */
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:baseQueryDic];
    
    NSData *objData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [dataDic setObject:objData forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)dataDic, NULL);
}

+ (id)loadObjectForKey:(NSString *)key {
    
    /* 1. Query Setting */
    NSDictionary *baseQueryDic = [self baseQueryDicFromObjectKey:key];
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionaryWithDictionary:baseQueryDic];
    [queryDic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [queryDic setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    /* 2. Query */
    id retObj = nil;
    CFDataRef objData = NULL;
    OSStatus retStatus = SecItemCopyMatching((CFDictionaryRef)queryDic, (CFTypeRef *)&objData);
    if (noErr == retStatus) {
        retObj = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)objData];
    }
    
    if (objData) {
        CFRelease(objData);
    }
    
    return retObj;
}

+ (void)deleteObjectForKey:(NSString *)key {
    
    NSDictionary *baseQueryDic = [self baseQueryDicFromObjectKey:key];
    SecItemDelete((CFDictionaryRef)baseQueryDic);
}

@end
