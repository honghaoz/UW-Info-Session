//
//  UWCellScrollView.m
//  UW Info
//
//  Created by Zhang Honghao on 5/14/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWCellScrollView.h"

@implementation UWCellScrollView

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

- (void)updateContentOffset:(NSNotification *)notification {
    //NSLog(@"receive notification");
    CGPoint offset = [[notification.userInfo objectForKey:@"CurrentContentOffset"] CGPointValue];
    //NSLog(@"received offset: %@", NSStringFromCGPoint(offset));
    //[self setContentOffset:offset animated:YES];
    self.contentOffset = offset;
}

@end
