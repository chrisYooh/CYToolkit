//
//  UIImageView+CYCategory.m
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYBigImageView.h"

#import "UIImageView+CYCategory.h"

@implementation UIImageView (CYCategory)

- (void)cyPreviewImage {
    [CYBigImageView previewImageWithImageView:self];
}

- (void)cyOpenPreviewPower {
    [self setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cyPreviewImage)];
    [self addGestureRecognizer:tapGesture];
}

@end
