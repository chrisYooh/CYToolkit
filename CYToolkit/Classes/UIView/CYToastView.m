//
//  CYToastView.m
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYToastView.h"

#define __defaultSize   CGSizeMake(140, 33.5)

@interface CYToastView()
<CAAnimationDelegate>
@end

@implementation CYToastView

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self selfConfig];
        
        [self allocSubviews];
        [self configSubviews];
        [self positionSubviews];
    }
    
    return self;
}

- (void)selfConfig {
    
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.layer setCornerRadius:5];
    [self clipsToBounds];
    
    CGRect tmpRect = CGRectZero;
    tmpRect.size = __defaultSize;
    [self setFrame:tmpRect];
}

- (void)allocSubviews {
    _infoLabel = [[UILabel alloc] init];
}

- (void)configSubviews {
    [_infoLabel setTextColor:[UIColor whiteColor]];
    [_infoLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self addSubview:_infoLabel];
}

- (void)positionSubviews {
    
    [_infoLabel sizeToFit];
    
    /* View Bounds */
    if (_infoLabel.frame.size.width > 100) {
        
        CGRect tmpRect = self.bounds;
        tmpRect.size.width = _infoLabel.frame.size.width + 40;
        [self setBounds:tmpRect];
    }
    
    /* Note position */
    CGPoint tmpCenter = CGPointZero;
    tmpCenter.x = self.bounds.size.width / 2;
    tmpCenter.y = self.bounds.size.height / 2;
    
    [_infoLabel setCenter:tmpCenter];
}

#pragma mark - User interface

+ (CYToastView *)showToast:(NSString *)toast
              onParentView:(UIView *)parentView
                  duration:(NSTimeInterval)duration {
    
    CYToastView *newNode = [[CYToastView alloc] init];
    
    NSLog(@"Parent Center : %@", NSStringFromCGPoint(parentView.center));
    
    [newNode.infoLabel setText:toast];
    [newNode setCenter:parentView.center];
    [newNode setAlpha:0];
    [parentView addSubview:newNode];
    
    [newNode positionSubviews];
    [newNode.layer addAnimation:[newNode appearAndDisappearWithDuration:duration] forKey:nil];
    
    return newNode;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self removeFromSuperview];
}

- (CAKeyframeAnimation *)appearAndDisappearWithDuration:(NSTimeInterval)duration
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    NSArray *valueArray = @[
                            [NSNumber numberWithFloat:0],
                            [NSNumber numberWithFloat:1],
                            [NSNumber numberWithFloat:1],
                            [NSNumber numberWithFloat:0],
                            ];
    [animation setValues:valueArray];
    
    NSArray *keyTimeArray = @[
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.2],
                              [NSNumber numberWithFloat:0.8],
                              [NSNumber numberWithFloat:1.0],
                              ];
    [animation setKeyTimes:keyTimeArray];
    
    [animation setDuration:duration];
    [animation setDelegate:self];
    [animation setRemovedOnCompletion:YES];
    
    return animation;
}

@end
