//
//  NSString+Contain.h
//  UW Info
//
//  Created by Zhang Honghao on 4/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Contain)


- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;

@end
