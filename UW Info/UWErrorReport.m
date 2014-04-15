//
//  UWErrorReport.m
//  UW Info
//
//  Created by Zhang Honghao on 4/14/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWErrorReport.h"
#import <Parse/Parse.h>
#import "UIApplication+AppVersion.h"

@implementation UWErrorReport

+ (void)reportErrorWithDescription:(NSString *)description {
    PFObject *error = [PFObject objectWithClassName:@"Error"];
    error[@"Device_Name"] = [[UIDevice currentDevice] name];
    error[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
    error[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
    error[@"App_Version"] = [UIApplication appVersion];
    error[@"Description"] = description;
    [error saveEventually];
}

@end
