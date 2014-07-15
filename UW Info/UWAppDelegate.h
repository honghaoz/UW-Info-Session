//
//  UWAppDelegate.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
//#import "iRate.h"

@interface UWAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate/*, iRateDelegate*/>

@property (strong, nonatomic) UIWindow *window;

@end
