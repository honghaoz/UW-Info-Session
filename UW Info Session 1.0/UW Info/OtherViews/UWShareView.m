//
//  UWShareView.m
//  UW Info
//
//  Created by Zhang Honghao on 4/6/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWShareView.h"

@implementation UWShareView {
    CGFloat buttonWidth;
    CGFloat padding;
    CGFloat titleHeight;
    CGFloat cancelHeight;
    NSInteger numberOfRows;
    NSInteger numberOfColumns;
}

- (id)init {
    if ((self = [super init])) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;

        buttonWidth = 60;
        titleHeight = 30;
        cancelHeight = 30;
        numberOfRows = 3;
        numberOfColumns = 4;
        
        padding = (screenSize.width - numberOfColumns * buttonWidth) / (numberOfColumns + 1);
        CGFloat padViewHeight = titleHeight + (numberOfRows + 1) * padding + numberOfRows * buttonWidth;
        CGFloat padViewOriginY = self.frame.size.height - padViewHeight;
        
        [self setFrame:CGRectMake(0, padViewOriginY, screenSize.width, padViewHeight)];
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

@end
