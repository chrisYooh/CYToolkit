//
//  CLLocation+CYCategory.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import "CLLocation+CYCategory.h"

@implementation CLLocation (CYCategory)

+ (CYLocation *)cyLocation {
    return [CYLocation cySharedLocation];
}

+ (void)cyLocationUpdate {
    [CYLocation cySharedLocationUpdate];
}

+ (double)cyLongitudeStringWithLocationInfo:(CLLocation *)location {
    
    CLLocationCoordinate2D tmpCoordinate = location.coordinate;
    return tmpCoordinate.longitude;
}

+ (double)cyLatitudeStringWithLocationInfo:(CLLocation *)location {
    
    CLLocationCoordinate2D tmpCoordinate = location.coordinate;
    return tmpCoordinate.latitude;
}

@end
