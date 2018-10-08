//
//  CYIdfa.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYIdfa : NSObject

+ (BOOL)cyCanGetSysIdfa;        /* 是否可以获得系统idfa */
+ (NSString *)cySysIdfa;        /* 系统idfa */
+ (NSString *)cySimulateIDFA;   /* 模拟idfa */

@end

NS_ASSUME_NONNULL_END
