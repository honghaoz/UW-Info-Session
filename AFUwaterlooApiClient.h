//
//  AFUwaterlooApiClient.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFUwaterlooApiClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
