//
//  UWTabBarController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoSessionsViewController;
@class MyInfoViewController;
@class SearchViewController;
@class DetailViewController;

@interface UWTabBarController : UITabBarController //<DetailViewControllerDelegate>

//@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, strong) InfoSessionsViewController *infoSessionsViewController;
@property (nonatomic, strong) MyInfoViewController *myInfoViewController;
@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) DetailViewController *detailViewController;

@property (nonatomic, assign) BOOL isHidden;

- (void) hideTabBar;
- (void) showTabBar;

@end
