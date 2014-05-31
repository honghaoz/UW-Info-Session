//
//  UWDetailRSVPCell.m
//  UW Info
//
//  Created by Zhang Honghao on 5/17/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWDetailRSVPCell.h"

@implementation UWDetailRSVPCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 21)];
        [_titleLabel setText:@"Register"];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        
        _statusSiwtch = [[UISwitch alloc] initWithFrame:CGRectMake(251, 5, 49, 31)];
        _statusSiwtch.onTintColor = UWGold;
        //_statusSiwtch.tintColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_statusSiwtch];
        
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