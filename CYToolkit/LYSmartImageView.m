//
//  LYSmartImageView.m
//  BigImageView
//
//  Created by mac on 15/7/1.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "CYCompatible.h"
#import "CYDefinitions.h"

#import "LYSmartImageView.h"

static const float glassViewOpacity = 0.8;
static const float appearDisappearDuration = 0.2;
static const float scaleChangeDuration = 0.2;
static const float maxScaleMinValue = 2.0f;

@interface LYSmartImageView()
<UIScrollViewDelegate>

@property (nonatomic, retain) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *doubleTapGesture;

@end

@implementation LYSmartImageView

- (id)init
{
    self = [super init];
    
    if (self) {
        
        [self selfConfig];
        
        [self allocSubviews];
        [self configSubviews];
        [self positionSubviews];
    }
    
    return self;
}

- (void)selfConfig
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect tmpRect = [UIScreen mainScreen].bounds;
    
    [self setFrame:tmpRect];
}

- (void)allocSubviews
{
    _glassView = [[UIView alloc] init];
    _scrollView = [[UIScrollView alloc] init];
    _imageView = [[UIImageView alloc] init];
}

- (void)configSubviews
{
    [_glassView setBackgroundColor:[UIColor blackColor]];
    [_glassView setAlpha:glassViewOpacity];

    [_scrollView setDelegate:self];
    [_scrollView setMinimumZoomScale:1];

    /* Double touches */
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleClicked:)];
    [_doubleTapGesture setNumberOfTapsRequired:2];
    
    /* Single touches */
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleClicked:)];
    [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
    
    [_scrollView addGestureRecognizer:_singleTapGesture];
    [_scrollView addGestureRecognizer:_doubleTapGesture];

    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setClipsToBounds:YES];
    
    [self addSubview:_glassView];
    [self addSubview:_scrollView];
    [_scrollView addSubview:_imageView];
}

- (void)positionSubviews
{
    CGRect tmpRect = CGRectZero;
    
    /* Glass View */
    tmpRect = self.bounds;
    [_glassView setFrame:tmpRect];
    
    /* Scroll View */
    tmpRect = self.bounds;
    [_scrollView setFrame:tmpRect];
    
    /* Image View */
    [_imageView setCenter:_scrollView.center];
}

+ (LYSmartImageView *)showSmartImageViewWithImage:(UIImage *)image
                                       appearRect:(CGRect)appearRect
                                      onSuperView:(UIView *)superView
{
    LYSmartImageView *newView = [[LYSmartImageView alloc] init];
    
    /* Config */
    [newView configWithImage:image];
    newView.appearRect = appearRect;
    [superView addSubview:newView];
    
    /* Appear animations */
    [newView viewAppear];
    
    return newView;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//[_imageView setCenter:_scrollView.center];
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    _imageView.center = CGPointMake(xcenter, ycenter);
}

#pragma mark - Touch
- (void)scrollViewSingleClicked:(UITapGestureRecognizer *)tapGesture
{
     [self viewDisappear];
}

- (void)scrollViewDoubleClicked:(UITapGestureRecognizer *)tapGesture
{
    float threScale = _scrollView.minimumZoomScale;
    float animationDuration = scaleChangeDuration;
    
    cyWeakSelf(weakSelf);
    if (_scrollView.zoomScale <= threScale) {
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.scrollView.zoomScale = weakSelf.scrollView.maximumZoomScale;
        }];
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.scrollView.zoomScale = weakSelf.scrollView.minimumZoomScale;
        }];
    }
}

#pragma mark - Image related config
- (void)configWithImage:(UIImage *)image
{
    /* Set image */
    [self.imageView setImage:image];
    
    /* Layout Image */
    [self calcImageDisplaySizeWithImage:image];
    [self.imageView setCenter:_scrollView.center];
    [self.imageView setBounds:CGRectMake(0, 0, _imageDisplaySize.width, _imageDisplaySize.height)];
    
    /* Scroll View zoom scale */
    [_scrollView setMaximumZoomScale:[self imageScaleMaxWithDisplaySize:_imageDisplaySize]];
}

- (void)calcImageDisplaySizeWithImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float widthRatio = screenSize.width / imageSize.width;
    float heightRatio = screenSize.height / imageSize.height;
    
    if (widthRatio < heightRatio) {
        _imageDisplaySize = CGSizeMake(CYDefScreenWidth, imageSize.height * widthRatio);
    } else {
        _imageDisplaySize = CGSizeMake(imageSize.width * heightRatio, CYDefScreenHeight);
    }
}

- (float)imageScaleMaxWithDisplaySize:(CGSize)displaySize
{
    float scale = maxScaleMinValue;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float heightRatio = screenSize.height / displaySize.height;
    float widthRatio = screenSize.width / displaySize.width;
    
    scale = MAX(scale, heightRatio);
    scale = MAX(scale, widthRatio);
    
    return scale;
}

#pragma mark - Animations
- (void)viewAppear
{
    [self glassViewAppear];
    [self imageViewAppear];
}

- (void)viewDisappear
{
    [self glassViewDisappear];
    [self imageViewDisappear];
}

#pragma mark GlassView
- (void)glassViewAppear
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:glassViewOpacity];
    animation.duration = appearDisappearDuration;

    [_glassView.layer addAnimation:animation forKey:nil];
}

- (void)glassViewDisappear
{
    cyWeakSelf(weakSelf);
    [UIView animateWithDuration:appearDisappearDuration animations:^{
        [weakSelf.glassView setAlpha:0];
    }];
}

#pragma mark ImageView
- (void)imageViewAppear
{
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, _appearRect.size.width, _appearRect.size.height)];
    boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, _imageDisplaySize.width, _imageDisplaySize.height)];
    boundsAnimation.duration = appearDisappearDuration;
    
    CABasicAnimation *centerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    centerAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(_appearRect.origin.x + _appearRect.size.width / 2, _appearRect.origin.y + _appearRect.size.height / 2)];
    centerAnimation.toValue = [NSValue valueWithCGPoint:_scrollView.center];
    centerAnimation.duration = appearDisappearDuration;
    
    [_imageView.layer addAnimation:centerAnimation forKey:nil];
    [_imageView.layer addAnimation:boundsAnimation forKey:nil];
}

- (void)imageViewDisappear
{
    cyWeakSelf(weakSelf);
    [UIView animateWithDuration:appearDisappearDuration animations:^{
        [weakSelf.imageView setFrame:weakSelf.appearRect];
    } completion:^(BOOL finished) {
        
        [weakSelf.scrollView removeGestureRecognizer:weakSelf.singleTapGesture];
        [weakSelf.scrollView removeGestureRecognizer:weakSelf.doubleTapGesture];
        weakSelf.singleTapGesture = nil;
        weakSelf.doubleTapGesture = nil;
        
        [weakSelf removeFromSuperview];
    }];
}

@end
