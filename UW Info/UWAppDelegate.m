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
#import "AFNetworkActivityIndicatorManager.h"

@implementation UWAppDelegate {
    InfoSessionModel *_infoSessionModel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
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
        NSInteger targetIndex = [InfoSessionModel findInfoSessionIdentifier:[localNotification.userInfo objectForKey:@"InfoId"] in:_infoSessionModel.myInfoSessions];
        tabController.targetIndexTobeSelectedInMyInfoVC = targetIndex;
        
        [self setNotified:localNotification];
    } else {
        tabController.targetIndexTobeSelectedInMyInfoVC = -1;
    }
    
    // get time interval of seconds in minute
    NSTimeInterval roundedInterval = round([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    // date of next minute
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:roundedInterval + 60];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:date
                                              interval:60
                                                target:self
                                              selector:@selector(handleEveryMinutes:)
                                              userInfo:nil
                                               repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
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
    // clear badge number
    application.applicationIconBadgeNumber = 0;
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
    // clear badge number
    application.applicationIconBadgeNumber = 0;
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
    [self setNotified:notification];
    
    // clear badge number
    application.applicationIconBadgeNumber = 0;
}

/**
 *  Use notification to set the related alert to isNotified
 *
 *  @param notification
 */
- (void)setNotified:(UILocalNotification *)notification {
    NSInteger targetIndex = [InfoSessionModel findInfoSessionIdentifier:[notification.userInfo objectForKey:@"InfoId"] in:_infoSessionModel.myInfoSessions];
    InfoSession *theTargetInfo = [_infoSessionModel.myInfoSessions objectAtIndex:targetIndex];
    //NSMutableDictionary *theTargetAlert = [theTargetInfo getAlertForChoice:[notification.userInfo objectForKey:@"AlertIndex"]];
    NSMutableDictionary *theTargetAlert = [theTargetInfo.alerts objectAtIndex:[[notification.userInfo objectForKey:@"AlertIndex"] integerValue]];
    [theTargetAlert setValue:[NSNumber numberWithBool:YES] forKey:@"isNotified"];
}


- (void)handleEveryMinutes:(NSTimer *)timer {
    // post notification every minute
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OneMinute" object:self];
}

@end
