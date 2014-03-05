//
//  UWTodayButton.m
//  UW Info
//
//  Created by Zhang Honghao on 3/4/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWTodayButton.h"

@interface UWTodayButton()

@property (nonatomic, strong) UILabel *todayLabel;
@property (nonatomic, strong) UILabel *dateLabel;

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

- (UWTodayButton *)initWithTitle:(NSString *)title date:(NSDate *)date {
    CGFloat buttonWidth = 40;
    self = [self initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, buttonWidth, 15)];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _todayLabel.font = [UIFont systemFontOfSize:13];
        _todayLabel.text = title;
        _todayLabel.textColor = UWBlack;
        _todayLabel.highlightedTextColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, buttonWidth, 14)];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _dateLabel.font = [UIFont boldSystemFontOfSize:11];
        _dateLabel.textColor = UWBlack;
        _dateLabel.highlightedTextColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"MMM d"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
        
        _dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
        
        [self addSubview:_todayLabel];
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    _todayLabel.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted {
    super.highlighted = highlighted;
    _todayLabel.highlighted = highlighted;
    _dateLabel.highlighted = highlighted;
}

@end
