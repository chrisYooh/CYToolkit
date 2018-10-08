//
//  UIFont+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "UIFont+CYCategory.h"

static NSString *_defaultFontName = @"";
#define __isSmallScreenPhone        ([UIScreen mainScreen].bounds.size.width < 330)

@implementation UIFont (CYCategory)

#pragma mark - Base

+ (void)cySetDefaultFontName:(NSString *)fontName {
    _defaultFontName = fontName;
}

+ (UIFont *)cyDefaultFontWithSize:(CGFloat)fontSize {
    return [self cyFontWithName:_defaultFontName size:fontSize];
}

+ (UIFont *)cyFontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    
    UIFont *tmpFont = [UIFont fontWithName:fontName size:fontSize];
    tmpFont = tmpFont ? : [UIFont systemFontOfSize:fontSize];
    return tmpFont;
}

+ (UIFont *)cyFontWithFontAttributes:(NSDictionary *)attributes{
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:attributes];
    return [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
}

+ (UIFont *)cyFontWithFamily:(NSString *)family Name:(NSString *)fontName size:(CGFloat)fontSize weight:(CGFloat)weightSize{
    
    return [self cyFontWithFontAttributes:@{UIFontDescriptorFamilyAttribute:family,
                                            UIFontDescriptorNameAttribute:fontName,
                                            UIFontDescriptorSizeAttribute:[NSNumber numberWithDouble:fontSize],
                                            UIFontWeightTrait:[NSNumber numberWithDouble:weightSize]}];
}

+ (UIFont *)cyMediumFontWithSize:(CGFloat)fontSize{
    
    if (@available(iOS 8.2, *)) {
        return [UIFont cyFontWithFamily:@"PingFangSC" Name:@"PingFangSC-Medium" size:fontSize weight:UIFontWeightMedium];
    } else {
        return [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
    }
}

+ (UIFont *)cyHelveticaFontWithSize:(CGFloat)fontSize{
    
    if (@available(iOS 8.2, *)) {
        return [UIFont cyFontWithFamily:@"Helvetica" Name:@"Helvetica" size:fontSize weight:UIFontWeightRegular];
    } else {
        return [UIFont fontWithName:@"Helvetica" size:fontSize];
    }
}

#pragma mark - 遍历

+ (void)cyTraversalFontWithFontFamilyCallback:(void(^)(NSString *fontFamily))fontFamilyCallback
                             fontNameCallback:(void(^)(NSString *fontName))fontNameCallback {
    
    for (NSString *fontfamilyname in [UIFont familyNames]) {
        
        if (nil != fontFamilyCallback) {
            fontFamilyCallback(fontfamilyname);
        }
        
        for (NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname]) {
            
            if (nil != fontNameCallback) {
                fontNameCallback(fontName);
            }
        }
    }
}

#pragma mark  字形适配手机

+ (UIFont *)cyAdaptiveFontWithBaseSize:(CGFloat)baseSize
                                reduce:(CGFloat)reduce {
    
    return [self cyAdaptiveFontWithFontName:@""
                                   baseSize:baseSize
                                     reduce:reduce];
}

+ (UIFont *)cyAdaptiveFontWithFontName:(NSString *)fontName
                              baseSize:(CGFloat)baseSize
                                reduce:(CGFloat)reduce {
    
    CGFloat reduceSize = baseSize - reduce;
    reduceSize = (reduceSize > 0) ? reduceSize : 0;
    
    UIFont *tmpFont = nil;
    if (YES == __isSmallScreenPhone) {
        tmpFont = [self cyFontWithName:fontName size:reduceSize];
    } else {
        tmpFont = [self cyFontWithName:fontName size:baseSize];
    }
    return tmpFont;
}

@end
