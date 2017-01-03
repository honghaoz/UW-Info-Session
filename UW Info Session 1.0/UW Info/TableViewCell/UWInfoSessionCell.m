//
//  InfoSessionCell.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWInfoSessionCell.h"

@implementation UWInfoSessionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _employer = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, 272, 25)];
        [_employer setFont:[UIFont boldSystemFontOfSize:17]];
        [_employer setTextColor:[UIColor blackColor]];
        
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 26, 76, 21)];
        [_locationLabel setFont:[UIFont systemFontOfSize:14]];
        [_locationLabel setTextColor:[UIColor darkGrayColor]];
        [_locationLabel setText:@"Location: "];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 43, 41, 21)];
        [_dateLabel setFont:[UIFont systemFontOfSize:14]];
        [_dateLabel setTextColor:[UIColor darkGrayColor]];
        [_dateLabel setText:@"Date: "];
        
        
        _location= [[UILabel alloc] initWithFrame:CGRectMake(80, 26, 202, 21)];
        [_location setFont:[UIFont systemFontOfSize:14]];
        [_location setTextColor:[UIColor darkGrayColor]];
        
        _date= [[UILabel alloc] initWithFrame:CGRectMake(56, 43, 226, 21)];
        [_date setFont:[UIFont systemFontOfSize:14]];
        [_date setTextColor:[UIColor darkGrayColor]];
        
        [self setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        [self.contentView addSubview:self.employer];
        [self.contentView addSubview:self.locationLabel];
        [self.contentView addSubview:self.location];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.date];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
