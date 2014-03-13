//
//  CenterTextCell.m
//  UW Info
//
//  Created by Zhang Honghao on 3/12/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "CenterTextCell.h"

@implementation CenterTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _centerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 24)];
        [_centerTextLabel setTextAlignment:NSTextAlignmentCenter];
        [_centerTextLabel setFont:[UIFont systemFontOfSize:18]];
        [self.contentView addSubview:_centerTextLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
