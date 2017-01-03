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
#import "UIDevice-Hardware.h"

@implementation UWErrorReport

+ (void)reportErrorWithDescription:(NSString *)description {
    PFObject *error = [PFObject objectWithClassName:@"Error"];
    error[@"Device_Name"] = [[UIDevice currentDevice] name];
    //error[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
    error[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
    error[@"App_Version"] = [UIApplication appVersion];
    error[@"Description"] = description;
    
    NSString *deviceType = [NSString stringWithFormat:@"%@ %@(%@)", [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] platform], [[UIDevice currentDevice] hwmodel]];
    error[@"Device_Type"] = deviceType;
    [error saveEventually];
}

@end
