//
//  MoreViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 3/12/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MoreViewController.h"
#import "UIApplication+AppVersion.h"
#import "CenterTextCell.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "MoreNavigationViewController.h"
#import "FeedbackViewController.h"
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

#import "GADAdMobExtras.h"
#import "UWGoogleAnalytics.h"
#import "UWAds.h"

#import "iRate.h"
#import "WeixinActivity.h"
#import "LINEActivity.h"
#import "UWErrorReport.h"

@interface MoreViewController () <UIActionSheetDelegate, ADBannerViewDelegate, GADBannerViewDelegate, UIAlertViewDelegate>

@end

@implementation MoreViewController {
    NSString *itunesURLString;
    NSString *itunesRateURLString;
    NSString *itunesShortURLString;
    NSString *appURLString;
    NSString *sharPostString;
    
    UWAds *ad;
    NSInteger toManager_tappedTimes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    self.title = @"More";
    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:UWGold];
    self.navigationController.navigationBar.tintColor = UWBlack;
    
    //[self.tableView registerClass:[CenterTextCell class] forCellReuseIdentifier:@"CenterCell"];
    
    itunesURLString = @"http://itunes.apple.com/app/uw-info-session/id837207884?mt=8";
    itunesRateURLString = @"itms-apps://itunes.apple.com/app/id837207884";
    itunesShortURLString = @"http://goo.gl/bQyyH0";
    appURLString = @"itms://itunes.apple.com/app/uw-info-session/id837207884?mt=8";
    sharPostString = @"UW Info is a great app to search and manage info sessions #UWaterloo, check it out!";
    
    //self.canDisplayBannerAds = YES;
    
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
//    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
//        _adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//    } else {
//        _adBannerView = [[ADBannerView alloc] init];
//    }
//    CGRect contentFrame = self.view.bounds;
//    
//    NSLog(@"%@", NSStringFromCGRect(contentFrame));
//    
//    //CGSize sizeForBanner = [_adBannerView sizeThatFits:contentFrame.size];
//    CGRect bannerFrame = _adBannerView.frame;
//    //NSLog(@"%@", NSStringFromCGRect(bannerFrame));
//    bannerFrame.origin.y = contentFrame.size.height - self.navigationController.navigationBar.frame.size.height - bannerFrame.size.height;
//    NSLog(@"%@", NSStringFromCGRect(bannerFrame));
//    //bannerFrame.size.height = sizeForBanner.height;
//    //bannerFrame.size.width = sizeForBanner.width;
//    
//    [_adBannerView setFrame:bannerFrame];
//    
//    _adBannerView.delegate = self;
//    [self.view addSubview:_adBannerView];
//    
//    // Google Ad
//    // Create a view of the standard size at the top of the screen.
//    // Available AdSize constants are explained in GADAdSize.h.
//    _googleBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//    
//    // Specify the ad unit ID.
//    _googleBannerView.adUnitID = @"ca-app-pub-5080537428726834/3638663901";
//    _googleBannerView.rootViewController = self;
//    _googleBannerView.alpha = 0;
//    googleAdRequested = NO;
//
//    bannerFrame = _googleBannerView.frame;
//    bannerFrame.origin.y = contentFrame.size.height - self.navigationController.navigationBar.frame.size.height - bannerFrame.size.height;
//    
//    [_googleBannerView setFrame:bannerFrame];
//    
////    [self.view addSubview:_googleBannerView];
//    [_googleBannerView setDelegate:self];
//    //[self showGoogleAd];
    
    // Google Analytics
    [UWGoogleAnalytics analyticScreen:@"More Screen"];
    toManager_tappedTimes = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ad = [UWAds singleton];
    [ad resetAdView:self OriginY:self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - ad.iAdBannerView.frame.size.height - 20];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return @"It's your support \nmakes me do better!";
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else if (section == 1){
        return 3;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *resueIdentifier = @"Value1Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resueIdentifier];
            }
            
            cell.textLabel.text = @"App Version";
            [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
            cell.detailTextLabel.text = [UIApplication appVersion];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        else if (indexPath.row == 1) {
            NSString *resueIdentifier = @"Value1Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resueIdentifier];
            }
            
            cell.textLabel.text = @"Developed by";
            [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
            cell.detailTextLabel.text = @"@zhh358";
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *resueIdentifier = @"CenterCell";
            CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[CenterTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            cell.centerTextLabel.text = @"    Share on ";
            [cell.centerTextLabel setFrame:CGRectMake(10, 15, 280, 24)];
            [cell.centerTextLabel setTextAlignment:NSTextAlignmentLeft];
            
            CGFloat leftX = 115;
            CGFloat buttonSize = 39;
            
            UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX, 8, buttonSize, buttonSize)];
            [facebookButton setBackgroundImage:[UIImage imageNamed:@"uiactivity_facebook"] forState:UIControlStateNormal];
            [facebookButton addTarget:self action:@selector(shareOnFacebook) forControlEvents:UIControlEventTouchUpInside];
            UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 45, 8, buttonSize, buttonSize)];
            [twitterButton setBackgroundImage:[UIImage imageNamed:@"uiactivity_twitter"] forState:UIControlStateNormal];
            [twitterButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 90, 8, buttonSize, buttonSize)];
            [wechatButton setBackgroundImage:[UIImage imageNamed:@"uiactivity_wechat"] forState:UIControlStateNormal];
            [wechatButton addTarget:self action:@selector(shareOnWechat) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 135, 8, buttonSize, buttonSize)];
            [weiboButton setBackgroundImage:[UIImage imageNamed:@"uiactivity_weibo"] forState:UIControlStateNormal];
            [weiboButton addTarget:self action:@selector(shareOnWeibo) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:facebookButton];
            [cell.contentView addSubview:twitterButton];
            [cell.contentView addSubview:wechatButton];
            [cell.contentView addSubview:weiboButton];
            return cell;
        } else if (indexPath.row == 1) {
            NSString *resueIdentifier = @"CenterCell";
            CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[CenterTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            cell.centerTextLabel.text = @"Send me feedback";
            return cell;
        } else if (indexPath.row == 2) {
            NSString *resueIdentifier = @"CenterCell";
            CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[CenterTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            cell.centerTextLabel.text = @"Rate this app 😊";
            return cell;
        }
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    headerLabel.numberOfLines = 0;
    headerLabel.font = [UIFont systemFontOfSize:18];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.textColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    //headerLabel.shadowColor = [UIColor lightGrayColor];
    //headerLabel.shadowOffset = CGSizeMake(0,1);
    //lbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"my_head_bg"]];
    //lbl.alpha = 0.9;
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 55;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
//            [self preformTransitionToViewController:self direction:kCATransitionFromBottom];
            toManager_tappedTimes++;
            NSLog(@"%d", toManager_tappedTimes);
            if (toManager_tappedTimes % 12 == 0) {
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"UW Info Manager Login" message:@"Enter Username & Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                [alert addButtonWithTitle:@"Login"];
                [alert show];
                
            }
            
        } else if (indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/zhh358"]];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showActivityViewController];
        } else if (indexPath.row == 1) {
            FeedbackViewController *newFeedbackVC = [[FeedbackViewController alloc] init];
            MoreNavigationViewController *newMoreNaviVC = [[MoreNavigationViewController alloc] initWithRootViewController:newFeedbackVC];
            [self presentViewController:newMoreNaviVC animated:YES completion:^(){}];
        } else if (indexPath.row == 2) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesRateURLString]];
            [[iRate sharedInstance] openRatingsPageInAppStore];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        UITextField *usernameTextField = [alertView textFieldAtIndex:0];
        UITextField *passwordTextField = [alertView textFieldAtIndex:1];
        NSString *username = usernameTextField.text;
        NSString *password = passwordTextField.text;
        
        if ([username length] >= 1) {
            PFQuery *queryForId = [PFQuery queryWithClassName:@"ManagerUsers"];
            [queryForId whereKey:@"Username" equalTo:username];
            [queryForId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    // no object for this id, query with device name
                    if (objects.count == 0) {
                        [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"Error Manager user: %@, password: %@", username, password]];
                        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"No username matched"
                                                                         message:@""
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles: nil];
                        //                    [alert addButtonWithTitle:@"GOO"];
                        [alert show];
                    }
                    else {
                        for (PFObject *object in objects) {
                            // only one user is matched
                            NSString *passwordFromPase = object[@"Password"];
                            if ([passwordFromPase isEqualToString:password]) {
                                [self showManagerView];
                            }
                            else {
                                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Username/Password doesn't matched"
                                                                                 message:@""
                                                                                delegate:self
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles: nil];
                                //                    [alert addButtonWithTitle:@"GOO"];
                                [alert show];
                            }
                        }
                    }
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Please input at least one character"
                                                             message:@""
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
            //                    [alert addButtonWithTitle:@"GOO"];
            [alert show];
        }
    }
}

- (void)showManagerView {
//    PFQuery *query = [PFQuery queryWithClassName:@"Installation"];
//    //[queryForId whereKey:@"Installation" notEqualTo:nil];
//    [query setLimit: 1000];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            // no object for this id, query with device name
//            if (objects.count == 0) {
//                NSLog(@"found 0 installation");
//            }
//            else {
//                for (PFObject *object in objects) {
//                    NSLog(@"%@", object[@"appName"]);
//                }
//                NSLog(@"Count: %d", [objects count]);
//            }
//        } else {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//    FeedbackViewController *newFeedbackVC = [[FeedbackViewController alloc] init];
//    MoreNavigationViewController *newMoreNaviVC = [[MoreNavigationViewController alloc] initWithRootViewController:newFeedbackVC];
//    [self presentViewController:newMoreNaviVC animated:YES completion:^(){}];
    // Send a notification to all devices subscribed to the "Giants" channel.
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"test"];
    [push setMessage:@"YES! YES! YES!"];
    [push sendPushInBackground];
}

//- (void)preformTransitionToViewController:(UIViewController*)dest direction:(NSString*)direction {
//	//NSLog(@"segue identifier: %@, source: %@, destination: %@", self.identifier, sourceViewController, destinationController);
//
//	CATransition* transition = [CATransition animation];
//	transition.duration = 0.5;
//	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//	transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//	transition.subtype = direction; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//	
////	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.tableView.layer addAnimation:transition forKey:kCATransition];
//	
//	NSMutableArray *stack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//	[stack removeLastObject];
//	[stack addObject:dest];
//	//	  [sourceViewController.navigationController pushViewController:destinationController animated:NO];
//	[self.navigationController setViewControllers:stack animated:NO];
//}

- (void)showActivityViewController {
    NSArray *activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init], [[LINEActivity alloc] init]];
    NSString *postText = sharPostString;
    UIImage *postImage = [UIImage imageNamed:@"AppIcon-Rounded.png"];
    NSURL *postURL = [NSURL URLWithString:itunesShortURLString];
    
    NSArray *activityItems = @[postText, postImage, postURL];
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
     applicationActivities:activity];
    activityController.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}


- (void)shareOnFacebook {
    // Check if the Facebook app is installed and we can present the share dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:itunesURLString];
    params.name = @"UW Info Session";
    params.caption = @"Search, notify and manage your info sessions @ UWaterloo";
    params.picture = [NSURL URLWithString:@"https://scontent-b-ord.xx.fbcdn.net/hphotos-prn1/t1.0-9/10009853_721591927881510_1258200664_n.jpg"];
    params.description = @"Search, notify and manage your info sessions @ UWaterloo.";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:params.name
                                      caption:params.caption
                                  description:params.description
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"UW Info Session", @"name",
                                       @"Search, notify and manage your info sessions @ UWaterloo.", @"caption",
                                       @"Search, notify and manage your info sessions @ UWaterloo.", @"description",
                                       itunesURLString, @"link",
                                       @"https://scontent-b-ord.xx.fbcdn.net/hphotos-prn1/t1.0-9/10009853_721591927881510_1258200664_n.jpg", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          //NSLog(@"%@", [NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              //NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  //NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  //NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  //NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)shareOnTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:sharPostString];
        [composeController addImage:[UIImage imageNamed:@"AppIcon-Rounded.png"]];
        [composeController addURL: [NSURL URLWithString:
                                    itunesShortURLString]];
        
        [self presentViewController:composeController
                           animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareOnWechat {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share to moments", @"Share to friends", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        // share to friends
        [self shareOnWechatTo:WXSceneTimeline];
    } else if (buttonIndex == 1) {
        // share to moments
        [self shareOnWechatTo:WXSceneSession];
    }
    theActionSheet = nil;
}

- (void)shareOnWechatTo:(int)scene {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        // prepare WXMediaMessage
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"UW Info Session";
        message.description = sharPostString;
        [message setThumbImage:[UIImage imageNamed:@"AppIcon-Rounded.png"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = @"http://uw-info.honghaoz.com"; //itunesURLString;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.scene = scene;
        req.message = message;
        
        [WXApi sendReq:req];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't share on Wechat right now, make sure you have installed Wechat."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void)shareOnWeibo {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
    {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        [composeController setInitialText:@"UW Info is a great app to search and manage info sessions #UWaterloo#, check it out!"];
        [composeController addImage:[UIImage imageNamed:@"AppIcon-Rounded.png"]];
        [composeController addURL: [NSURL URLWithString:
                                    itunesShortURLString]];
        
        [self presentViewController:composeController
                           animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a weibo right now, make sure your device has an internet connection and you have at least one Weibo account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Navigation

- (void)done {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

//#pragma mark - iAd delegate methods
//
//- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
//    NSLog(@"iad banner show");
//    NSLog(@"alpha: %f", banner.alpha);
//    [self.view addSubview:_adBannerView];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1];
//    [banner setAlpha:1];
//    
//    [UIView commitAnimations];
//     NSLog(@"alpha: %f", banner.alpha);
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//    [_adBannerView removeFromSuperview];
//    if (_googleBannerView.alpha == 0) {
//        googleAdRequested = NO;
//    }
//    if (googleAdRequested == NO) {
//        GADRequest *request = [GADRequest request];
//        //request.testDevices = [NSArray arrayWithObjects: GAD_SIMULATOR_ID, @"b8ab61a5a3e7e3e252774bab62655fd3", nil];
//        [request setLocationWithDescription:@"N2L3G1 CA"];
//        GADAdMobExtras *extras = [[GADAdMobExtras alloc] init];
//        extras.additionalParameters =
//        [NSMutableDictionary dictionaryWithObjectsAndKeys:
//         @"DDDDDD", @"color_bg",
//         @"999999", @"color_bg_top",
//         @"BBBBBB", @"color_border",
//         @"FF9735", @"color_link",
//         @"999999", @"color_text",
//         @"FF9735", @"color_url",
//         nil];
//        
//        [request registerAdNetworkExtras:extras];
//        [request setKeywords:[NSMutableArray arrayWithObjects:@"UWaterloo", @"Waterloo", @"Job", @"Internship", nil]];
//        [_googleBannerView loadRequest:request];
//        googleAdRequested = YES;
//    }
//    
//    NSLog(@"iad banner show error");
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1];
//    [banner setAlpha:0];
//    
//    
//    [UIView commitAnimations];
//    
//}
//
//#pragma mark - Google Ad delegate methods
//
//- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
//    NSLog(@"google banner show");
//    [self.view addSubview:_googleBannerView];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1];
//    
//    [_googleBannerView setAlpha:1];
//    [UIView commitAnimations];
//    
//}
//
//- (void)adView:(GADBannerView *)bannerView
//didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"google banner show error");
//    [_googleBannerView removeFromSuperview];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1];
//    [bannerView setAlpha:0];
//    
//    [UIView commitAnimations];
//}

@end
