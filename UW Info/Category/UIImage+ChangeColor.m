//
//  UIImage+ChangeColor.m
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UIImage+ChangeColor.h"

@implementation UIImage (ChangeColor)

- (UIImage *)changeToColor:(UIColor*)color {
    UIImage *mask = self;
    CGImageRef maskImage = mask.CGImage;
    CGFloat width = mask.scale * mask.size.width;
    CGFloat height = mask.scale * mask.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    return [UIImage imageWithCGImage:mainViewContentBitmapContext scale:mask.scale orientation:UIImageOrientationUp];
}

@end
