//
//  UWTabBarController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface UWTabBarController : UITabBarController //<DetailViewControllerDelegate>

//@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, assign) BOOL isHidden;

- (void) hideTabBar;
- (void) showTabBar;

@end
