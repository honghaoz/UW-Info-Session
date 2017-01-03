//
//  UIColor+ApplyAlpha.m
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UIColor+ApplyAlpha.h"

@implementation UIColor (ApplyAlpha)

- (UIColor *)colorByApplyingAlpha:(CGFloat)alpha {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, oldAlpha =0.0;
    [self getRed:&red green:&green blue:&blue alpha:&oldAlpha];
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
