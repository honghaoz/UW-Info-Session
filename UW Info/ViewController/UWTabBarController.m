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
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
    InfoSessionsViewController *infoSessionViewController = (InfoSessionsViewController *)navigationController.topViewController;
    infoSessionViewController.tabBarController = self;
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
    NSLog(@"tap");
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

@end
