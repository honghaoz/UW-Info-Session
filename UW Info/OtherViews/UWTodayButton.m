//
//  UWTodayButton.m
//  UW Info
//
//  Created by Zhang Honghao on 3/4/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWTodayButton.h"
#import "InfoSession.h"
#import "UIColor+ApplyAlpha.h"

@interface UWTodayButton ()

@property (nonatomic, strong) UILabel* todayLabel;
@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightColor;

@end

@implementation UWTodayButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UWTodayButton*)initWithTitle:(NSString*)title date:(NSDate*)date
{
    CGFloat buttonWidth = 40;
    self = [self initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
    if (self) {
        self.normalColor = [UIColor blackColor];
        self.highlightColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, buttonWidth, 15)];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _todayLabel.font = [UIFont systemFontOfSize:13];
        _todayLabel.text = title;
        _todayLabel.textColor = self.normalColor;
        _todayLabel.highlightedTextColor = self.highlightColor;//[UIColor colorWithWhite:0.0 alpha:0.3];

        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, buttonWidth, 14)];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _dateLabel.font = [UIFont boldSystemFontOfSize:11];
        _dateLabel.textColor = self.normalColor;
        _dateLabel.highlightedTextColor = self.highlightColor;//[UIColor colorWithWhite:0.0 alpha:0.3];

        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
        //NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //[dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"MMM d"];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];

        _dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];

        [self addSubview:_todayLabel];
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    LogMethod;
    self.normalColor = color;
    self.highlightColor = [color colorByApplyingAlpha:0.35];
    _todayLabel.textColor = self.normalColor;
    _dateLabel.textColor = self.normalColor;
    _todayLabel.highlightedTextColor = self.highlightColor;
    _dateLabel.highlightedTextColor = self.highlightColor;
}

- (void)setSelected:(BOOL)selected
{
    LogMethod;
    super.selected = selected;
    _todayLabel.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    _todayLabel.highlighted = highlighted;
    _dateLabel.highlighted = highlighted;
//    if (highlighted) {
//        NSLog(@"high state");
//        _todayLabel.textColor = self.highlightColor;
//        _dateLabel.textColor = self.highlightColor;
//    } else {
//        NSLog(@"normal state");
//        _todayLabel.textColor = self.normalColor;
//        _dateLabel.textColor = self.normalColor;
//    }
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    if (enabled) {
        _todayLabel.textColor = self.normalColor;
        _dateLabel.textColor = self.normalColor;
    } else {
        _todayLabel.textColor = self.highlightColor;//[UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:0.5];
        _dateLabel.textColor = self.highlightColor;//[UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:0.5];
    }
}

@end
