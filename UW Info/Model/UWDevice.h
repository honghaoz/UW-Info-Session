//
//  UWDevice.h
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWDevice : NSObject

@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *queryKey;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) NSNumber *openTimes;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSDate *createTime;
@property (nonatomic, copy) NSDate *updateTime;

@end
