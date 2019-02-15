//
//  NSObject+CYCategory.h
//  CYToolkit
//
//  Created by Chris on 2018/11/5.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CYCategory)

#pragma mark - Instance Save & Load

/* 缓存/读取 类，必须遵照NSCoding协议 */
- (BOOL)cySaveForKey:(NSString *)objKey;
+ (id)cyLoadObjForKey:(NSString *)objKey;

/* 通过aDecoder 读取/存储 某个类的缓存信息
 * 注：aDecoder要和对应的类一致 */
- (void)cyReadAllAttrWithDecoder:(NSCoder *)aDecoder;
- (void)cySaveAllAttrWithCoder:(NSCoder *)aCoder;

#pragma mark - String runtime

/* 以字符串为输入执行方法 */
- (id)cyPerformSelStr:(NSString *)selecterStr;
- (id)cyPerformSelStr:(NSString *)selecterStr withObject:(id)object;

@end

NS_ASSUME_NONNULL_END
