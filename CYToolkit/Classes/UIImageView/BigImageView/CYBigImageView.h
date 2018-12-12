//
//  CYBigImageView.h
//  CYToolkit
//
//  Created by Chris on 2018/12/11.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYBigImageView : UIView

@property (nonatomic, retain) UIView *glassView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;

/**
 * 将一张图片放大展示
 * image : 需要展示的图片
 * appearRect : 图片 开始展示起始位置 & 结束展示目标位置 动画的Rect
 * imageView : 通过imageView自行提取 image & appearRect
 */
+ (CYBigImageView *)previewImage:(UIImage *)image;
+ (CYBigImageView *)previewImage:(UIImage *)image appearRect:(CGRect)appearRect;
+ (CYBigImageView *)previewImageWithImageView:(UIImageView *)imageView;

@end

NS_ASSUME_NONNULL_END
