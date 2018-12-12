//
//  CYToastView.h
//  CYToolkit
//
//  Created by Chris on 2018/12/12.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYToastView : UIView

@property (nonatomic, retain) UILabel *infoLabel;;

+ (CYToastView *)showToast:(NSString *)toast
              onParentView:(UIView *)parentView
                  duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
