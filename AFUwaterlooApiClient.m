//
//  AFUwaterlooApiClient.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFUwaterlooApiClient.h"
static NSString * const AFUwaterlooApiBaseURLString = @"https://api.uwaterloo.ca/v2/";

@implementation AFUwaterlooApiClient

+ (instancetype)sharedClient {
    static AFUwaterlooApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFUwaterlooApiClient alloc] initWithBaseURL:[NSURL URLWithString:AFUwaterlooApiBaseURLString]];
    });
    
    return _sharedClient;
}

@end
