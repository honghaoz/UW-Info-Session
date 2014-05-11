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
#import <Parse/Parse.h>
#import "WXApi.h"
#import "UIDevice-Hardware.h"

#import "GAI.h"
#import "iRate.h"
#import "HSLUpdateChecker.h"
#import "UIApplication+AppVersion.h"

#import "UWErrorReport.h"

@implementation UWAppDelegate {
    InfoSessionModel *_infoSessionModel;
    PFObject *currentDevice;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    [[UIApplication sharedApplication] keyWindow].tintColor = UWBlack;
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
    
    // Set timer to refresh cell
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
    
    // Parse service
    [Parse setApplicationId:@"zytbQR05vLnq2h37zHHBDneLWMzaH47qHB978zfx"
                  clientKey:@"O107hqVq0uYHr3QLFGSCTJPCCC5YKY5vx2BQXS2q"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //NSLog(@"%@", identifierForVendor);
//    NSLog(@"%@", [[UIDevice currentDevice] platform]);
//    NSLog(@"%@", [[UIDevice currentDevice] platformString]);
//    NSLog(@"%@", [[UIDevice currentDevice] hwmodel]);
    NSString *deviceType = [NSString stringWithFormat:@"%@ %@(%@)", [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] platform], [[UIDevice currentDevice] hwmodel]];
    NSLog(@"%@", deviceType);
    
    PFQuery *queryForId = [PFQuery queryWithClassName:@"Device"];
    [queryForId whereKey:@"Identifier" equalTo:identifierForVendor];
    [queryForId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"delegate Successfully retrieved %lu devices.", (unsigned long)objects.count);
            // no object for this id, query with device name
            if (objects.count == 0) {
                PFQuery *queryForDeviceName = [PFQuery queryWithClassName:@"Device"];
                [queryForDeviceName whereKey:@"Device_Name" equalTo:deviceName];
                [queryForDeviceName findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"delegate Successfully retrieved %lu devices.", (unsigned long)objects.count);
                        // if no object for this device name, create a new object
                        if (objects.count == 0) {
                            PFObject *device = [PFObject objectWithClassName:@"Device"];
                            device[@"Device_Name"] = deviceName;
                            //device[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
                            device[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                            device[@"Opens"] = @1;
                            device[@"Identifier"] = identifierForVendor;
                            device[@"App_Version"] = [UIApplication appVersion];
                            device[@"Installation"] = [PFInstallation currentInstallation];
                            //device[@"channels"] = [PFInstallation currentInstallation][];
                            device[@"Device_Type"] = deviceType;
//                            device[@"Device_Token"] = [PFInstallation currentInstallation].deviceToken;
                            //device[@"Query_Key"] = _infoSessionModel.apiKey;
                            currentDevice = device;
                            [device saveEventually];
                        }
                        // Do something with the found objects
                        else {
                            for (PFObject *object in objects) {
                                object[@"Device_Name"] = deviceName;
                                //object[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
                                object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                                object[@"Opens"] = [NSNumber numberWithInteger:[object[@"Opens"] integerValue] + 1];
                                object[@"Identifier"] = identifierForVendor;
                                //NSLog(@"update key: %@", object[@"Query_Key"]);
                                object[@"App_Version"] = [UIApplication appVersion];
                                object[@"Installation"] = [PFInstallation currentInstallation];
                                object[@"Device_Type"] = deviceType;
//                                object[@"Device_Token"] = [PFInstallation currentInstallation].deviceToken;
                                if (object[@"Query_Key"] == nil && ![_infoSessionModel.apiKey isEqualToString:@"0"]) {
                                    NSLog(@"Key is nil, restore key");
                                    object[@"Query_Key"] = _infoSessionModel.apiKey;
                                } else if (object[@"Query_Key"] == nil && [_infoSessionModel.apiKey isEqualToString:@"0"]) {
//                                    NSLog(@"WTF??? object[@Query_Key] == nil && [_infoSessionModel.apiKey isEqualToString:@0]");
                                    _infoSessionModel.apiKey = @"1";
                                    
                                    [UWErrorReport reportErrorWithDescription:@"Delegate: Wrong key: 0, set 1 insted"];
                                    
                                    object[@"Query_Key"] = _infoSessionModel.apiKey;
                                    [UWErrorReport reportErrorWithDescription:@"object[@Query_Key] == nil && [_infoSessionModel.apiKey isEqualToString:@0], query device name"];
                                }
                                else {
                                    NSLog(@"update key: %@", object[@"Query_Key"]);
                                    _infoSessionModel.apiKey = object[@"Query_Key"];
                                }
                                //_infoSessionModel.apiKey = object[@"Query_Key"];
                                // for retrive old key stored in device
                                //object[@"Query_Key"] = _infoSessionModel.apiKey;
                                currentDevice = object;
                                [object saveEventually];
                            }
                        }
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"query device name error: %@ %@", error, [error userInfo]]];
                    }
                }];
            }
            // Do something with the found objects
            else {
                for (PFObject *object in objects) {
                    //NSLog(@"%@", object[@"Installation"][@"deviceToken"]);
                    object[@"Device_Name"] = deviceName;
                    //object[@"Platform_Name"] = [[UIDevice currentDevice] systemName];
                    object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                    object[@"Opens"] = [NSNumber numberWithInteger:[object[@"Opens"] integerValue] + 1];
                    object[@"App_Version"] = [UIApplication appVersion];
                    object[@"Installation"] = [PFInstallation currentInstallation];
                    object[@"Device_Type"] = deviceType;
//                    object[@"Device_Token"] = [PFInstallation currentInstallation].deviceToken;
                    if (object[@"Query_Key"] == nil && ![_infoSessionModel.apiKey isEqualToString:@"0"]) {
                        NSLog(@"Key is nil, restore key");
                        object[@"Query_Key"] = _infoSessionModel.apiKey;
                    } else if (object[@"Query_Key"] == nil && [_infoSessionModel.apiKey isEqualToString:@"0"]) {
                        //NSLog(@"WTF??? object[@Query_Key] == nil && [_infoSessionModel.apiKey isEqualToString:@0]");
                        _infoSessionModel.apiKey = @"1";
                        object[@"Query_Key"] = _infoSessionModel.apiKey;
                        [UWErrorReport reportErrorWithDescription:@"object[@Query_Key] == nil && [_infoSessionModel.apiKey isEqualToString:@0], query device identifier"];
                    }
                    else {
                        NSLog(@"update key: %@", object[@"Query_Key"]);
                        _infoSessionModel.apiKey = object[@"Query_Key"];
                    }
                    //object[@"Query_Key"] = _infoSessionModel.apiKey;
                    currentDevice = object;
                    [object saveEventually];
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"query device identifier error: %@ %@", error, [error userInfo]]];
        }
    }];
    
    // register weixin
    [WXApi registerApp:@"wxd7e4735bd9b62ea4"];
    
    // Google Analytics
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-45146473-2"];
    
    // check update
    [HSLUpdateChecker checkForUpdate];
    
    // Register push notification
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

+ (void)initialize {
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 4;
    [iRate sharedInstance].usesUntilPrompt = 15;
    [iRate sharedInstance].eventsUntilPrompt = 5;
    [iRate sharedInstance].remindPeriod = 1;
    [iRate sharedInstance].message = @"If you find UW Info is helpful, would you mind taking a moment to rate it? It's your support makes me do better! Thanks!";
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    //[iRate sharedInstance].previewMode = YES;
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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
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
    NSLog(@"%@", [notification.userInfo objectForKey:@"InfoId"]);
    NSLog(@"%d", targetIndex);
    InfoSession *theTargetInfo = [_infoSessionModel.myInfoSessions objectAtIndex:targetIndex];
    NSLog(@"%@, %d", theTargetInfo.employer, [[notification.userInfo objectForKey:@"AlertIndex"] integerValue]);
    //NSMutableDictionary *theTargetAlert = [theTargetInfo getAlertForChoice:[notification.userInfo objectForKey:@"AlertIndex"]];
    NSMutableDictionary *theTargetAlert = [theTargetInfo.alerts objectAtIndex:[[notification.userInfo objectForKey:@"AlertIndex"] integerValue]];
    [theTargetAlert setValue:[NSNumber numberWithBool:YES] forKey:@"isNotified"];
    [_infoSessionModel saveMyInfoSessions];
}


- (void)handleEveryMinutes:(NSTimer *)timer {
    // post notification every minute
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OneMinute" object:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    NSLog(@"register push");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = application.applicationIconBadgeNumber;
    [currentInstallation addUniqueObject:@"Info_News" forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    currentInstallation[@"Device_Name"] = [[UIDevice currentDevice] name];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = 0;
    currentInstallation[@"Device_Name"] = [[UIDevice currentDevice] name];
    [currentInstallation saveInBackground];
    [PFPush handlePush:userInfo];
}

@end
