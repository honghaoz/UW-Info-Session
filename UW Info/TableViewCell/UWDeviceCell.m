//
//  UWDeviceCell.m
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWDeviceCell.h"

@implementation UWDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _deviceNameTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 24)];
        [_deviceNameTextLabel setTextAlignment:NSTextAlignmentLeft];
        [_deviceNameTextLabel setFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:_deviceNameTextLabel];
        
        _queryKeyTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 10, 30, 24)];
        [_queryKeyTextLabel setTextAlignment:NSTextAlignmentLeft];
        [_queryKeyTextLabel setFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:_queryKeyTextLabel];
        
        _openTimesTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 40, 24)];
        [_openTimesTextLabel setTextAlignment:NSTextAlignmentLeft];
        [_openTimesTextLabel setFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:_openTimesTextLabel];
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
