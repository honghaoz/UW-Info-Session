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

@interface MoreViewController () <UIActionSheetDelegate>

@end

@implementation MoreViewController {
    NSString *itunesURLString;
    NSString *itunesShortURLString;
    NSString *appURLString;
    NSString *sharPostString;
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
    itunesShortURLString = @"http://goo.gl/bQyyH0";
    appURLString = @"itms://itunes.apple.com/app/uw-info-session/id837207884?mt=8";
    sharPostString = @"UW Info is a great app to search and manage info sessions #UWaterloo, check it out!";
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
//        if (indexPath.row == 0) {
//            NSString *resueIdentifier = @"AccessoryCell";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
//            }
//            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//            cell.textLabel.text = @"Help";
//            [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
//            return cell;
//        }
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
            cell.centerTextLabel.text = @"     Share on ";
            [cell.centerTextLabel setFrame:CGRectMake(10, 15, 280, 24)];
            [cell.centerTextLabel setTextAlignment:NSTextAlignmentLeft];
            
            CGFloat leftX = 120;
            CGFloat buttonSize = 35;
            
            UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX, 10, buttonSize, buttonSize)];
            [facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
            [facebookButton addTarget:self action:@selector(shareOnFacebook) forControlEvents:UIControlEventTouchUpInside];
            UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 45, 10, buttonSize, buttonSize)];
            [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
            [twitterButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 90, 10, buttonSize, buttonSize)];
            [wechatButton setBackgroundImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
            [wechatButton addTarget:self action:@selector(shareOnWechat) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(leftX + 135, 10, buttonSize, buttonSize)];
            [weiboButton setBackgroundImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
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
            
        } else if (indexPath.row == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/zhh358"]];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showActivityViewController];
        } else if (indexPath.row == 1) {
            FeedbackViewController1 *newFeedbackVC = [[FeedbackViewController1 alloc] init];
            MoreNavigationViewController *newMoreNaviVC = [[MoreNavigationViewController alloc] initWithRootViewController:newFeedbackVC];
            [self presentViewController:newMoreNaviVC animated:YES completion:^(){}];
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURLString]];
        }
    }
}

- (void)showActivityViewController {
    NSString *postText = sharPostString;
    UIImage *postImage = [UIImage imageNamed:@"AppIcon-Rounded.png"];
    NSURL *postURL = [NSURL URLWithString:itunesShortURLString];
    
    NSArray *activityItems = @[postText, postImage, postURL];
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
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
    if ([WXApi isWXAppInstalled]) {
        // prepare WXMediaMessage
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"UW Info Session";
        message.description = sharPostString;
        [message setThumbImage:[UIImage imageNamed:@"AppIcon-Rounded.png"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = itunesURLString;
        
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
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
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

@end