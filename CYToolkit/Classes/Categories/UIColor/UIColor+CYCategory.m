//
//  UIColor+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "UIColor+CYCategory.h"

@implementation UIColor (CYCategory)

#pragma mark - 随机颜色

+ (UIColor *)cyRandomColor {
    return [self cyRandomColorWithAlpha:1];
}

+ (UIColor *)cyRandomColorWithAlpha:(float)alpha {
    return [self _colorWithRGB:(rand() % 0xffffff) alpha:alpha];
}

#pragma mark - MISC

+ (UIColor *)_colorWithRGB:(uint32_t)rgbValue alpha:(float)alpha {
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:alpha];
}
@end
