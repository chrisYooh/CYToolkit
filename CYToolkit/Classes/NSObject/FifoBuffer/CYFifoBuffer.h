//
//  CYFifoBuffer.h
//  CYToolkit
//
//  Created by Chris Yang on 2020/3/25.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/* 一个先进先出的缓存队列（不考虑线程安全）
 */
@interface CYFifoBuffer : NSObject

@property (nonatomic, assign) NSInteger bufferSize;         /* 缓冲区大小 */

+ (CYFifoBuffer *)sharedBuffer;                             /* 全局缓存对象，亦可单独创建缓存对象 */

#pragma mark - 增
- (void)pushObject:(id)object forKey:(NSString *)objKey;    /* 缓存对象 */

#pragma mark - 删
- (void)clearBuffer;                                        /* 清空缓存 */

#pragma mark - 改
- (void)refreshObject:(id)object;                           /* 刷新对象，置为队尾，找不到对象则什么也不做 */
- (void)refreshKey:(id)objKey;                              /* 刷新对象，置为队尾，找不到对象则什么也不做 */

#pragma mark - 查
- (NSInteger)curCachedNumber;                               /* 当前缓存对象数量 */
- (id)objectForKey:(NSString *)objKey;                      /* 获取对象，并将对象置为最新 */
- (NSArray<id> *)curObjects;                                /* 按添加顺序排列的当前所有缓存对象 */

@end

NS_ASSUME_NONNULL_END
