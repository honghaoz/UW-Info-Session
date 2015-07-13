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
@class InfoSessionModel;

@interface UWTabBarController : UITabBarController //<DetailViewControllerDelegate>

@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, strong) InfoSessionsViewController *infoSessionsViewController;
@property (nonatomic, strong) MyInfoViewController *myInfoViewController;
@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) DetailViewController *detailViewControllerOfTabbar0;
@property (nonatomic, strong) DetailViewController *detailViewControllerOfTabbar1;
@property (nonatomic, strong) DetailViewController *detailViewControllerOfTabbar2;

@property (nonatomic, assign) NSUInteger lastTapped;

@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, assign) NSInteger targetIndexTobeSelectedInMyInfoVC;

- (void) hideTabBar;
- (void) showTabBar;

- (void) setBadge;

@end
