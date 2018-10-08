//
//  CYLocation.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYLocation : NSObject

+ (CYLocation *)cySharedLocation;

/* 每次调用只更新一次地理位置信息 */
+ (void)cySharedLocationUpdate;

@end

NS_ASSUME_NONNULL_END
