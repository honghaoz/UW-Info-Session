//
//  UWDeviceCell.m
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWDeviceCell.h"
#import "UWCellScrollView.h"

@implementation UWDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _scrollView = [[UWCellScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 32)];
        
        _scrollView.backgroundColor = [UIColor clearColor];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        CGFloat seperatorWidth = 10;
        CGFloat deviceNameWidth = 200;
        _deviceName = [[UILabel alloc] initWithFrame:CGRectMake(seperatorWidth, 3, deviceNameWidth, 24)];
        [_deviceName setTextAlignment:NSTextAlignmentLeft];
        [_deviceName setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_deviceName];
        
        CGFloat queryKeyWidth = 30;
        _queryKey = [[UITextField alloc] initWithFrame:CGRectMake(_deviceName.frame.origin.x + _deviceName.frame.size.width + seperatorWidth, 3, queryKeyWidth, 24)];
        [_queryKey setTextAlignment:NSTextAlignmentLeft];
        [_queryKey setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_queryKey];
        
        CGFloat openTimesWidth = 40;
        _openTimes = [[UILabel alloc] initWithFrame:CGRectMake(_queryKey.frame.origin.x + _queryKey.frame.size.width + seperatorWidth, 3, openTimesWidth, 24)];
        [_openTimes setTextAlignment:NSTextAlignmentLeft];
        [_openTimes setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_openTimes];
        
        CGFloat appVersionWidth = 70;
        _appVersion = [[UILabel alloc] initWithFrame:CGRectMake(_openTimes.frame.origin.x + _openTimes.frame.size.width + seperatorWidth, 3, appVersionWidth, 24)];
        [_appVersion setTextAlignment:NSTextAlignmentLeft];
        [_appVersion setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_appVersion];
        
        CGFloat deviceTypeWidth = 200;
        _deviceType = [[UILabel alloc] initWithFrame:CGRectMake(_appVersion.frame.origin.x + _appVersion.frame.size.width + seperatorWidth, 3, deviceTypeWidth, 24)];
        [_deviceType setTextAlignment:NSTextAlignmentLeft];
        [_deviceType setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_deviceType];
        
        CGFloat systemVersionWidth = 70;
        _systemVersion = [[UILabel alloc] initWithFrame:CGRectMake(_deviceType.frame.origin.x + _deviceType.frame.size.width + seperatorWidth, 3, systemVersionWidth, 24)];
        [_systemVersion setTextAlignment:NSTextAlignmentLeft];
        [_systemVersion setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_systemVersion];
        
        CGFloat channelsWidth = 120;
        _channels = [[UITextField alloc] initWithFrame:CGRectMake(_systemVersion.frame.origin.x + _systemVersion.frame.size.width + seperatorWidth, 3, channelsWidth, 24)];
        [_channels setTextAlignment:NSTextAlignmentLeft];
        [_channels setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_channels];
        
        CGFloat createdWidth = 130;
        _created = [[UILabel alloc] initWithFrame:CGRectMake(_channels.frame.origin.x + _channels.frame.size.width + seperatorWidth, 3, createdWidth, 24)];
        [_created setTextAlignment:NSTextAlignmentLeft];
        [_created setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_created];
        
        CGFloat updatedWidth = 130;
        _updated = [[UILabel alloc] initWithFrame:CGRectMake(_created.frame.origin.x + _created.frame.size.width + seperatorWidth, 3, updatedWidth, 24)];
        [_updated setTextAlignment:NSTextAlignmentLeft];
        [_updated setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_updated];
        
        CGFloat noteWidth = 100;
        _note = [[UITextField alloc] initWithFrame:CGRectMake(_updated.frame.origin.x + _updated.frame.size.width + seperatorWidth, 3, noteWidth, 24)];
        [_note setTextAlignment:NSTextAlignmentLeft];
        [_note setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:_note];
        
        _scrollView.contentSize = CGSizeMake(_note.frame.origin.x + _note.frame.size.width + seperatorWidth, 30);
        
        [self.contentView addSubview:_scrollView];
    
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
