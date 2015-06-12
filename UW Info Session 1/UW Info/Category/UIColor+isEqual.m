//
//  UIColor+isEqual.m
//  UW Info
//
//  Created by Honghao on 7/20/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UIColor+isEqual.h"

@implementation UIColor (isEqual)

- (BOOL)isEqualToColor:(UIColor *)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat red1 = 0.0, green1 = 0.0, blue1 = 0.0, alpha1 =0.0;
    [color getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    if ((red == red1) && (green == green1) && (blue == blue1) && (alpha == alpha1)) {
        return true;
    } else {
        return false;
    }
}

@end
