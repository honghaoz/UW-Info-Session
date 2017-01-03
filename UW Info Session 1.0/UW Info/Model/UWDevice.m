//
//  UWDevice.m
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWDevice.h"
#import <Parse/Parse.h>
#import "UWColorSchemeCenter.h"

@implementation UWDevice

- (id)init {
    self = [super init];
    if (self) {
        //
        _isRandomColor = NO;
    }
    return self;
}

+ (instancetype)sharedDevice
{
    static UWDevice *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UWDevice alloc] init];
    });
    return _sharedClient;
}


- (void)setIsColorful:(BOOL)isColorful
{
    if (_pfObject != nil) {
        _pfObject[@"isColorful"] = [NSNumber numberWithBool:isColorful];
        [_pfObject saveEventually];
    }
}


- (void)updateColorScheme
{
    LogMethod;
    if (_pfObject != nil) {
        NSLog(@"Device: %@", _pfObject[@"Device_Name"]);
        if ([_pfObject[@"isRandomColor"] boolValue]) {
            _isRandomColor = YES;
            [UWColorSchemeCenter updateColorScheme];
            return;
        }
        if ([_pfObject[@"isColorful"] boolValue]) {
            PFObject *colorScheme_ref = _pfObject[@"ColorScheme_ref"];
            //        PFQuery *query = [colorScheme_ref query];
            [colorScheme_ref fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        PFObject *UWGold = object[@"UWGold"];
                        [UWGold fetchIfNeeded];
                        PFObject *UWBlack = object[@"UWBlack"];
                        [UWBlack fetchIfNeeded];
                        PFObject *TabBar = object[@"TabBar"];
                        [TabBar fetchIfNeeded];
                        BOOL statusBarIsLight = [object[@"statusBarIsLight"] boolValue];
                        if (statusBarIsLight) {
                            [UWColorSchemeCenter setStatusStyle:UIStatusBarStyleLightContent];
                        } else {
                            [UWColorSchemeCenter setStatusStyle:UIStatusBarStyleDefault];
                        }
                        
                        [UWColorSchemeCenter setGoldColor:[UIColor colorWithRed:[UWGold[@"red"] floatValue]
                                                                          green:[UWGold[@"green"] floatValue]
                                                                           blue:[UWGold[@"blue"] floatValue]
                                                                          alpha:[UWGold[@"alpha"] floatValue]]];
                        [UWColorSchemeCenter setBlackColor:[UIColor colorWithRed:[UWBlack[@"red"] floatValue]
                                                                           green:[UWBlack[@"green"] floatValue]
                                                                            blue:[UWBlack[@"blue"] floatValue]
                                                                           alpha:[UWBlack[@"alpha"] floatValue]]];
                        [UWColorSchemeCenter setTabBarColor:[UIColor colorWithRed:[TabBar[@"red"] floatValue]
                                                                            green:[TabBar[@"green"] floatValue]
                                                                             blue:[TabBar[@"blue"] floatValue]
                                                                            alpha:[TabBar[@"alpha"] floatValue]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [UWColorSchemeCenter post];
                        });
                    });
                } else {
                    NSLog(@"No Color Scheme");
                }
            }];
        }
    }
}

@end
