//
//  DetailViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertViewController.h"
@class InfoSession;
@class InfoSessionModel;
@class DetailViewController;
@class UWTabBarController;
@class DetailDescriptionCell;

@interface DetailViewController : UITableViewController <AlertViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *caller;
@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSession *infoSessionBackup;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, weak) UWTabBarController *tabBarController;

// performedNavigation is a string records what navigation action causes DetailView disappears
@property (nonatomic, copy) NSString *performedNavigation;

@end
