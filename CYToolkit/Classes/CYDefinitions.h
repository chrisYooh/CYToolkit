//
//  CYDefinitions.h
//  CYToolkit
//
//  Created by Chris on 2018/11/8.
//  Copyright © 2018 杨一凡. All rights reserved.
//

#ifndef CYDefinitions_h
#define CYDefinitions_h

/* 状态栏高度 */
#define CYDefStatusBarHeight      ([[UIApplication sharedApplication] statusBarFrame].size.height)

/* 导航栏高度 */
#define CYDefNavHeight            (44)

/* 顶部高度（状态栏 + 导航栏高度） */
#define CYDefTopHeight            (CYDefStatusBarHeight + CYDefNavHeight)

/* Tab高度 */
#define CYDefTabHeight            (CYDefIsIphoneX ? 83 : 49)

/* 是否有效URl */
#define CYDefIsEmptyUrl(inputUrl)  (NO == [inputUrl isKindOfClass:[NSURL class]])

/* 是否iPhoneX */
#define CYDefIsIphoneX \
([UIScreen mainScreen].bounds.size.width == 375 \
&& [UIScreen mainScreen].bounds.size.height == 812)

/* 屏幕信息 */
#define CYDefScreenBounds     [UIScreen mainScreen].bounds
#define CYDefScreenFrame      [UIScreen mainScreen].frame
#define CYDefScreenWidth      [UIScreen mainScreen].bounds.size.width
#define CYDefScreenHeight     [UIScreen mainScreen].bounds.size.height

#endif /* CYDefinitions_h */
