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
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, strong) NSString *notificationName;

+ (instancetype)sharedCenter;
+ (UIColor *)uwGold;
+ (UIColor *)uwBlack;
+ (UIColor *)uwTabBarColor;
+ (UIStatusBarStyle) statusBarStyle;

+ (void)setGoldColor:(UIColor *)gold;
+ (void)setBlackColor:(UIColor *)black;
+ (void)setTabBarColor:(UIColor *)tabBarColor;
+ (void)setStatusStyle:(UIStatusBarStyle)statusStyle;
+ (void)updateColorScheme;
+ (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector;

@end
