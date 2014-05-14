//
//  UWGridTableView.m
//  UW Info
//
//  Created by Zhang Honghao on 5/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWGridTableView.h"

@implementation UWGridTableView {
    NSInteger numberOfColumns;
    NSInteger numberOfRows;
    NSMutableArray *widths;
    NSMutableArray *heights;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UWGridTableView *)initWithFrame:(CGRect)frame andContentSize:(CGSize)size byNumberOfColumns:(NSInteger)columns andRows:(NSInteger)rows {
    self = [self initWithFrame:frame];
    if (self) {
        self.contentSize = size;
        numberOfColumns = columns;
        numberOfRows = rows;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(1.0, 1.0)];
        [path addLineToPoint:CGPointMake(size.width - 1.0, 1.0)];
        [path addLineToPoint:CGPointMake(size.width - 1.0, size.height - 1.0)];
        [path addLineToPoint:CGPointMake(1.0, size.height - 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 1.0)];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor darkGrayColor] CGColor];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [self.layer addSublayer:shapeLayer];
        
        // add vertical lines
        CGFloat width = size.width / columns;
        for (NSInteger i = 1; i < columns; i++) {
            [path removeAllPoints];
            [path moveToPoint:CGPointMake(width * i, 1.0)];
            [path addLineToPoint:CGPointMake(width * i, size.height - 1.0)];
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [path CGPath];
            shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
            shapeLayer.lineWidth = 1.0;
            //shapeLayer.lineDashPhase = 5.0;
            shapeLayer.lineDashPattern = @[@1];
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
            [self.layer addSublayer:shapeLayer];
        }
        // add horizontal lines
        CGFloat height = size.height / rows;
        for (NSInteger i = 1; i < rows; i++) {
            [path removeAllPoints];
            [path moveToPoint:CGPointMake(1.0, height * i)];
            [path addLineToPoint:CGPointMake(size.width - 1.0, height * i)];
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [path CGPath];
            shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
            shapeLayer.lineWidth = 1.0;
//            shapeLayer.lineDashPhase = 1.0;
            shapeLayer.lineDashPattern = @[@1];
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
            [self.layer addSublayer:shapeLayer];
        }
        
    }
    return self;
}

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    NSLog(@"draw something");
//    NSLog(@"frame: %@", NSStringFromCGRect(self.frame));
//}


@end
