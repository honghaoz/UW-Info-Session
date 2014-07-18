//
//  UWColorSchemeCenter.m
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWColorSchemeCenter.h"
#import <Parse/Parse.h>

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
//        _uwGoldColor = UW_GOLD;
//        _uwBlackColor = UW_BLACK;
//        _tabBarTintColor = TAB_BAR_COLOR;
//        _statusBarStyle = UIStatusBarStyleDefault;
        [self readColorScheme];
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

+ (UIStatusBarStyle) statusBarStyle {
    return [UWColorSchemeCenter sharedCenter].statusBarStyle;
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

+ (void)setStatusStyle:(UIStatusBarStyle)statusStyle {
    [[UWColorSchemeCenter sharedCenter] setStatusStyle:statusStyle];
}

- (void)setStatusStyle:(UIStatusBarStyle)statusStyle {
    _statusBarStyle = statusStyle;
}

+ (void)updateColorScheme {
    [[UWColorSchemeCenter sharedCenter] updateColorScheme];
}

- (void)updateColorScheme {
    [PFCloud callFunctionInBackground:@"getColorScheme"
                       withParameters:@{}
                                block:^(NSDictionary *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                        NSLog(@"%@", result);
                                        [self setColorsWithResult:result];
                                        [self post];
                                    } else {
                                        NSLog(@"getColorScheme failed %@", [error description]);
                                    }
                                }];
//    _uwGoldColor = UW_GOLD;
//    _uwBlackColor = UW_BLACK;
//    _tabBarTintColor = TAB_BAR_COLOR;
}

- (void)setColorsWithResult:(NSDictionary *)result {
    NSDictionary *gold = result[@"uwGoldColor"];
    NSDictionary *black = result[@"uwBlackColor"];
    NSDictionary *tabBarColor = result[@"uwTabColor"];
    if ([result[@"statusBarIsLight"] boolValue]) {
        NSLog(@"light");
        _statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        NSLog(@"dark");
        _statusBarStyle = UIStatusBarStyleDefault;
    }
    _uwGoldColor = [UIColor colorWithRed:[gold[@"red"] floatValue]
                                   green:[gold[@"green"] floatValue]
                                    blue:[gold[@"blue"] floatValue]
                                   alpha:[gold[@"alpha"] floatValue]];
    _uwBlackColor = [UIColor colorWithRed:[black[@"red"] floatValue]
                                   green:[black[@"green"] floatValue]
                                    blue:[black[@"blue"] floatValue]
                                   alpha:[black[@"alpha"] floatValue]];
    _tabBarTintColor = [UIColor colorWithRed:[tabBarColor[@"red"] floatValue]
                                       green:[tabBarColor[@"green"] floatValue]
                                        blue:[tabBarColor[@"blue"] floatValue]
                                       alpha:[tabBarColor[@"alpha"] floatValue]];
}

+ (void)post {
    [[UWColorSchemeCenter sharedCenter] post];
}

- (void)post {
    LogMethod;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName object:self userInfo:nil];
}

+ (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector {
    [[UWColorSchemeCenter sharedCenter] registerColorSchemeNotificationForObserver:observer selector:selector];
}

- (void)registerColorSchemeNotificationForObserver:(id)observer selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:_notificationName object:self];
}

+ (void)saveColorScheme {
    [[UWColorSchemeCenter sharedCenter] saveColorScheme];
}

- (void)saveColorScheme {
    LogMethod;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.uwGoldColor] forKey:@"uwGoldColor"];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.uwBlackColor] forKey:@"uwBlackColor"];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.tabBarTintColor] forKey:@"tabBarTintColor"];
    
    [defaults setInteger:self.statusBarStyle forKey:@"statusBarStyle"];
    [defaults synchronize];
}

+ (void)readColorScheme {
    [[UWColorSchemeCenter sharedCenter] readColorScheme];
}

- (void)readColorScheme {
    LogMethod;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.uwGoldColor = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"uwGoldColor"]];
    if (self.uwGoldColor == nil) {
        NSLog(@"Default color: UW_GOLD");
        self.uwGoldColor = UW_GOLD;
    }
    
    self.uwBlackColor = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"uwBlackColor"]];
    if (self.uwBlackColor == nil) {
        NSLog(@"Default color: UW_BLACK");
        self.uwBlackColor = UW_BLACK;
    }
    self.tabBarTintColor = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"tabBarTintColor"]];
    if (self.tabBarTintColor == nil) {
        NSLog(@"Default color: TAB_BAR_COLOR");
        self.tabBarTintColor = TAB_BAR_COLOR;
    }
    self.statusBarStyle = [defaults integerForKey:@"statusBarStyle"];
}

+ (void)resetColorScheme {
    [[UWColorSchemeCenter sharedCenter] resetColorScheme];
}

- (void)resetColorScheme {
    _uwGoldColor = UW_GOLD;
    _uwBlackColor = UW_BLACK;
    _tabBarTintColor = TAB_BAR_COLOR;
    _statusBarStyle = UIStatusBarStyleDefault;
}

@end
