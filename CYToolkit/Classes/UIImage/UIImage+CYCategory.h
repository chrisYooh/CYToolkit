//
//  UIImage+CYCategory.h
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CYCategory)

/**
 * 图片方向矫正
 * 将ImageOrientation非Up的转化为Up的图像
 */
- (UIImage *)cyUpOrientationImage;

@end

NS_ASSUME_NONNULL_END
