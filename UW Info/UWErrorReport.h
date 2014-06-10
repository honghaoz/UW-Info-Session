//
//  UWErrorReport.h
//  UW Info
//
//  Created by Zhang Honghao on 4/14/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWErrorReport : NSObject

/**
 *  Report Error message
 *
 *  @param description error description
 */
+ (void)reportErrorWithDescription:(NSString *)description;

@end
