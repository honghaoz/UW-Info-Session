//
//  UWAppDelegate.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWAppDelegate.h"
#import "InfoSessionModel.h"
#import "UWTabBarController.h"
#import "MyInfoViewController.h"

@implementation UWAppDelegate {
    InfoSessionModel *_infoSessionModel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UWTabBarController *tabController = (UWTabBarController *)self.window.rootViewController;
    // initiate infoSessionModel
    _infoSessionModel = [[InfoSessionModel alloc] init];
    tabController.infoSessionModel = _infoSessionModel;
    
    // check if app is launched by tapping a notification
    // if so, lead app to show detail of this info session
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [tabController setSelectedIndex:1];
        tabController.targetIndexTobeSelectedInMyInfoVC = [InfoSessionModel findInfoSessionIdentifier:[localNotification.userInfo objectForKey:@"InfoId"] in:_infoSessionModel.myInfoSessions];
    } else {
        tabController.targetIndexTobeSelectedInMyInfoVC = -1;
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

/**
 *  save date to local file
 */
-(void)saveData {
    [_infoSessionModel saveInfoSessions];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // clear badge number
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveData];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.userInfo[@"Employer"]
                                                    message:notification.alertBody
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
