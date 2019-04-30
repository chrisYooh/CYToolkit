//
//  NSString+CYTTS.m
//  CYToolkit
//
//  Created by Chris on 2019/4/30.
//  Copyright © 2019 杨一凡. All rights reserved.
//

#import "CYTTS.h"

#import "NSString+CYTTS.h"

@implementation NSString (CYTTS)

- (void)cySpeak {
    if (self.length <= 0) {
        return;
    }
    [[CYTTS sharedInstance] speak:self];
}

@end
