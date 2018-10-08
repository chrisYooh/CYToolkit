//
//  UIFont+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CYFont(fontSize)        [UIFont cyDefaultFontWithSize:fontSize]

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (CYCategory)

#pragma mark - Base

/* Setting */
+ (void)cySetDefaultFontName:(NSString *)fontName;

/* Font Creater */
+ (UIFont *)cyDefaultFontWithSize:(CGFloat)fontSize;
+ (UIFont *)cyFontWithName:(NSString *)fontName size:(CGFloat)fontSize;
+ (UIFont *)cyFontWithFontAttributes:(NSDictionary<NSString *, id> *)attributes;//根据attributes生成字体

+ (UIFont *)cyMediumFontWithSize:(CGFloat)fontSize;//默认字体，字重500
+ (UIFont *)cyHelveticaFontWithSize:(CGFloat)fontSize;//Helvetica字体 字重400
+ (UIFont *)cyFontWithFamily:(NSString *)family Name:(NSString *)fontName size:(CGFloat)fontSize weight:(CGFloat)weightSize;

/* 字体遍历 */
+ (void)cyTraversalFontWithFontFamilyCallback:(void(^)(NSString *fontFamily))fontFamilyCallback
                             fontNameCallback:(void(^)(NSString *fontName))fontNameCallback;

/* 新字体添加说明 */
/* 1. 于Info.plist中添加【Fonts provided by application】字段，并设定对应的Item值为ttf文件名称
 * 2. 通过[字体遍历接口]找到对应的FontFamily或FontName即可使用了
 */

#pragma mark  字形适配手机

/* FontSize: 大屏手机标准字号
 * reduct: 小屏手机字号缩小幅度, 为负表示增大字号
 * fontName: 字体名称，如输入则为默认字体
 */
+ (UIFont *)cyAdaptiveFontWithBaseSize:(CGFloat)baseSize
                                reduce:(CGFloat)reduce;
+ (UIFont *)cyAdaptiveFontWithFontName:(NSString *)fontName
                              baseSize:(CGFloat)baseSize
                                reduce:(CGFloat)reduce;
@end

NS_ASSUME_NONNULL_END
