//
//  DetailNormalCell.m
//  UW Info
//
//  Created by Zhang Honghao on 2/9/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "DetailNormalCell.h"

@implementation DetailNormalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"normal cell called");
        //[self ]
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
