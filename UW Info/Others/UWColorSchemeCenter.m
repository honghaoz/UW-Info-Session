//
//  UWColorSchemeCenter.m
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWColorSchemeCenter.h"

@implementation UWColorSchemeCenter

#define UW_BLACK [UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1]
#define UW_GOLD [UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]//[UIColor colorWithRed:0.44 green:0.84 blue:0.97 alpha:1]
#define TAB_BAR_COLOR [UIColor blackColor]

+ (instancetype)sharedCenter
{
    static UWColorSchemeCenter *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UWColorSchemeCenter alloc] init];
    });
    return _sharedClient;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notificationName = @"UpdateColorScheme";
        _uwGoldColor = [UIColor brownColor];//[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0];
        _uwBlackColor = [UIColor greenColor];//[UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1];
        _tabBarTintColor = TAB_BAR_COLOR;//[UIColor blackColor];
    }
    return self;
}

+ (UIColor *)uwGold {
    return [UWColorSchemeCenter sharedCenter].uwGoldColor;
}

+ (UIColor *)uwBlack {
    return [UWColorSchemeCenter sharedCenter].uwBlackColor;
}

+ (UIColor *)uwTabBarColor {
    return [UWColorSchemeCenter sharedCenter].tabBarTintColor;
}

+ (void)setGoldColor:(UIColor *)gold {
    [[UWColorSchemeCenter sharedCenter] setGoldColor:gold];
}

- (void)setGoldColor:(UIColor *)gold {
    _uwGoldColor = gold;
}

+ (void)setBlackColor:(UIColor *)black {
    [[UWColorSchemeCenter sharedCenter] setBlackColor:black];
}

- (void)setBlackColor:(UIColor *)black {
    _uwBlackColor = black;
}

+ (void)setTabBarColor:(UIColor *)tabBarColor {
    [[UWColorSchemeCenter sharedCenter] setTabBarColor:tabBarColor];
}

- (void)setTabBarColor:(UIColor *)tabBarColor {
    _tabBarTintColor = tabBarColor;
}

+ (void)updateColorScheme {
    [[UWColorSchemeCenter sharedCenter] updateColorScheme];
}

- (void)updateColorScheme {
    _uwGoldColor = [UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0];
    _uwBlackColor = [UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1];
    _tabBarTintColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self userInfo:nil];
}

+ (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector {
    [[UWColorSchemeCenter sharedCenter] registerColorSchemeNotificationForObserver:observer selector:selector];
}

- (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:_notificationName object:self];
}

@end
