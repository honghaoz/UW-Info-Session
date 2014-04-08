//
//  NSString+Contain.m
//  UW Info
//
//  Created by Zhang Honghao on 4/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "NSString+Contain.h"

@implementation NSString (Contain)

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end
