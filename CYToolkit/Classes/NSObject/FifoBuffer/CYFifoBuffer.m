//
//  CYFifoBuffer.m
//  CYToolkit
//
//  Created by Chris Yang on 2020/3/25.
//  Copyright © 2020 杨一凡. All rights reserved.
//

#import "CYFifoBuffer.h"

@interface CYFifoBuffer ()

@property (nonatomic, strong) NSMutableArray<NSString *> *fifoKeyArray;             /* 排序队列，存储Key，尾进头出 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *bufferDic;       /* 查找字典 */

@end

@implementation CYFifoBuffer

- (id)init {
    self = [super init];
    if (self) {
        
        _bufferSize = 30;
        
        _fifoKeyArray = [[NSMutableArray alloc] init];
        _bufferDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (CYFifoBuffer *)sharedBuffer {
    
    static CYFifoBuffer *_sharedBuffer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBuffer = [[CYFifoBuffer alloc] init];
    });
    
    return _sharedBuffer;
}

#pragma mark - 增

- (void)pushObject:(id)object forKey:(NSString *)objKey {
    
    if (nil == object || nil == objKey) {
        return;
    }
    
    /* 项满删一个 */
    if (_fifoKeyArray.count >= _bufferSize) {
        NSString *firstKey = _fifoKeyArray.firstObject;
        [_fifoKeyArray removeObject:firstKey];
        [_bufferDic removeObjectForKey:firstKey];
    }
    
    /* 新添加一个 */
    [_fifoKeyArray addObject:objKey];
    [_bufferDic setValue:object forKey:objKey];
}

#pragma mark - 删

- (void)clearBuffer {
    [_fifoKeyArray removeAllObjects];
    [_bufferDic removeAllObjects];
}

#pragma mark - 改
- (void)refreshObject:(id)object {
    NSString *objKey = nil;
    for (NSString *tmpKey in _bufferDic) {
        id tmpObj = _bufferDic[tmpKey];
        if (tmpObj == object) {
            objKey = tmpKey;
            break;
        }
    }
    
    if (nil == objKey) {
        return;
    }
    
    [_fifoKeyArray removeObject:objKey];
    [_fifoKeyArray addObject:objKey];
}

- (void)refreshKey:(id)objKey {
    
    if (NO == [_fifoKeyArray containsObject:objKey]) {
        return;
    }
    
    [_fifoKeyArray removeObject:objKey];
    [_fifoKeyArray addObject:objKey];
}

#pragma mark - 查

- (NSInteger)curCachedNumber {
    return _fifoKeyArray.count;
}

- (id)objectForKey:(NSString *)objKey {
    
    if (nil == objKey) {
        return nil;
    }

    [self refreshKey:objKey];
    id tmpObj = [_bufferDic valueForKey:objKey];

    return tmpObj;
}

- (NSArray<id> *)curObjects {
    
    NSMutableArray *tmpMulArray = [[NSMutableArray alloc] init];
    for (NSString *tmpKey in _fifoKeyArray) {
        id tmpObj = [_bufferDic objectForKey:tmpKey];
        if (nil != tmpObj) {
            [tmpMulArray addObject:tmpObj];
        }
    }
    
    return tmpMulArray.copy;
}

@end
