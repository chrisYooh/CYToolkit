//
//  CYKeychain.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYKeychain : NSObject

+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)loadObjectForKey:(NSString *)key;
+ (void)deleteObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
