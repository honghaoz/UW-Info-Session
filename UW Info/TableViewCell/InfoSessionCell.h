//
//  InfoSessionCell.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoSessionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *employer;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *location;
@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

//@property (nonatomic, strong) IBOutlet UIImageView *logo;

@end
