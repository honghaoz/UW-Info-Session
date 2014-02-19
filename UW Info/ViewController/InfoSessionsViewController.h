//
//  InfoSessionsViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTabBarController;

@interface InfoSessionsViewController : UITableViewController

@property (nonatomic, weak) UWTabBarController *tabBarController;

- (void)scrollToToday;

@end
