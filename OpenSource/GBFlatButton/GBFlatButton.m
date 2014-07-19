//
//  GBFlatButton.m
//  GBFlatButton
//
//  Created by Gustavo Barbosa on 4/15/14.
//  Copyright (c) 2014 Gustavo Barbosa. All rights reserved.
//

#import "GBFlatButton.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kHorizontalPadding = 4.0f;

@implementation GBFlatButton
{
    UIColor *buttonColor;
}

#pragma mark - Constructors

- (id)init
{
    self = [super init];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customizeAppearance];
    }
    return self;
}

#pragma mark - Appearance

- (void)customizeAppearance
{
    BOOL containsEdgeInsets = ! UIEdgeInsetsEqualToEdgeInsets(self.contentEdgeInsets, UIEdgeInsetsZero);
    self.contentEdgeInsets = containsEdgeInsets ? self.contentEdgeInsets : UIEdgeInsetsMake(0, kHorizontalPadding, 0, kHorizontalPadding);
    self.layer.borderWidth = self.layer.borderWidth ?: 1.0f;
    self.layer.cornerRadius = self.layer.cornerRadius ?: CGRectGetHeight(self.frame) / 2.0f;
    self.layer.masksToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted {
    NSLog(highlighted ? @"YES" : @"NO");
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = self.tintColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
        self.backgroundColor = self.tintColor;
    else
        self.backgroundColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect
{
    self.layer.borderColor = self.tintColor.CGColor;
    [self setTitleColor:self.tintColor
               forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateHighlighted];
    self.layer.borderWidth = self.layer.borderWidth ?: 1.0f;
    self.layer.cornerRadius = self.layer.cornerRadius ?: CGRectGetHeight(self.frame) / 2.0f;
    self.layer.masksToBounds = YES;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    buttonColor = tintColor;
    [self setNeedsDisplay];
}

- (UIColor *)tintColor
{
    return buttonColor ?: [super tintColor];
}

@end
