//
//  LYSmartImageView.h
//  BigImageView
//
//  Created by mac on 15/7/1.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSmartImageView : UIView

@property (nonatomic) CGRect appearRect;
@property (nonatomic) CGSize imageDisplaySize;

@property (nonatomic, retain) UIView *glassView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;

+ (LYSmartImageView *)showSmartImageViewWithImage:(UIImage *)image
                                       appearRect:(CGRect)appearRect
                                      onSuperView:(UIView *)superView;

@end
