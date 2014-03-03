//
//  LoadingCell.m
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingLabel setFrame:CGRectMake(203, 11, 20, 20)];
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 11, 181, 21)];
        [_loadingLabel setFont:[UIFont systemFontOfSize:17.0]];
        [_loadingLabel setTextColor:[UIColor darkGrayColor]];
        
        [self.contentView addSubview:_loadingLabel];
        [self.contentView addSubview:_loadingIndicator];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
