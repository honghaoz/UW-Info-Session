//
//  UWAppiRaterDelegate.m
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWAppiRaterDelegate.h"

@implementation UWAppiRaterDelegate


+ (UWAppiRaterDelegate *)sharediRateDelegate
{
    LogMethod;
    static UWAppiRaterDelegate *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UWAppiRaterDelegate alloc] init];
    });
    
    return _shared;
}


- (void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated
{
    LogMethod;
}


- (void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated
{
    LogMethod;
}


- (void)appiraterDidDisplayAlert:(Appirater *)appirater
{
    LogMethod;
}

@end
