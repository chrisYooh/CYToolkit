//
//  UIImageView+CYCategory.h
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (CYCategory)

/* 预览图片 */
- (void)cyPreviewImage;

/* 打开预览能力：即点击预览大图 */
- (void)cyOpenPreviewPower;

@end

NS_ASSUME_NONNULL_END
