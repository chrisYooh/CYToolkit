//
//  CLLocation+CYCategory.h
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "CYLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (CYCategory)

/* 当前位置 */
+ (CYLocation *)cyLocation;

/* 位置更新(更新一次) */
+ (void)cyLocationUpdate;

/* 经度 */
+ (double)cyLongitudeStringWithLocationInfo:(CLLocation *)location;

/* 纬度 */
+ (double)cyLatitudeStringWithLocationInfo:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
