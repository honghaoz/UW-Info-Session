//
//  InfoSessionsViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoSessionModel.h"
@class UWTabBarController;

@interface InfoSessionsViewController : UITableViewController <InfoSessionModelDelegate>

@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, weak) UWTabBarController *tabBarController;

- (void)reload:(__unused id)sender;
- (void)scrollToToday;

@end
