//
//  UWTabBarController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWTabBarController.h"
#import "InfoSessionsViewController.h"
#import "MyInfoViewController.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

@interface UWTabBarController ()

@end

@implementation UWTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"UWTabbar viweDidLoad");
    _lastTapped = -1;
//    [self.tabBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:0.9]];
    
     //[UIColor colorWithRed:0/255.0 green:213/255.0 blue:161/255.0 alpha:1]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITabBar *tabBar = self.tabBar;
    [tabBar setBarStyle:UIBarStyleBlackOpaque];
    [tabBar setBackgroundColor:[UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1]];
    //[UIColor colorWithRed:0.26 green:0.28 blue:0.33 alpha:1]
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    [item0 setSelectedImage:[UIImage imageNamed:@"List-selected"]];
    [item1 setSelectedImage:[UIImage imageNamed:@"Bookmarks-selected"]];
    [item2 setSelectedImage:[UIImage imageNamed:@"Search-selected"]];
    
    self.tabBar.tintColor = [UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0];
	// Do any additional setup after loading the view.
    self.isHidden = NO;
    
    // initiate three VC in tabbarController
    NSLog(@"initiate three VC in tabbarController");
    UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
    _infoSessionsViewController = (InfoSessionsViewController *)navigationController.viewControllers[0];
    _infoSessionsViewController.tabBarController = self;
    
    navigationController = [self.viewControllers objectAtIndex:1];
    _myInfoViewController = (MyInfoViewController *)navigationController.viewControllers[0];
     _myInfoViewController.tabBarController = self;
    
    navigationController = [self.viewControllers objectAtIndex:2];
    _searchViewController = (SearchViewController *)navigationController.viewControllers[0];
     _searchViewController.tabBarController = self;
    
    //[self setSelectedIndex:1];
    //[self setSelectedIndex:2];
    //[self setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) {
        _detailViewControllerOfTabbar1.performedNavigation = @"Open Tabbar1";
        if (_lastTapped == 0) {
            // if first tab show InfoSessionsViewController then scroll to today
            UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
            if ([navigationController.topViewController isKindOfClass:[InfoSessionsViewController class]]) {
                [_infoSessionsViewController scrollToToday];
            }
        }
        _lastTapped = 0;

    } else if (item.tag == 1) {
        _detailViewControllerOfTabbar0.performedNavigation = @"Open Tabbar2";
        if (_lastTapped != 1) {
            [_myInfoViewController reloadTable];
        }
        _lastTapped = 1;
    } else {
        _detailViewControllerOfTabbar0.performedNavigation = @"Open Tabbar3";
        _detailViewControllerOfTabbar1.performedNavigation = @"Open Tabbar3";
        _lastTapped = 2;
    }
    //[item setBadgeValue:@"1"];
    //[self tabBarItem]
}

//#pragma mark - DetailViewControllerDelegate methods
//
//- (void)detailViewController:(DetailViewController *)detailController didAddInfoSession:(InfoSession *)infoSession {
//    //[self setSelectedIndex:1];
//    //[[self.viewControllers[0] tabBarItem] setBadgeValue:@"!@312312"];
////    MyInfoViewController *myInfoViewController = [[MyInfoViewController alloc] init];
////    UINavigationController *navigation = self.viewControllers[1];
////    [navigation pushViewController:myInfoViewController animated:YES];
//    
//}

/**
 *  Hide tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) hideTabBar{
    if (!self.isHidden) {
        self.isHidden = YES;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        float fHeight = screenRect.size.height;
        if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
        {
            fHeight = screenRect.size.width;
        }
        
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                view.backgroundColor = [UIColor whiteColor];
            }
        }
        [UIView commitAnimations];
    }
}

/**
 *  Show tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) showTabBar {
    if (self.isHidden) {
        self.isHidden = NO;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float fHeight = screenRect.size.height - self.tabBar.frame.size.height;
        
        if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
        {
            fHeight = screenRect.size.width - self.tabBar.frame.size.height;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            }
        }
        [UIView commitAnimations];
    }
}

@end
