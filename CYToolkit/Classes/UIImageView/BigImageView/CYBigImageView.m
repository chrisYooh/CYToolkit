//
//  CYBigImageView.m
//  CYToolkit
//
//  Created by Chris on 2018/12/11.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CYBigImageView.h"

#define __screenWidth       [UIScreen mainScreen].bounds.size.width
#define __screenHeight      [UIScreen mainScreen].bounds.size.height
#define __baseWindow        [UIApplication sharedApplication].delegate.window

static const float glassViewOpacity = 0.8;              /* 背景蒙层透明度 */
static const float appearDisappearDuration = 0.2;       /* 图片出现、消失动画时长 */
static const float scaleChangeDuration = 0.2;           /* 图片双击放大、缩小动画时长 */
static const float maxScaleMinValue = 2.0f;             /* 图片放大、缩小最小比例 */

@interface CYBigImageView()
<UIScrollViewDelegate>

@property (nonatomic, assign) CGRect appearRect;            /* 图片点开时，imageView的Rect */
@property (nonatomic, assign) CGSize imageDisplaySize;      /* 图片展示的默认大小 */

@property (nonatomic, retain) UITapGestureRecognizer *singleTapGesture;     /* 单击结束预览 */
@property (nonatomic, retain) UITapGestureRecognizer *doubleTapGesture;     /* 双击放大缩小 */

@end

@implementation CYBigImageView

- (id)init {
    self = [super init];
    if (self) {
        [self configSelf];
        [self allocSubviews];
        [self configSubviews];
        [self positionSubviews];
    }
    return self;
}

- (void)configSelf {
    [self setBackgroundColor:[UIColor clearColor]];
    CGRect tmpRect = [UIScreen mainScreen].bounds;
    [self setFrame:tmpRect];
}

- (void)allocSubviews {
    _glassView = [[UIView alloc] init];
    _scrollView = [[UIScrollView alloc] init];
    _imageView = [[UIImageView alloc] init];
}

- (void)configSubviews {
    
    /* Glass View */
    [_glassView setBackgroundColor:[UIColor blackColor]];
    [_glassView setAlpha:glassViewOpacity];
    
    /* Scroll View */
    [_scrollView setDelegate:self];
    [_scrollView setMinimumZoomScale:1];
    
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleClicked:)];
    [_doubleTapGesture setNumberOfTapsRequired:2];
    [_scrollView addGestureRecognizer:_doubleTapGesture];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleClicked:)];
    [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
    [_scrollView addGestureRecognizer:_singleTapGesture];
    
    /* Image View */
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setClipsToBounds:YES];
    
    [self addSubview:_glassView];
    [self addSubview:_scrollView];
    [_scrollView addSubview:_imageView];
}

- (void)positionSubviews {
    
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

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat xcenter = scrollView.center.x;
    CGFloat ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width
    ? scrollView.contentSize.width / 2
    : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height
    ? scrollView.contentSize.height / 2
    : ycenter;
    
    _imageView.center = CGPointMake(xcenter, ycenter);
}

#pragma mark - Target-Action Pair

- (void)scrollViewSingleClicked:(UITapGestureRecognizer *)tapGesture {
    [self viewDisappear];
}

- (void)scrollViewDoubleClicked:(UITapGestureRecognizer *)tapGesture {
    
    float threScale = _scrollView.minimumZoomScale;
    float animationDuration = scaleChangeDuration;
    
    __weak CYBigImageView *weakSelf;
    if (_scrollView.zoomScale <= threScale) {
        /* 放大 */
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.scrollView.zoomScale = weakSelf.scrollView.maximumZoomScale;
        }];
        
    } else {
        /* 缩小 */
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.scrollView.zoomScale = weakSelf.scrollView.minimumZoomScale;
        }];
    }
}

#pragma mark - Animations

- (void)viewAppear {
    [self glassViewAppear];
    [self imageViewAppear];
}

- (void)viewDisappear {
    [self glassViewDisappear];
    [self imageViewDisappear];
}

#pragma mark GlassView

- (void)glassViewAppear {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:glassViewOpacity];
    animation.duration = appearDisappearDuration;
    
    [_glassView.layer addAnimation:animation forKey:nil];
}

- (void)glassViewDisappear {
    
    __weak CYBigImageView *weakSelf;
    [UIView animateWithDuration:appearDisappearDuration animations:^{
        [weakSelf.glassView setAlpha:0];
    }];
}

#pragma mark ImageView

- (void)imageViewAppear {
    
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

- (void)imageViewDisappear {
    
    __weak CYBigImageView *weakSelf;
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

#pragma mark - MISC

- (void)configWithImage:(UIImage *)image {
    
    /* Set image */
    [self.imageView setImage:image];
    
    /* Layout Image */
    [self calcImageDisplaySizeWithImage:image];
    [self.imageView setCenter:_scrollView.center];
    [self.imageView setBounds:CGRectMake(0, 0, _imageDisplaySize.width, _imageDisplaySize.height)];
    
    /* Scroll View zoom scale */
    [_scrollView setMaximumZoomScale:[self imageScaleMaxWithDisplaySize:_imageDisplaySize]];
}

- (void)calcImageDisplaySizeWithImage:(UIImage *)image {
    
    CGSize imageSize = image.size;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float widthRatio = screenSize.width / imageSize.width;
    float heightRatio = screenSize.height / imageSize.height;
    
    if (widthRatio < heightRatio) {
        _imageDisplaySize = CGSizeMake(__screenWidth, imageSize.height * widthRatio);
    } else {
        _imageDisplaySize = CGSizeMake(imageSize.width * heightRatio, __screenHeight);
    }
}

- (float)imageScaleMaxWithDisplaySize:(CGSize)displaySize {
    
    float scale = maxScaleMinValue;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float heightRatio = screenSize.height / displaySize.height;
    float widthRatio = screenSize.width / displaySize.width;
    
    scale = MAX(scale, heightRatio);
    scale = MAX(scale, widthRatio);
    
    return scale;
}

#pragma mark - User Interface

+ (CYBigImageView *)previewImage:(UIImage *)image {
    CGRect appearRect = CGRectMake(__screenWidth / 2, __screenHeight / 2, 1, 1);
    CYBigImageView *tmpView = [self previewImage:image appearRect:appearRect];
    return tmpView;
}

+ (CYBigImageView *)previewImage:(UIImage *)image appearRect:(CGRect)appearRect {
    
    if (nil == image) {
        return nil;
    }
    
    CYBigImageView *newView = [[CYBigImageView alloc] init];
    
    /* Config */
    [newView configWithImage:image];
    newView.appearRect = appearRect;
    [__baseWindow addSubview:newView];
    
    /* Appear animations */
    [newView viewAppear];
    
    return newView;
}

+ (CYBigImageView *)previewImageWithImageView:(UIImageView *)imageView {
    
    if (nil == imageView) {
        return nil;
    }
    
    CGRect appearRect = [__baseWindow convertRect:imageView.frame fromView:imageView.superview];
    CYBigImageView *tmpView = [self previewImage:imageView.image appearRect:appearRect];
    return tmpView;
}

@end
