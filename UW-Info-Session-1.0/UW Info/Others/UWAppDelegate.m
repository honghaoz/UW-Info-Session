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

#import "WXApi.h"
#import "GAI.h"
#import "iRate.h"
#import "Appirater.h"
#import "HSLUpdateChecker.h"

#import "UIApplication+AppVersion.h"
#import "UIDevice-Hardware.h"

#import "UWColorSchemeCenter.h"

@implementation UWAppDelegate {
    UWTabBarController *_tabController;
    InfoSessionModel* _infoSessionModel;
    NSArray* pushChannels;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.window.backgroundColor = [UIColor blackColor];//[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    [[UIApplication sharedApplication] keyWindow].tintColor = [UWColorSchemeCenter uwBlack];
    
    // Show indicators when there's network connections
    [AFNetworkActivityIndicatorManager sharedManager].enabled = NO;

    // Init
    _tabController = (UWTabBarController*)self.window.rootViewController;
    _infoSessionModel = [[InfoSessionModel alloc] init];
    _tabController.infoSessionModel = _infoSessionModel;

    // Handle notifications: Local and Remote
    [self handleNotifications:launchOptions];

    // Set timer for every minute
    [self setTimerForEveryMinute];

    /************************  Third Party Serverices ***********************/

    // register weixin
    [WXApi registerApp:@"wxd7e4735bd9b62ea4"];

    // Google Analytics
    [self setGoogleAnalytics];

    // check update
//    [HSLUpdateChecker enableDebugMode:YES];
    [HSLUpdateChecker enablePostNotification:YES];
    [HSLUpdateChecker checkForUpdate];

    // Register push notification
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];

    application.applicationIconBadgeNumber = 0;
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[UIApplication appVersion] forKey:@"version"];
    [defaults synchronize];
    
    [application setApplicationSupportsShakeToEdit:YES];
    return YES;
}

/**
 *  Initialize, set up rate promot services
 */
+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].eventsUntilPrompt = 5;
    [iRate sharedInstance].remindPeriod = 1;
    [iRate sharedInstance].message = @"If you find UW Info is helpful, would you mind taking a moment to rate it? It's your support makes me do better! Thanks!";
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    //[iRate sharedInstance].previewMode = YES;
}

#pragma mark - Application life cycle methods

- (void)applicationWillResignActive:(UIApplication*)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveData];
    // clear badge number
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // clear badge number
    application.applicationIconBadgeNumber = 0;
    //    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    PFInstallation* currentInstallation = [PFInstallation currentInstallation];
//    if (currentInstallation.badge != 0) {
//        currentInstallation.badge = 0;
//        [currentInstallation saveEventually];
//    }
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // clear badge number
    application.applicationIconBadgeNumber = 0;
    [self saveData];
}

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
}

#pragma mark - Application methods

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:notification.userInfo[@"Employer"]
                                                    message:notification.alertBody
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self setNotified:notification];

    // clear badge number
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler
{
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)newDeviceToken
{
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - Initialization methods

- (void)handleNotifications:(NSDictionary*)launchOptions
{
    // Handle local notifications
    // Check if app is launched by tapping a notification
    // If so, lead app to show detail of this info session
    UILocalNotification* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [_tabController setSelectedIndex:1];
        NSInteger targetIndex = [InfoSessionModel findInfoSessionIdentifier:[localNotification.userInfo objectForKey:@"InfoId"] in:_infoSessionModel.myInfoSessions];
        _tabController.targetIndexTobeSelectedInMyInfoVC = targetIndex;
        [self setNotified:localNotification];
    } else {
        _tabController.targetIndexTobeSelectedInMyInfoVC = -1;
    }

    // Handle remote push notification
    // Extract the notification data
    NSDictionary* notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

    // Should show reply alert view
    NSString* shouldReply = [notificationPayload objectForKey:@"ShouldReply"];
    NSString* sender = [notificationPayload objectForKey:@"Sender"];
    NSString* receivedMessage = [notificationPayload objectForKey:@"Message"];
    if ([shouldReply isEqualToString:@"YES"]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Reply to %@", sender] message:receivedMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert addButtonWithTitle:@"Send"];
        alert.tag = 0;
        [alert show];
    }
}

/**
 *  Use notification to set the related alert to isNotified
 *  This will avoid not reschedule notified notifications
 *
 *  @param notification
 */
- (void)setNotified:(UILocalNotification*)notification
{
    NSInteger targetIndex = [InfoSessionModel findInfoSessionIdentifier:[notification.userInfo objectForKey:@"InfoId"] in:_infoSessionModel.myInfoSessions];
    NSLog(@"%@", [notification.userInfo objectForKey:@"InfoId"]);
    NSLog(@"%d", targetIndex);
    InfoSession* theTargetInfo = [_infoSessionModel.myInfoSessions objectAtIndex:targetIndex];
    NSLog(@"%@, %d", theTargetInfo.employer, [[notification.userInfo objectForKey:@"AlertIndex"] integerValue]);
    //NSMutableDictionary *theTargetAlert = [theTargetInfo getAlertForChoice:[notification.userInfo objectForKey:@"AlertIndex"]];
    NSMutableDictionary* theTargetAlert = [theTargetInfo.alerts objectAtIndex:[[notification.userInfo objectForKey:@"AlertIndex"] integerValue]];
    [theTargetAlert setValue:[NSNumber numberWithBool:YES] forKey:@"isNotified"];
    [_infoSessionModel saveMyInfoSessions];
}


/**
 *  Init a time for every minute
 */
- (void)setTimerForEveryMinute
{
    // Set timer to refresh cell
    // Get time interval of seconds in minute
    NSTimeInterval roundedInterval = round([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    // Date of next minute
    NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate:roundedInterval + 60];

    NSTimer* timer = [[NSTimer alloc] initWithFireDate:date
                                              interval:60
                                                target:self
                                              selector:@selector(handleEveryMinute:)
                                              userInfo:nil
                                               repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

/**
 *  Post "OneMinute" notification, used for update ongoing info sessions' color
 *
 *  @param timer
 */
- (void)handleEveryMinute:(NSTimer *)timer {
//    if ([UWDevice sharedDevice].isRandomColor || [UWColorSchemeCenter sharedCenter].isTemporaryRandomColor) {
//        [UWColorSchemeCenter updateColorScheme];
//    }
    // post notification every minute
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OneMinute" object:self];
}

/**
 *  Set up Google Analytics Services
 */
- (void)setGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.

    [GAI sharedInstance].trackUncaughtExceptions = YES;

    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;

    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];

    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-45146473-2"];
}

- (void)updateColorScheme {
//    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UWColorSchemeCenter uwGold], UITextAttributeTextColor, [UWColorSchemeCenter uwBlack], UITextAttributeTextShadowColor, nil];
//    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
}

#pragma mark - Other methods

/**
 *  save date to local file
 */
- (void)saveData
{
    [_infoSessionModel saveInfoSessions];
}

#pragma mark - UIAlertView delegate
/**
 *  Used for show reply alert view
 *
 *  @param alertView   alertView description
 *  @param buttonIndex buttonIndex description
 */
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
        }
    }
}

@end
