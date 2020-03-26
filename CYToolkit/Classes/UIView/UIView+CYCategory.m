//
//  UIView+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <objc/runtime.h>
#import "CYToastView.h"

#import "UIView+CYCategory.h"

static char cyActionHandlerTapBlockKey;
static char cyActionHandlerTapGestureKey;
static char cykActionHandlerLongPressBlockKey;
static char cykActionHandlerLongPressGestureKey;

@implementation UIView (CYCategory)

#pragma mark xib扩展

- (void)setCyBorderColor:(UIColor *)cyBorderColor{
    self.layer.borderColor = cyBorderColor.CGColor;
}

- (UIColor *)cyBorderColor{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setCyBorderWidth:(CGFloat)cyBorderWidth{
    self.layer.borderWidth = cyBorderWidth;
}

- (CGFloat)cyBorderWidth{
    return self.layer.borderWidth;
}

- (void)setCyCornerRadius:(CGFloat)cyCornerRadius{
    self.layer.cornerRadius = cyCornerRadius;
}

- (CGFloat)cyCornerRadius{
    return self.layer.cornerRadius;
}

- (void)setCyMasksToBounds:(BOOL)cyMasksToBounds{
    self.layer.masksToBounds = cyMasksToBounds;
}

- (BOOL)cyMasksToBounds{
    return self.layer.masksToBounds;
}


//设置阴影
- (void)setCyShadowColor:(UIColor *)cyShadowColor{
    self.layer.shadowColor = cyShadowColor.CGColor;
}

- (UIColor *)cyShadowColor{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setCyShadowOffset:(CGSize)cyShadowOffset{
    self.layer.shadowOffset = cyShadowOffset;
}

- (CGSize)cyShadowOffset{
    return self.layer.shadowOffset;
}

- (void)setCyShadowOpacity:(CGFloat)cyShadowOpacity{
    self.layer.shadowOpacity = cyShadowOpacity;
}

- (CGFloat)cyShadowOpacity{
    return self.layer.shadowOpacity;
}

- (void)setCyShadowRadius:(CGFloat)cyShadowRadius{
    self.layer.shadowRadius = cyShadowRadius;
}

- (CGFloat)cyShadowRadius{
    return self.layer.shadowRadius;
}

#pragma mark block类型手势

- (void)cyAddTapActionWithBlock:(CYGestureActionBlock)block{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &cyActionHandlerTapGestureKey);
    if (!gesture){
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &cyActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &cyActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}
- (void)handleActionForTapGesture:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized){
        CYGestureActionBlock block = objc_getAssociatedObject(self, &cyActionHandlerTapBlockKey);
        if (block){
            block(gesture);
        }
    }
}

- (void)cyAddLongPressActionWithBlock:(CYGestureActionBlock)block{
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &cykActionHandlerLongPressGestureKey);
    if (!gesture){
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &cykActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &cykActionHandlerLongPressBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForLongPressGesture:(UITapGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized){
        CYGestureActionBlock block = objc_getAssociatedObject(self, &cykActionHandlerLongPressBlockKey);
        if (block){
            block(gesture);
        }
    }
}

- (void)cyShowToast:(NSString *)toast {
    [self cyShowToast:toast duration:3];
}

- (void)cyShowToast:(NSString *)toast duration:(NSTimeInterval)duration {
    [CYToastView showToast:toast onParentView:self duration:duration];
}

+ (void)cyShowToast:(NSString *)toast {
    [self cyShowToast:toast duration:3];
}

+ (void)cyShowToast:(NSString *)toast duration:(NSTimeInterval)duration {
    [CYToastView showToast:toast onParentView:[UIApplication sharedApplication].delegate.window duration:duration];
}

#pragma mark - 动画过度

- (void)cySetAlphaHidden:(BOOL)aHidden {
    self.alpha = !aHidden;
    [self.layer addAnimation:[self __fadeTransitionWithDuration:0.3] forKey:nil];
}

- (void)cyFadeTrans {
    [self.layer addAnimation:[self __fadeTransitionWithDuration:0.3] forKey:nil];
}

- (CAAnimation *)__fadeTransitionWithDuration:(float)duration {
    
    CATransition *animation = [[CATransition alloc] init];
    [animation setRemovedOnCompletion:YES];
    [animation setRepeatCount:1];
    
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    
    return animation;
}

@end
