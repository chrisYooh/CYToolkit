//
//  CYLocation.m
//  CYToolkit
//
//  Created by 杨一凡 on 2018/10/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "CYLocation.h"

#define __isIos8Later         (NSOrderedDescending == [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch])

@interface CYLocation ()
<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CYLocation

- (id)init {
    
    self = [super init];
    
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        
        if (YES == __isIos8Later) {
            /* 8.0 Later */
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    return self;
}

+ (CYLocation *)cySharedInstance {
    
    static CYLocation *sharedLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocation = [[CYLocation alloc] init];
    });
    
    return sharedLocation;
}

+ (CLLocation *)cySharedLocation {
    return [self cySharedInstance].locationManager.location;
}

+ (void)cySharedLocationUpdate {
    [[self cySharedInstance].locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

@end
