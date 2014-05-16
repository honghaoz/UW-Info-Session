//
//  UWDeviceCell.h
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWCellScrollView;

@interface UWDeviceCell : UITableViewCell

@property (nonatomic, strong) UILabel *deviceName;
@property (nonatomic, strong) UITextField *queryKey;
@property (nonatomic, strong) UILabel *openTimes;
@property (nonatomic, strong) UILabel *appVersion;
@property (nonatomic, strong) UILabel *deviceType;
@property (nonatomic, strong) UILabel *systemVersion;
@property (nonatomic, strong) UITextField *channels;
@property (nonatomic, strong) UILabel *created;
@property (nonatomic, strong) UILabel *updated;
@property (nonatomic, strong) UITextField *note;

@property (nonatomic, strong) UWCellScrollView *scrollView;

@end
