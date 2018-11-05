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

/* 必须遵照NSCoding协议 */
- (BOOL)cySaveForKey:(NSString *)objKey;
+ (id)cyLoadObjForKey:(NSString *)objKey;

@end

NS_ASSUME_NONNULL_END
