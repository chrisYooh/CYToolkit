//
//  UIColor+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CYRandColor(inputAlpha)     [UIColor cyRandomColorWithAlpha:inputAlpha]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CYCategory)

+ (UIColor *)cyRandomColor;
+ (UIColor *)cyRandomColorWithAlpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
