//
//  UWColorSchemeCenter.h
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWColorSchemeCenter : NSObject

@property (nonatomic, strong) UIColor *uwGoldColor;
@property (nonatomic, strong) UIColor *uwBlackColor;
@property (nonatomic, strong) UIColor *tabBarTintColor;

@property (nonatomic, strong) NSString *notificationName;

+ (instancetype)sharedCenter;
+ (UIColor *)uwGold;
+ (UIColor *)uwBlack;
+ (UIColor *)uwTabBarColor;

+ (void)updateColorScheme;
+ (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector;

@end
