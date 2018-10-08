//
//  UIView+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CYGestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CYCategory)

#pragma mark xib扩展

@property (copy  , nonatomic) IBInspectable UIColor *cyBorderColor;  //边框颜色
@property (assign, nonatomic) IBInspectable CGFloat cyBorderWidth;   //边框宽度
@property (assign, nonatomic) IBInspectable CGFloat cyCornerRadius;  //圆角

@property (assign, nonatomic) IBInspectable BOOL cyMasksToBounds;    //超出父图层的部分就截取掉

@property (copy  , nonatomic) IBInspectable UIColor *cyShadowColor;  //阴影颜色
@property (assign, nonatomic) IBInspectable CGSize cyShadowOffset;    //阴影偏移
@property (assign, nonatomic) IBInspectable CGFloat cyShadowOpacity;   //阴影透明度
@property (assign, nonatomic) IBInspectable CGFloat cyShadowRadius;    //阴影半径

#pragma mark block类型手势

/**
 *  @brief  添加tap手势
 *
 *  @param block 代码块
 */
- (void)cyAddTapActionWithBlock:(CYGestureActionBlock)block;

/**
 *  @brief  添加长按手势
 *
 *  @param block 代码块
 */
- (void)cyAddLongPressActionWithBlock:(CYGestureActionBlock)block;

@end

NS_ASSUME_NONNULL_END
