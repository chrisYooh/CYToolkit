//
//  CAAnimation+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAAnimation (CYCategory)

#pragma mark  基础动画

/* 渐变动画 */
+ (CAAnimation *)cyFadeTransitionWithDuration:(float)duration;

/* 位置动画 */
+ (CAAnimation *)cyMoveAnimationWithDuration:(float)duration
                                  startPoint:(CGPoint)startPoint
                                    endPoint:(CGPoint)endPoint;

/* 透明度动画 */
+ (CAAnimation *)cyAlphaAnimationWithDuration:(float)duration
                                    baseAlpha:(float)baseAlpha
                                  targetAlpha:(float)targetAlpha;

/* 比例动画（大小变化） */
+ (CAAnimation *)cyScaleAnimationWithDuration:(float)duration
                                    baseScale:(float)baseScale
                                  targetScale:(float)targetScale;

/* 旋转动画 */
+ (CAAnimation *)cyRotateAnimationWithDuration:(float)duration
                                     baseAngle:(float)baseAngle
                                   targetAngle:(float)targetAngle;

/* Gif转动画
 * Tip：直接用UIWebView播放gif不方便控制gif的【播放次数】及【图片范围】 */
+ (CAAnimation *)cyGifAnimationWithGifData:(NSData *)gifData duration:(float)duration;

/* 动画暂停 & 继续 */
+ (void)cyPauseAnimationWithLayer:(CALayer *)inputLayer;
+ (void)cyResumeAnimationWithLayer:(CALayer *)inputLayer;

/* 设置动画基本配置
 * 1、 结束自动移除
 * 2、 重复次数为1
 */
- (void)setBaseConfig;

#pragma mark  高级动画

/* 闪烁动画 */
+ (CAAnimation *)cyPlaneTwinkleAnimationWithDuration:(float)duration;

/* 抖动动画 - 直线 */
+ (CAAnimation *)cyLineShakeAnimationWithDuration:(float)duration
                                       fromCenter:(CGPoint)sCenter
                                         toCenter:(CGPoint)dCenter;
/* 抖动动画 - 平面
 * scope : 抖动最大幅度，单位：像素 */
+ (CAAnimation *)cyPlaneShakeAnimationWithDuration:(float)duration
                                       shakeCenter:(CGPoint)shakeCenter
                                             scope:(float)scope;

/* 弹性动画（膨胀收缩） */
+ (CAAnimation *)cyExpandShrinkAnimationWithDuration:(float)duration;

@end

NS_ASSUME_NONNULL_END
