//
//  DetailViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailNormalCell.h"
#import "DetailLinkCell.h"
#import "DetailRSVPCell.h"
#import "DetailDescriptionCell.h"
#import "DetailSwitchCell.h"
#import "UWDetailRSVPCell.h"

#import "InfoSession.h"
#import "InfoSessionModel.h"

#import "AlertViewController.h"

#import "InfoSessionsViewController.h"
#import "MyInfoViewController.h"

#import "LoadingCell.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "UWTabBarController.h"
#import "MapViewController.h"

#import "SVProgressHUD.h"

#import "SearchViewController.h"
#import "PSPDFTextView.h"
#import "UWGoogleAnalytics.h"

#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADAdMobExtras.h"

#import "UWAds.h"
#import "iRate.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "WXApi.h"
#import "WXApiObject.h"

#import "UWShareView.h"
#import "WeixinActivity.h"
#import "LINEActivity.h"
#import "JNJGoogleMapsActivity.h"
#import "TTAppleMapsActivity.h"

#import "NSString+Contain.h"
//#import "PullHeaderView.h"
#import "ZHHPullView.h"
#import "NSString+Contain.h"
#import "UWWebViewController.h"

@interface DetailViewController () <EKEventEditViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, ADBannerViewDelegate, GADBannerViewDelegate/*, ZHHPullViewDelegate*/, NSURLSessionTaskDelegate, UIWebViewDelegate>

@property (nonatomic, strong) DetailDescriptionCell *programCell;
@property (nonatomic, strong) DetailDescriptionCell *descriptionCell;
@property (nonatomic, strong) DetailDescriptionCell *noteCell;
@property (nonatomic, strong) UWWebViewController *webViewVC;

- (IBAction)addToMyInfo:(id)sender;

@end

//static int kObservingContentInsetChangesContext = 1;

@implementation DetailViewController {
    NSInteger noteLines;
    NSInteger cursorIndex;
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    
//    ADBannerView *_adBannerView;
//    GADBannerView *_googleBannerView;
//    BOOL googleAdRequested;
    UWAds *ad;
    // stores latitude and longitude for building
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *building;
    
//    ZHHPullView *nextPullView;
//    ZHHPullView *prevPullView;
//    BOOL isLoading;
    //UIViewController *destinationViewController;
//    UISwitch *registerUISwitch;
    DetailRSVPCell *rsvpCell;
    BOOL haveRegistered;
    BOOL registerSucceed;
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
    NSLog(@"detail view did load start");
    [super viewDidLoad];
    //self.title = @"Details";
    // if caller is Info
    if ([_caller isEqualToString:@"InfoSessionsViewController"] || [_caller isEqualToString:@"SearchViewController"]) {
        _openedMyInfo = NO;
        // backup infoSession in tab1
        _originalInfoSession = _infoSession;
        NSInteger existIndex = [InfoSessionModel findInfoSession:_infoSession in:_infoSessionModel.myInfoSessions];
        if (existIndex != -1) {
            _infoSession = _infoSessionModel.myInfoSessions[existIndex];
            _openedMyInfo = YES;
        }
    } else {
        _openedMyInfo = YES;
    }
    
    [self backupInfoSession];
    [self setBarIcon];
    
    // set tap gesture to resgin first responser
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
//    
//    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
//    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
//    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
    
    
    // set notification for entering background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self.tabBarController showTabBar];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    noteLines = [self getHeightForString:_infoSession.note fontSize:15 width:280];
    
    // Google Analytics
    [UWGoogleAnalytics analyticScreen:@"Detail Screen"];
    
    // because ads exist, need set insets
    [self.tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)];
    
    // set gps info
    latitude = nil;
    longitude = nil;
    if ([_infoSession.location length] > 1) {
        NSRange range = [_infoSession.location rangeOfString:@" "];
        if (range.length == 0) {
            building = [_infoSession.location copy];
        } else {
            building = [_infoSession.location substringToIndex:range.location];
        }
        
        if ([building isEqualToString:@"TC"]) {
            latitude = @(43.469);
            longitude = @(-80.541324);
        } else if ([building isEqualToString:@"SCH"] || [building isEqualToString:@"Laurel"]) {
            building = @"SCH";
            latitude = @(43.46915917);
            longitude = @(-80.5405839);
        } else if ([building isEqualToString:@"DC"]) {
            latitude = @(43.472761);
            longitude = @(-80.542164);
        } else if ([building isEqualToString:@"SLC"]) {
            latitude = @(43.471601);
            longitude = @(-80.545455);
        } else if ([building isEqualToString:@"QNC"]) {
            latitude = @(43.471174);
            longitude = @(-80.544476);
        } else {
            NSLog(@"building: %@!!!!", building);
            NSMutableArray *buildings = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"uw_building" ofType:@"plist"]];
            //NSLog(@"buildings: %d", [buildings count]);
            for (NSDictionary *eachBuilding in buildings) {
                if ([((NSString *)eachBuilding[@"building_code"]) containsString:building] || [((NSString *)eachBuilding[@"alternate_building_names"]) containsString:building]) {
                    //NSLog(@"found %@", building);
                    latitude = [(NSNumber *)eachBuilding[@"latitude"] copy];
                    longitude = [(NSNumber *)eachBuilding[@"longitude"] copy];
                    break;
                }
            }
        }
    }
    
//    // add pull views
//    CGFloat topOffset = self.navigationController.navigationBar.frame.size.height + 20;
//    CGFloat bottomOffset = self.tabBarController.tabBar.frame.size.height;
//    if (nextPullView == nil) {
//        nextPullView = [[ZHHPullView alloc] initWithScrollView:self.tableView arrowImageName:@"blueArrow.png" textColor:[UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0] subtext:@"next article" position:PullBottom withTopOffset:0 andBottomOffset:bottomOffset];
//        nextPullView.delegate = self;
//        [self.tableView addSubview:nextPullView];
//    }
//    if (prevPullView == nil) {
//        prevPullView = [[ZHHPullView alloc] initWithScrollView:self.tableView arrowImageName:@"blueArrow.png" textColor:[UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0] subtext:@"prev article" position:PullTop withTopOffset:topOffset andBottomOffset:0];
//        prevPullView.delegate = self;
//        [self.tableView addSubview:prevPullView];
//    }
//    [nextPullView updateSubtext];
//	[prevPullView updateSubtext];
    
//    [self.tableView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:&kObservingContentInsetChangesContext];
    
    NSLog(@"detail view did load end");
}

- (void)setBarIcon {
    // initiate the right buttons
    UIBarButtonItem *favButton;
    if (_openedMyInfo == NO) {
        favButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoritesButton:)];
    } else {
        favButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star-selected"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoritesButton:)];
    }
    UIBarButtonItem *calButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButton:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar"] style:UIBarButtonItemStylePlain target:self action:@selector(addToCalendar:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:favButton, shareButton, calButton, nil]];
    //[self.navigationItem.rightBarButtonItems]
}

- (void)updateBarIcon {
    if (_openedMyInfo == NO) {
//        UIBarButtonItem *favButton = self.navigationItem.rightBarButtonItems[0];
//        favButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoritesButton:)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoritesButton:)], self.navigationItem.rightBarButtonItems[1], self.navigationItem.rightBarButtonItems[2], nil]];
    } else {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star-selected"] style:UIBarButtonItemStyleBordered target:self action:@selector(favoritesButton:)], self.navigationItem.rightBarButtonItems[1], self.navigationItem.rightBarButtonItems[2], nil]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"detailView will appear start");
    _tabBarController.lastTapped = -1;
    [super viewWillAppear:animated];
    _performedNavigation = @"";
    [self.tableView reloadData];
    [self updateBarIcon];
    ad = [UWAds singleton];
    [ad resetAdView:self OriginY:-30];
    NSLog(@"detailView will appear end");
    _webViewVC.webProgress.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"detaiView did disappear start");
    [super viewWillDisappear:animated];
    //NSLog(@"preformedNavigation: %@", _performedNavigation);
    if ([_performedNavigation isEqualToString:@""]) {
        if ([self.infoSessionBackup isChangedCompareTo:self.infoSession]) {
            [self addToMyInfo:nil];
        }
    }
    NSLog(@"detaiView did disappear end");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) applicationDidEnterBackground {
    [self.noteCell.contentText resignFirstResponder];
    if ([self.infoSessionBackup isChangedCompareTo:self.infoSession]) {
        [self addToMyInfo:nil];
    }
    //[self addToMyInfo:nil];
}

#pragma mark - Calendar related
/**
 *  Calendar button is taped
 *
 *  @param sender calendar button
 */
- (void)addToCalendar:(id)sender {
//    if (_infoSessionModel.eventStore == nil) {
//        NSLog(@"new eventStore is created");
//        _infoSessionModel.eventStore = [[EKEventStore alloc] init];
//    }
    [InfoSession eventStore];
    // Check whether we are authorized to access Calendar
    [self checkEventStoreAccessForCalendar];
    
}

/**
 *  Check the authorization status of our application for Calendar
 */
-(NSInteger)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Turn On Calendars Access to Add Info Sessions" message:@"Go to \"Settings\" -> \"Privacy\" -> \"Calendar\" to enable access."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = -1;
            [alert show];
        }
            break;
        default:
            break;
    }
    return status;
}

/**
 *  Prompt the user for access to their Calendar
 */
-(void)requestCalendarAccess
{
    [[InfoSession eventStore] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             DetailViewController * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Turn On Calendars Access to Add Info Sessions" message:@"Go to \"Settings\" -> \"Privacy\" -> \"Calendar\" to enable access."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];\
             alert.tag = -2;
             [alert show];
         }
     }];
}

/**
 *  This method is called when the user has granted permission to Calendar
 */
-(void)accessGrantedForCalendar
{
    // if this infoSession's calendarId is not nil, use this calendarId to initiate default calendar
    if (_infoSession.calendarId != nil) {
        _infoSessionModel.defaultCalendar = [[InfoSession eventStore] calendarWithIdentifier:_infoSession.calendarId];
    }
    // else if infoSession's calendarId is nil, or defaultCalendar is initiated failed in last if statement
    if (_infoSession.calendarId == nil || _infoSessionModel.defaultCalendar == nil) {
        // Let's get the default calendar associated with our event store
        _infoSessionModel.defaultCalendar = [InfoSession eventStore].defaultCalendarForNewEvents;
    }
    [self showEventEditViewController];
}

/**
 *  Called after accessGrantedForCalendar
 */
- (void)showEventEditViewController {
    // Create an instance of EKEventEditViewController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    // changed UI to meet this app's style
    [addController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]];
    addController.navigationBar.tintColor = [UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1];
    
    // Set addController's event store to the current event store
    addController.eventStore = [InfoSession eventStore];
    
    // creat a new event
    EKEvent *event = [EKEvent eventWithEventStore:[InfoSession eventStore]];
    
    // if ekEvent and eventId all are nil, then this event is not saved,
    // try to fetch the event according the startDate and endDate and title ...
    if (_infoSession.ekEvent == nil && _infoSession.eventId == nil) {
        _infoSession.ekEvent = [self fetchEventAccordingStartDate:_infoSession.startTime andEndDate:_infoSession.endTime];
    }
    // if ekEvent is nil but eventId is not nil, then this event is saved and restore from file
    // try to fetch the event with eventId.
    else if (_infoSession.ekEvent == nil && _infoSession.eventId != nil) {
        // fetch the event according the infosession's eventId
        _infoSession.ekEvent = [self fetchEventWithId:_infoSession.eventId];
    }
    else if (_infoSession.ekEvent != nil && _infoSession.eventId != nil) {
        
    } else {
    }
    
    // if infosession's event is nil or refresh failed (means this event is deleted)
    if (_infoSession.ekEvent == nil || ![_infoSession.ekEvent refresh]) {
        if (_infoSession.ekEvent == nil) {
        } else if (![_infoSession.ekEvent refresh]) {
            
        }
        [event setTitle:_infoSession.employer];
        [event setLocation:_infoSession.location];
        [event setStartDate:_infoSession.startTime];
        [event setEndDate:_infoSession.endTime];
        [event setAlarms:[_infoSession getEKAlarms]];
        [event setURL:[NSURL URLWithString:_infoSession.website]];
        [event setNotes:_infoSession.note];
        
        [event setCalendar:_infoSessionModel.defaultCalendar];
    }
    // infosession's event already exists
    else {
        event = _infoSession.ekEvent;
    }
    
    addController.event = event;
    addController.editViewDelegate = self;
    self.performedNavigation = @"addCalendarEvent";
    [self presentViewController:addController animated:YES completion:nil];
}

/**
 *  Fetch the event with eventIdentifier
 *
 *  @param eventId EKEvent eventIdentifier
 *
 *  @return the event if exsit, else nil
 */
- (EKEvent *)fetchEventWithId:(NSString *)eventId {
    return [[InfoSession eventStore] eventWithIdentifier:eventId];
}

/**
 *  Fetch the event is between this infoSession's startTime and endTime and title == employer
 *
 *  @param startDate NSDate startTime
 *  @param endDate   NSDate endTime
 *
 *  @return the EKEvent meet the predicater or nil if not found.
 */
- (EKEvent *)fetchEventAccordingStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    NSPredicate *predicate = [[InfoSession eventStore] predicateForEventsWithStartDate:startDate
                                                            endDate:endDate
                                                          calendars:nil];
    NSArray *events = [[InfoSession eventStore] eventsMatchingPredicate:predicate];
    EKEvent *theEvent = nil;
    for (EKEvent *eachEvent in events) {
        if ([eachEvent.title isEqualToString:_infoSession.employer]) {
            theEvent = eachEvent;
            break;
        }
    }
    return theEvent;
}

/**
 *  EventEditViewController delegate method
 *
 *  @param controller EKEventEditViewController
 *  @param action     this
 */
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
    if (action == EKEventEditViewActionCanceled) {
    }
    else if (action == EKEventEditViewActionSaved) {
        _infoSession.ekEvent = controller.event;
        _infoSession.calendarId = [controller.event.calendar calendarIdentifier];
        _infoSession.eventId = [controller.event eventIdentifier];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:_eventStore];
    } else if (action == EKEventEditViewActionDeleted) {
        _infoSession.ekEvent = nil;
        _infoSession.calendarId = nil;
        _infoSession.eventId = nil;
        //NSLog(@"Deleted edited");
    }
    [self backupInfoSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

///**
// *  Notification Handler, used handle eventStore is changed
// *
// *  @param sender Send?
// */
//-(void)storeChanged:(id)sender {
//    NSLog(@"event store changed");
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // if showing infoSession is deleted, then pop up
//    if (_infoSessionBackup == nil) {
//        NSLog(@"pop up");
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    if (_openedMyInfo == YES) {
        return 5;
    } else {
        return 4;
    }
}

/**
 *  Return the number of rows in the section.
 *
 *  @param tableView UITableView
 *  @param section   NSInteger
 *
 *  @return the number of rows in the section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0: numberOfRows = 5; break;
        case 1:{
            // if switch is ON
            if (_infoSession.alertIsOn == YES) {
                // if # of alerts is not full, show "add more alert" row
                if (![_infoSession alertsIsFull]) {
                    numberOfRows = 1 + [_infoSession.alerts count] + 1;
                }
                // if # of alerts is full, do not show "add more alert" row
                else {
                    numberOfRows = 1 + [_infoSession.alerts count];
                }
            }
            // if switch is OFF
            else {
                numberOfRows = 1;
            }
            break;
        }
        case 2: numberOfRows = 4; break;
        case 3: numberOfRows = 1; break;
        case 4: numberOfRows = 1; break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DetailNormalCell *cell = (DetailNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Employer";
            cell.contentLabel.text = _infoSession.employer;
            NSLog(@"cell: %@", cell.contentLabel.text);
            return cell;
        }
        else if (indexPath.row == 1) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            if (cell == nil) {
                cell = [[DetailNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailNormalCell"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Date";
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            [dateFormatter setLocale:enUSPOSIXLocale];
            NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
            [dateFormatter setDateFormat:@"cccc, MMM d, y"];
            // set timezone to EST
            //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
            cell.contentLabel.text = [dateFormatter stringFromDate:_infoSession.date];
            return cell;
        }
        else if (indexPath.row == 2) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Time";
//            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            [timeFormatter setLocale:enUSPOSIXLocale];
            NSDateFormatter *timeFormatter = [InfoSession estDateFormatter];
            [timeFormatter setDateFormat:@"h:mm a"];
            // set timezone to EST
            //[timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
            cell.contentLabel.text = [NSString stringWithFormat:@"%@ - %@", [timeFormatter stringFromDate:_infoSession.startTime], [timeFormatter stringFromDate:_infoSession.endTime]];
            return cell;
        }
        else if (indexPath.row == 3) {
            DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [cell.contentLabel setFont:[UIFont systemFontOfSize:16]];
            cell.titleLabel.text = @"Location";
            if ([_infoSession.location length] <= 1) {
                [cell.contentLabel setTextColor: [UIColor lightGrayColor]];
                cell.contentLabel.text = @"No Location Provided";
                return cell;
            } else {
                [cell.contentLabel setTextColor: [UIColor blackColor]];
                cell.contentLabel.text = _infoSession.location;
                return cell;
            }
        }
        else if (indexPath.row == 4) {
            DetailRSVPCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailRSVPCell"];
//            UWDetailRSVPCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UWDetailRSVPCell"];
//            if (cell == nil) {
//                cell = [[UWDetailRSVPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UWDetailRSVPCell"];
//            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (_infoSession.sessionId > 10 && [_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell.contentLabel setTextColor: [UIColor darkGrayColor]];
//                cell.statusSiwtch.enabled = YES;
                if (!haveRegistered) {
                    cell.contentLabel.text = @"Tap here to Register";
                } else {
                    if (registerSucceed) {
                        cell.contentLabel.text = @"Register Succeed!";
                    } else {
                        cell.contentLabel.text = @"Register Failed!";
                    }
                }
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentLabel setTextColor: [UIColor lightGrayColor]];
                cell.contentLabel.text = @"Not Available to Register";
//                cell.statusSiwtch.enabled = NO;
            }
//            [cell.statusSiwtch addTarget:self action:@selector(registerInfoSwitch:) forControlEvents:UIControlEventTouchUpInside];
//            registerUISwitch = cell.statusSiwtch;
            rsvpCell = cell;
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        if (_infoSession.alertIsOn == YES) {
            // the alert switch row
            if (indexPath.row == 0) {
                DetailSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailSwitchCell"];
                cell.remindSwitch.tintColor = [UIColor lightGrayColor];
                cell.remindSwitch.onTintColor = UWGold;
                //cell.remindSwitch.thumbTintColor = [UIColor redColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.remindSwitch addTarget:self action:@selector(didSwitchChange:) forControlEvents:UIControlEventValueChanged];
                [cell.remindSwitch setOn:YES animated:YES];
                
                // if this infoSession is in the future, can turn on siwtch
                
                if ([_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
                    [cell.remindSwitch setEnabled:YES];
                } else {
                    [cell.remindSwitch setEnabled:NO];
                }
                
                if (_infoSession.isCancelled) {
                    [cell.remindSwitch setEnabled:NO];
                }
                return cell;
            }
            // the last row, add more alert
            else if (indexPath.row == [_infoSession.alerts count] + 1) {
                LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddAlertCell"];
                cell.loadingLabel.text = @"Add more alert";
                [cell.loadingLabel setTextColor:[UIColor darkGrayColor]];
                return cell;
            }
            // alert item rows
            else {
                DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
                [cell.contentLabel setFont:[UIFont systemFontOfSize:16]];
                [cell.contentLabel setTextColor: [UIColor blackColor]];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
                NSMutableDictionary *theAlert = _infoSession.alerts[indexPath.row - 1];
                
                cell.titleLabel.text = [InfoSession getAlertSequence:[NSNumber numberWithInteger:indexPath.row]];
                cell.contentLabel.text = [InfoSession getAlertDescription:theAlert[@"alertChoice"]];
                return cell;
            }
        } else {
            DetailSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailSwitchCell"];
            cell.remindSwitch.onTintColor = UWGold;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.remindSwitch addTarget:self action:@selector(didSwitchChange:) forControlEvents:UIControlEventValueChanged];
            [cell.remindSwitch setOn:NO animated:YES];
            // if this infoSession is in the future, can turn on siwtch
            if ([_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending &&
                _infoSession.isCancelled == NO) {
                [cell.remindSwitch setEnabled:YES];
            } else {
                [cell.remindSwitch setEnabled:NO];
            }
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.titleLabel.text = @"Website";
            if ([_infoSession.website length] <= 7) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentLabel setFont:[UIFont systemFontOfSize:16]];
                [cell.contentLabel setTextColor: [UIColor lightGrayColor]];
                cell.contentLabel.text = @"No Website Provided";
                return cell;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell.contentLabel setFont:[UIFont systemFontOfSize:15]];
                [cell.contentLabel setTextColor: [UIColor blackColor]];
                cell.contentLabel.text = [_infoSession.website substringFromIndex:7];
//                CGFloat calculatedHeight = [self getHeightForString:_infoSession.website fontSize:15 width:240];
                // text line = 1
//                if (calculatedHeight < 37.0f) {
//                    //height = 42.0f;
//                    cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x, (42 - 21), cell.titleLabel.frame.size.width, cell.titleLabel.frame.size.height);
//                } else if (calculatedHeight < 56.0f) {
//                    // text line = 2
//                    //height = 58.0f;
//                    cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x, (58 - 21), cell.titleLabel.frame.size.width, cell.titleLabel.frame.size.height);
//                }
                return cell;
            }
        }
        else if (indexPath.row == 1){
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Students";
            cell.contentLabel.text = _infoSession.audience;
            return cell;
        }
        else if (indexPath.row == 2) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentText setSelectable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            [cell.contentText setSelectable:NO];
            cell.titleLabel.text = @"Programs";
            
            if ([_infoSession.programs length] <= 1) {
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
                cell.contentText.text = @"No Programs Infomation";
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                textViewFrame.size.height = [self getHeightForString:@"No Programs Infomation" fontSize:15 width:280];
                cell.contentText.frame = textViewFrame;
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.programs;
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                CGFloat calculatedHeight = [self getHeightForString:_infoSession.programs fontSize:15 width:280];
                if (calculatedHeight > 240) {
                    textViewFrame.size.height = 240;
                    [cell.contentText setScrollEnabled:YES];
                } else {
                    textViewFrame.size.height = calculatedHeight;
                    [cell.contentText setScrollEnabled:NO];
                }
                
                cell.contentText.frame = textViewFrame;
            }
            self.programCell = cell;
            [self.programCell.contentText setDelegate:self];
            return cell;
        }
        else if (indexPath.row == 3) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentText setSelectable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            [cell.contentText setSelectable:NO];
            cell.titleLabel.text = @"Descriptions";
            if ([_infoSession.description length] <= 1) {
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
                cell.contentText.text = @"No Descriptions";
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                textViewFrame.size.height = [self getHeightForString:@"No Descriptions" fontSize:15 width:280];
                cell.contentText.frame = textViewFrame;
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.description;
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                CGFloat calculatedHeight = [self getHeightForString:_infoSession.description fontSize:15 width:280];
                NSLog(@"cal height: %0.0f", calculatedHeight);
                if (calculatedHeight > 243.0f) {
                    textViewFrame.size.height = 243;
                    [cell.contentText setScrollEnabled:YES];
                } else {
                    textViewFrame.size.height = calculatedHeight;
                    [cell.contentText setScrollEnabled:NO];
                }
                cell.contentText.frame = textViewFrame;
                NSLog(@"%@", NSStringFromCGRect(cell.contentText.frame));
            }
            self.descriptionCell = cell;
            [self.descriptionCell.contentText setDelegate:self];
            return cell;
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Notes";
            [cell.contentText setSelectable:YES];
            [cell.contentText setEditable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            [cell.contentText setScrollEnabled:NO];
            if (_infoSession.note == nil || [_infoSession.note length] == 0) {
                cell.contentText.text = @"Take some notes here.";
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
            } else {
                cell.contentText.text = _infoSession.note;
                [cell.contentText setTextColor: [UIColor blackColor]];

            }
            // resize textView height
            CGRect textViewFrame = cell.contentText.frame;
            textViewFrame.size.height = [self getHeightForString:_infoSession.note fontSize:15 width:280];
            cell.contentText.frame = textViewFrame;
            
            self.noteCell = cell;
            [self.noteCell.contentText setDelegate:self];
            return cell;
        }
    }
    else if (indexPath.section == 4){
        if (indexPath.row == 0) {
            LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddAlertCell"];
            cell.loadingLabel.text = @"Delete From My Info Sessions";
            [cell.loadingLabel setTextColor:[UIColor redColor]];
            return cell;
        }
    }
    return nil;
}

/**
 *  set different cell height for different cell
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 *
 *  @return for LoadingCell, return 44.0f, for InfoSessionCell, return 72.0f
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    // use UITextView to calculate height of this label
                    CGFloat calculatedHeight = [self getHeightForString:_infoSession.employer fontSize:16 width:200];
                    // text line = 1
                    if (calculatedHeight < 37.0f) {
                        height = 42.0f;
                    } else if (calculatedHeight < 56.0f) {
                        // text line = 2
                        height = 58.0f;
                    } else if (calculatedHeight < 75.0f) {
                        // text line = 3
                        height = 74.0f;
                        // text line = 4
                    } else {
                        height = 90.0f;
                        // text line = 5
                    }
                    break;
                }
                case 1: height = 42.0f; break;
                case 2: height = 42.0f; break;
                case 3: {
                    // use UITextView to calculate height of this label
                    CGFloat calculatedHeight = [self getHeightForString:_infoSession.location fontSize:16 width:200];
                    
                    // text line = 1
                    if (calculatedHeight < 37.0f) {
                        height = 42.0f;
                    } else if (calculatedHeight < 56.0f) {
                        // text line = 2
                        height = 58.0f;
                    } else if (calculatedHeight < 75.0f) {
                        // text line = 3
                        height = 74.0f;
                        // text line = 4
                    } else if (calculatedHeight < 94.0f) {
                        height = 90.0f;
                        // text line = 5
                    } else {
                        height = 106.0f;
                    }
                    break;
                }
                case 4: height = 42.0f; break;
            } break;
        case 1: height = 42.0f; break;
        case 2:
            switch (indexPath.row) {
                case 0: {
                    CGFloat calculatedHeight;
                    if ([_infoSession.website length] <= 7) {
                         calculatedHeight = [self getHeightForString:@"No Website Provided" fontSize:16 width:230];
                    } else {
                        calculatedHeight = [self getHeightForString:_infoSession.website fontSize:15 width:240];
                    }
                    // text line = 1
                    if (calculatedHeight < 37.0f) {
                        height = 42.0f;
                    } else if (calculatedHeight < 56.0f) {
                        // text line = 2
                        height = 58.0f;
                    } else if (calculatedHeight < 75.0f) {
                        // text line = 3
                        height = 74.0f;
                        // text line = 4
                    } else if (calculatedHeight < 94.0f) {
                        height = 90.0f;
                        // text line = 5
                    } else {
                        height = 106.0f;
                    }
                    NSLog(@"height: %f", height);
                    break;
                }
                case 1: {
                    // use UITextView to calculate height of this label
                    CGFloat calculatedHeight = [self getHeightForString:_infoSession.audience fontSize:16 width:200];
                    
                    // text line = 1
                    if (calculatedHeight < 37.0f) {
                        height = 42.0f;
                    } else if (calculatedHeight < 56.0f) {
                        // text line = 2
                        height = 58.0f;
                    } else if (calculatedHeight < 75.0f) {
                        // text line = 3
                        height = 74.0f;
                        // text line = 4
                    } else if (calculatedHeight < 94.0f) {
                        height = 90.0f;
                        // text line = 5
                    } else {
                        height = 106.0f;
                    }
                    break;
                }
                case 2: {
                    CGFloat calculatedHeight = [self getHeightForString:_infoSession.programs fontSize:15 width:280];
                    //NSLog(_infoSession.programs);
                    if (calculatedHeight > 240) {
                        height = 240.0f + 55.0f;
                    } else {
                        height = calculatedHeight + 45.0f;
                    }
                    break;
                }
                case 3: {
                    CGFloat calculatedHeight = [self getHeightForString:_infoSession.description fontSize:15 width:280];
                    //NSLog(_infoSession.programs);
                    if (calculatedHeight > 240) {
                        height = 240.0f + 60.0f;
                    } else {
                        height = calculatedHeight + 50.0f;
                    }
                    break;
                }
            } break;
        case 3:
            switch (indexPath.row) {
                case 0: {
                    UITextView *calculationView = [[UITextView alloc] init];
                    if (_infoSession.note == nil || [_infoSession.note length] == 0) {
                        [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:@"Take some notes here."]];
                    } else {
                        [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:_infoSession.note]];
                    }
                    [calculationView setFont:[UIFont systemFontOfSize:15]];
                    CGSize size = [calculationView sizeThatFits:CGSizeMake(280.0f, FLT_MAX)];
                    
                    height = size.height + 50.0f;
                    
                    break;
                }
            } break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    height = 42.0f; break;
            } break;
    }
    return height;
}

- (CGFloat)getHeightForString:(NSString *)string fontSize:(CGFloat)fontSize width:(CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:string == nil? @"" : string]];
    [calculationView setFont:[UIFont systemFontOfSize:fontSize]];
    return [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)].height;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            if ([_infoSession.location length] <= 1) {
                return NO;
            }
        } else if (indexPath.row == 4) {
            return NO;
        }
    } else if (indexPath.section == 1) {
        return NO;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if ([_infoSession.website length] <= 7) {
                return NO;
            }
        } else if (indexPath.row == 2) {
            if ([_infoSession.programs length] <= 1) {
                return NO;
            }
        } else if (indexPath.row == 3) {
            if ([_infoSession.description length] <= 1) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        NSLog(@"%d, %d", indexPath.section, indexPath.row);
        if (indexPath.section == 0) {
            NSLog(@"copy");
            if (indexPath.row == 0) {
                [UIPasteboard generalPasteboard].string = _infoSession.employer;
                NSLog(@"%@", _infoSession.employer);
            } else if (indexPath.row == 1 || indexPath.row == 2) {
                NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
                [dateFormatter setDateFormat:@"cccc, MMM d, y"];
                NSDateFormatter *timeFormatter = [InfoSession estDateFormatter];
                [timeFormatter setDateFormat:@"h:mm a"];
                
                [UIPasteboard generalPasteboard].string = [[dateFormatter stringFromDate:_infoSession.date] stringByAppendingString:[NSString stringWithFormat:@" %@ - %@", [timeFormatter stringFromDate:_infoSession.startTime], [timeFormatter stringFromDate:_infoSession.endTime]]];
                NSLog(@"time");
            } else if (indexPath.row == 3) {
                [UIPasteboard generalPasteboard].string = _infoSession.location;
                NSLog(@"%@", _infoSession.location);
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                [UIPasteboard generalPasteboard].string = _infoSession.website;
                NSLog(@"%@", _infoSession.website);
            } else if (indexPath.row == 1) {
                [UIPasteboard generalPasteboard].string = _infoSession.audience;
                NSLog(@"%@", _infoSession.audience);
            } else if (indexPath.row == 2) {
                [UIPasteboard generalPasteboard].string = _infoSession.programs;
                NSLog(@"%@", _infoSession.programs);
            } else if (indexPath.row == 3) {
                [UIPasteboard generalPasteboard].string = _infoSession.description;
                NSLog(@"%@", _infoSession.description);
            }
        }
    }
}

#pragma mark - Table view delegate
/**
 *  select row at indexPath
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            [self performSegueWithIdentifier:@"ShowMap" sender:nil];
        } else if (indexPath.row == 4 && _infoSession.sessionId > 10) {
            if (_infoSession.sessionId > 10 && [_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
                [self registerInfoSession];
            } else {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
                [SVProgressHUD showErrorWithStatus:@"Register not available!"];
            }
//            NSURL *websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=%@&mode=on", [NSString stringWithFormat:@"%lu", (unsigned long)_infoSession.sessionId]]];
//            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
//            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 300, 300, 300)];
//            [webView loadRequest:urlRequest];
//            [self.tableView addSubview:webView];
            
            //NSURL *URL = [NSURL URLWithString:websiteUrl];
//            NSURLRequest *request = [NSURLRequest requestWithURL:websiteUrl
//                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                 timeoutInterval:30.0];
//            
//            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//            [connection start];
        }
    }
    // select alert section
    else if (indexPath.section == 1) {
        if (_infoSession.isCancelled || !([_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending)) {
//            [ProgressHUD showError:@"Reminder not available!" Interacton:YES];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
            [SVProgressHUD showErrorWithStatus:@"Reminder not available!"];
        } else {
            // select alert setting rows
            if (1 <= indexPath.row && indexPath.row <= [_infoSession.alerts count]) {
                [self performSegueWithIdentifier:@"ShowAlert" sender:indexPath];
            }
            // select "add more alert" row
            else if (indexPath.row == [_infoSession.alerts count] + 1) {
                
                [_infoSession addOneAlert];
                
                NSMutableArray *indexPathToInsert = [[NSMutableArray alloc] init];
                [indexPathToInsert addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
                if (![_infoSession alertsIsFull]) {
                    // add new alert item and need to insert this new row
                    [self.tableView insertRowsAtIndexPaths:indexPathToInsert withRowAnimation:UITableViewRowAnimationBottom];
                }
                else {
                    // add new alert item and need to insert this new row, if alerts is full, replace the "add" row
                    [self.tableView reloadRowsAtIndexPaths:indexPathToInsert withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0 && [_infoSession.website length] > 7) {

            _webViewVC = [[UWWebViewController alloc] init];
            NSString *webURL = [@"http://" stringByAppendingString:[[_infoSession.website substringFromIndex:7] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            //NSLog(@"%@", webURL);
            _webViewVC.URL = [NSURL URLWithString:webURL];
            //NSLog(@"%@", _webViewVC.URL);
            _webViewVC.webView.delegate = self;
            [self.navigationController pushViewController:_webViewVC animated:YES];
        }
    }
    // select note section
    else if (indexPath.section == 3) {
        NSLog(@"did select note");
        [self.noteCell.contentText becomeFirstResponder];
    }
    else if (indexPath.section == 4) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete Info Session", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma makr - NSURLSession delegate methods

- (void)setUsernameAndPassword {
    NSLog(@"set username");
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"WatIAM Authentication" message:@"Enter Username & Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert addButtonWithTitle:@"Login"];
    alert.tag = 2;
    [alert show];
}

- (BOOL)checkUsernameAndPassword {
    if (_infoSessionModel.uwValid) {
        NSLog(@"valid");
        return YES;
    } else {
        NSLog(@"not valid");
        return NO;
    }
}

- (void)registerInfoSession {
    BOOL usernamePasswordState = [self checkUsernameAndPassword];
    if (!usernamePasswordState) {
        [self setUsernameAndPassword];
    } else {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=%@&mode=on", [NSString stringWithFormat:@"%lu", (unsigned long)_infoSession.sessionId]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        sessionConfig.timeoutIntervalForRequest = 10;
        sessionConfig.timeoutIntervalForResource = 10;
        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;//NSHTTPCookieAcceptPolicyAlways;
        //NSURLSession *session = [NSURLSession sharedSession];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        //NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          NSLog(@"%@", response);
//                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//                                          NSInteger responseStatusCode = [httpResponse statusCode];
//                                          if (responseStatusCode == 200) {
                                              //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                              BOOL result = [self checkResponse:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                              NSLog(@"%@", result? @"YES" : @"NO");
                                              if (!result) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      haveRegistered = YES;
                                                      registerSucceed = NO;
                                                      _infoSessionModel.uwValid = NO;
                                                      rsvpCell.contentLabel.text = @"Register Failed!";
                                                      [SVProgressHUD setAnimationDuration:3];
                                                      [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
                                                      [SVProgressHUD showErrorWithStatus:@"Register Failed!"];
                                                      double delayInSeconds = 1.5;
                                                      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                                      dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                          //code to be executed on the main queue after delay
                                                          [self setUsernameAndPassword];
                                                      });
                                                      
                                                  });
                                              } else {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      haveRegistered = YES;
                                                      registerSucceed = YES;
                                                      _infoSessionModel.uwValid = YES;
                                                      rsvpCell.contentLabel.text = @"Register Succeed!";
                                                      [SVProgressHUD setAnimationDuration:3];
                                                      [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
                                                      [SVProgressHUD showSuccessWithStatus:@"Register Succeed!"];
                                                  });
                                              }
//                                          } else {
//                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                  [SVProgressHUD setAnimationDuration:3];
//                                                  [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
//                                                  [SVProgressHUD showErrorWithStatus:@"Network Error"];
//                                              });
//                                          }
                                      }];
        [task resume];
    }
}

//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    if (challenge.previousFailureCount == 0)
//    {
//        NSLog(@"received authentication challenge");
//        NSURLCredentialPersistence persistence = NSURLCredentialPersistenceForSession;
//        NSURLCredential *credential = [NSURLCredential credentialWithUser:_infoSessionModel.uwUsername password:_infoSessionModel.uwPassword persistence:persistence];
//        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//    }
//    else
//    {
//        // handle the fact that the previous attempt failed
//        NSLog(@"%s: challenge.error = %@", __FUNCTION__, challenge.error);
//        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
//    }
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    {
        if (challenge.previousFailureCount == 0)
        {
            NSLog(@"received authentication challenge task");
            NSURLCredential *credential = [NSURLCredential  credentialWithUser:_infoSessionModel.uwUsername password:_infoSessionModel.uwPassword persistence:NSURLCredentialPersistenceForSession];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else
        {
            // user name error
            NSLog(@"%s; challenge.error = %@", __FUNCTION__, challenge.error);
            _infoSessionModel.uwValid = NO;
            //[self setUsernameAndPassword];
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        
    }
}
#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    _webViewVC.webProgress.hidden = NO;
    [_webViewVC setProgressBar:0.35];
    // Delay execution of my block for 10 seconds.
    
    for (int i = 5; i < 50; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [_webViewVC setProgressBar:_webViewVC.webProgress.progress + 0.0001 * (51 - i)];
        });
    }
    
    [_webViewVC.navigationItem setTitle:_infoSession.employer];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(9, 0, 20, 20);
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
    [refreshView addSubview:activityView];
    //NSLog(@"%@", NSStringFromCGRect(activityView.frame));
    
    //[activityView sizeToFit];
    [activityView startAnimating];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:refreshView];
    [_webViewVC.navigationItem setRightBarButtonItem:loadingView animated:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    LogMethod;
    [_webViewVC setProgressBar:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _webViewVC.webProgress.hidden = YES;
        [_webViewVC.webProgress setProgress:0];
    });
    
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [_webViewVC.navigationItem setTitle:theTitle];
    
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Previous"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    UIBarButtonItem *goForward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Next"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(webViewReload:)];
    [_webViewVC.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:refresh, goForward, goBack , nil] animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)goBack:(id)sender {
    LogMethod;
    [_webViewVC.webView goBack];
}

- (void)goForward:(id)sender {
    LogMethod;
    [_webViewVC.webView goForward];
}

- (void)webViewReload:(id)sender {
    LogMethod;
    [_webViewVC.webView reload];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    LogMethod;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 0 && buttonIndex == 0) {
//        _performedNavigation = @"OpenRSVPLink";
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=%@&mode=on", [NSString stringWithFormat:@"%lu", (unsigned long)_infoSession.sessionId]]]];
//    }
//    else if (alertView.tag == 1 && buttonIndex == 0) {
//        _performedNavigation = @"OpenWebsiteLink";
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_infoSession.website]];
//    }
//    else
    if (alertView.tag == 2 && buttonIndex == 1) {
        UITextField *usernameTextField = [alertView textFieldAtIndex:0];
        UITextField *passwordTextField = [alertView textFieldAtIndex:1];
        NSString *username = usernameTextField.text;
        NSString *password = passwordTextField.text;
        NSLog(@"%@ %@", username, password);
        _infoSessionModel.uwUsername = username;
        _infoSessionModel.uwPassword = password;
        _infoSessionModel.uwValid = YES;
        [_infoSessionModel saveInfoSessions];
//        [self registerInfo:YES];
        [self registerInfoSession];
    }
    else if (alertView.tag == 2 && buttonIndex == 0) {
        //[registerUISwitch setOn:NO animated:YES];
        //[self registerInfoSession];
    }
}

#pragma mark - UIUIActionSheetDelegate 

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (id actionSheetSubview in actionSheet.subviews) {
        if ([actionSheetSubview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)actionSheetSubview;
            if ([button.titleLabel.text isEqualToString:@"Delete Info Session"]) {
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //[self takePhoto];
        [self deleteOperation:nil];
    }
    theActionSheet = nil;
}

/**
 *  Delete infoSession from myInfoSessions
 *
 *  @param sender none
 */
- (void)deleteOperation:(id)sender {
    NSString *senderClass = NSStringFromClass([sender class]);
    if ([_infoSessionModel deleteInfoSessionInMyInfo:_infoSession] == UWDeleted) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.performedNavigation = @"DeleteInfoSession";
            if (![NSStringFromClass([sender class]) isEqualToString:@"UIBarButtonItem"] || ([_caller isEqualToString:@"MyInfoViewController"])) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }completion:^(BOOL finished) {
            InfoSession *infoSessionDeleted = _infoSession;
            if ([senderClass isEqualToString:@"UIBarButtonItem"]) {
                // restore to original info session
                _infoSession = _originalInfoSession;
                _openedMyInfo = NO;
                [self updateBarIcon];
                [self.tableView reloadData];
                [self backupInfoSession];
            }
            // set badge for second barItem
            [_tabBarController setBadge];
            _infoSessionBackup = nil;
            
            // if deletion operation is commited in MyInfoVC
            if ([_caller isEqualToString:@"MyInfoViewController"]) {
                // if caller is MyInfoViewController, after pop up, need reload data
                [_tabBarController.myInfoViewController reloadTable];
                
                UINavigationController *infoSessionVCNavigationController = self.tabBarController.infoSessionsViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([infoSessionVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = infoSessionVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        // get the tabbar item0's detailViewController
                        DetailViewController *detailController = (DetailViewController *)controller;
                        // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            NSLog(@"tab1->tab0");
                            //if ([senderClass isEqualToString:@"UIBarButtonItem"]) {
                            detailController.infoSession = detailController.originalInfoSession;
                            detailController.openedMyInfo = NO;
                            //} else {
                              //  detailController.infoSessionBackup = nil;
                            //}
                        }
                    }
                }
                
                UINavigationController *searchVCNavigationController = self.tabBarController.searchViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([searchVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = searchVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        // get the tabbar item0's detailViewController
                        DetailViewController *detailController = (DetailViewController *)controller;
                        // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            NSLog(@"tab1->tab2");
                            detailController.infoSession = detailController.originalInfoSession;
                            detailController.openedMyInfo = NO;
//                            if ([senderClass isEqualToString:@"UIBarButtonItem"]) {
//                                detailController.infoSession = detailController.originalInfoSession;
//                                detailController.openedMyInfo = NO;
//                            } else {
//                                detailController.infoSessionBackup = nil;
//                            }
                        }
                    }
                }
            } else if ([_caller isEqualToString:@"InfoSessionsViewController"]) {
                UINavigationController *myInfoVCNavigationController = self.tabBarController.myInfoViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([myInfoVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = myInfoVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        DetailViewController *detailController = (DetailViewController *)controller;
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            NSLog(@"tab0->tab1");
                            detailController.infoSessionBackup = nil;
                            [myInfoVCNavigationController popViewControllerAnimated:NO];
                        }
                    }
                }
                
                UINavigationController *searchVCNavigationController = self.tabBarController.searchViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([searchVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = searchVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        // get the tabbar item0's detailViewController
                        DetailViewController *detailController = (DetailViewController *)controller;
                        // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            NSLog(@"tab0->tab2");
                            detailController.infoSession = detailController.originalInfoSession;
                            detailController.openedMyInfo = NO;
//                            detailController.infoSessionBackup = nil;
                        }
                    }
                }
            } else if ([_caller isEqualToString:@"SearchViewController"]) {
                
                UINavigationController *infoSessionVCNavigationController = self.tabBarController.infoSessionsViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([infoSessionVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = infoSessionVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        // get the tabbar item0's detailViewController
                        DetailViewController *detailController = (DetailViewController *)controller;
                        // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            NSLog(@"tab2->tab0");
                            detailController.infoSession = detailController.originalInfoSession;
                            detailController.openedMyInfo = NO;
                            //detailController.infoSessionBackup = nil;
                        }
                    }
                }
                
                UINavigationController *myInfoVCNavigationController = self.tabBarController.myInfoViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([myInfoVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = myInfoVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        DetailViewController *detailController = (DetailViewController *)controller;
                        if ([infoSessionDeleted isEqual:detailController.infoSession]) {
                            detailController.infoSessionBackup = nil;
                            [myInfoVCNavigationController popViewControllerAnimated:NO];
                        }
                    }
                }
            }
        }];
        // save to file
        [_infoSessionModel saveInfoSessions];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITextView Delegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _infoSession.note = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self updateNoteCellHeight];
    return YES;
}

//- (void)textViewDidChange:(UITextView *)textView {
//}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // set note cell is not scrollable
    [textView setScrollEnabled:NO];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // set note cell is scrollable
    [textView setScrollEnabled:YES];
    if (_infoSession.note == nil || [_infoSession.note length] == 0) {
        textView.text = @"";
        //NSLog(@"  textview changed: %@", textView.text);
    }
    // set note text is black color
    [self.noteCell.contentText setTextColor: [UIColor blackColor]];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    // set cursorIndex and scroll to right rect
    cursorIndex = textView.selectedRange.location;
    [self scrollToCursor];
}

- (void)updateNoteCellHeight {
    // calculate lines of string
    CGFloat calculatedHeight = [self getHeightForString:_infoSession.note fontSize:15 width:280];
    NSInteger lines = (NSInteger)(calculatedHeight - 34) / 18 + 1;
    // is lines changes, need to refresh tableView
    if (lines != noteLines) {
        noteLines = lines;
        CGRect textViewFrame = self.noteCell.contentText.frame;
        textViewFrame.size.height = calculatedHeight;
        self.noteCell.contentText.frame = textViewFrame;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)scrollToCursor{
    // get string before cursor
    NSString *stringBeforCursor;
    if (_infoSession.note == nil) {
        stringBeforCursor = @"";
    } else {
        @try {
            stringBeforCursor = [_infoSession.note substringToIndex:cursorIndex];
        }
        @catch (NSException *exception) {
            stringBeforCursor = _infoSession.note;
        }
        @finally {
        }
    }
    // calculate lines of string before cursor
    CGFloat calculatedHeight = [self getHeightForString:stringBeforCursor fontSize:15 width:280];
    NSInteger lines = (NSInteger)(calculatedHeight - 34) / 18 + 1;
    NSLog(@"lines : %i", lines);
    // calculate the offset need to scroll
    CGRect rectToScroll = CGRectMake(0, self.noteCell.frame.origin.y + lines * 20 - 95, 320, 120);
    // scroll tableview to rect that cursor is visible
    [self.tableView scrollRectToVisible:rectToScroll animated:YES];
}


#pragma mark - other methods

/**
 *  Alert Switch is change
 *
 *  @param sender UISwitch
 */
- (void)didSwitchChange:(id)sender {
    BOOL state = [sender isOn];
    _infoSession.alertIsOn = state;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)favoritesButton:(id)sender {
    if (_openedMyInfo == YES) {
        [self deleteOperation:sender];
    } else {
        [self addToMyInfo:sender];
    }
}

/**
 *  Add to my info sessions button
 *
 *  @param sender Button "Add"
 */
- (IBAction)addToMyInfo:(id)sender {
    // log event
    [[iRate sharedInstance] logEvent:NO];
    UW addResult = UWNonthing;
    // if note cell is editing, resign keyboard
    [self.noteCell.contentText resignFirstResponder];
    // this case is first time open an infosession from InfoSessionsVC or SearchViewController
    // only this situation, openedMyInfo == NO
    if (([_caller isEqualToString:@"InfoSessionsViewController"] || [_caller isEqualToString:@"SearchViewController"]) && _openedMyInfo == NO) {
        addResult = [InfoSessionModel addInfoSessionInOrder:[_infoSession copy] to:_infoSessionModel.myInfoSessions];
        // if first time to add, the below if statement must be true!
        if (addResult == UWAdded) {
            [self backupInfoSession];
            //UINavigationController *navigation = (UINavigationController *)_tabBarController.viewControllers[1];
            
            //MyInfoViewController *myInfoViewController = (MyInfoViewController *)navigation.topViewController;
            //myInfoViewController.infoSessionModel = _infoSessionModel;
            
            [UIView animateWithDuration:0.2 animations:^{
                [self animateSnapshotOfView:self.view.window toTab:_tabBarController.viewControllers[1]];
                // set badge
            }completion:^(BOOL finished) {
                [_tabBarController setBadge];
                // if added, replace _infoSession to the added infoSession in myInfoSession
                NSInteger existIndex = [InfoSessionModel findInfoSession:_infoSession in:_infoSessionModel.myInfoSessions];
                InfoSession *infoSessionReplaced = _infoSession;
                _infoSession = _infoSessionModel.myInfoSessions[existIndex];
                // at this time, the data from myInfo, so set YES
                
                NSLog(@"open = yes");
                _openedMyInfo = YES;
                [self updateBarIcon];
                // reload tabale
                [self.tableView reloadData];
                
                // update if other view is show this infosession
                if ([_caller isEqualToString:@"InfoSessionsViewController"]) {
                    UINavigationController *searchVCNavigationController = self.tabBarController.searchViewController.navigationController;
                    // if count > 1, means detailView is shown
                    if ([searchVCNavigationController.viewControllers count] > 1) {
                        UITableViewController *controller = searchVCNavigationController.viewControllers[1];
                        if ([controller isKindOfClass:[DetailViewController class]]) {
                            // get the tabbar item0's detailViewController
                            DetailViewController *detailController = (DetailViewController *)controller;
                            // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                            if ([infoSessionReplaced isEqual:detailController.infoSession]) {
                                NSLog(@"add: tab0->tab2");
                                detailController.infoSession = _infoSession;
                                detailController.openedMyInfo = YES;
                                //                            detailController.infoSessionBackup = nil;
                            }
                        }
                    }
                } else if ([_caller isEqualToString:@"SearchViewController"]) {
                    UINavigationController *infoSessionVCNavigationController = self.tabBarController.infoSessionsViewController.navigationController;
                    // if count > 1, means detailView is shown
                    if ([infoSessionVCNavigationController.viewControllers count] > 1) {
                        UITableViewController *controller = infoSessionVCNavigationController.viewControllers[1];
                        if ([controller isKindOfClass:[DetailViewController class]]) {
                            // get the tabbar item0's detailViewController
                            DetailViewController *detailController = (DetailViewController *)controller;
                            // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                            if ([infoSessionReplaced isEqual:detailController.infoSession]) {
                                NSLog(@"tab2->tab0");
                                detailController.infoSession = _infoSession;
                                detailController.openedMyInfo = YES;
                                //detailController.infoSessionBackup = nil;
                            }
                        }
                    }
                }
                
                // save to file
                [_infoSessionModel saveInfoSessions];
            }];
        }
    }
    else if (_openedMyInfo == YES) {
        // if opend saved one, then detect whether some changes made.
        if ([_infoSessionBackup isChangedCompareTo:_infoSession]) {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Modified Successfully!"];
//            [ProgressHUD showSuccess:@"Modified successfully!" Interacton:YES];
            [_infoSession scheduleNotifications];
            [self backupInfoSession];
            // save to file
            [_infoSessionModel saveInfoSessions];
        }
    }
}

/**
 *  Magic animation!!! Capture the current screen and drop to tabbar
 *
 *  @param view          the UIView want to drop
 *  @param navController the destination tabbar navigationController
 */
- (void)animateSnapshotOfView:(UIView *)view toTab:(UINavigationController *)navController
{
    NSUInteger targetTabIndex = [self.tabBarController.viewControllers indexOfObject:navController];
    NSUInteger tabCount = [self.tabBarController.tabBar.items count];
    // AFAIK there's no API (as of iOS 4) to get the frame of a tab bar item, so guesstimate using the index and the tab bar frame.
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    CGPoint targetPoint = CGPointMake((targetTabIndex + 0.5) * tabBarFrame.size.width / tabCount, CGRectGetMidY(tabBarFrame));
    targetPoint = [self.view.window convertPoint:targetPoint fromView:self.tabBarController.tabBar.superview];
    
    UIGraphicsBeginImageContext(view.frame.size);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //NSLog(@"image.size: %@", NSStringFromCGSize(image.size));
    
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    UIGraphicsEndImageContext();
    CGRect frame = [self.view.window convertRect:view.frame fromView:view.superview];
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (id)image.CGImage;
    imageLayer.opaque = NO;
    imageLayer.opacity = 0;
    imageLayer.frame = frame;
    [self.view.window.layer insertSublayer:imageLayer above:self.tabBarController.view.layer];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint startPoint = imageLayer.position;
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path,NULL,
                          startPoint.x, startPoint.y,
                          targetPoint.x, targetPoint.y,
                          targetPoint.x, targetPoint.y);
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    sizeAnimation.fromValue = [NSValue valueWithCGSize:imageLayer.frame.size];
    sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(10, 10)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.89];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:positionAnimation, sizeAnimation, opacityAnimation, nil];
    animationGroup.duration = 0.5;
    animationGroup.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationGroup.delegate = self;
    [animationGroup setValue:imageLayer forKey:@"animatedImageLayer"];
    
    [imageLayer addAnimation:animationGroup forKey:@"animateToTab"];
}

/**
 *  Tap gesture tatget method, resgin FirstResponder
 *
 *  @param gestureRecognizer gestureRecognizer
 */
- (void)hideKeyboard: (UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 3 && indexPath.row == 0) {
        return;
    }
    [self.noteCell.contentText resignFirstResponder];
    NSMutableArray *indexPathToReload = [[NSMutableArray alloc] init];
    [indexPathToReload addObject:[NSIndexPath indexPathForRow:0 inSection:3]];
    [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationFade];
}

- (void)backupInfoSession {
    // back up a copy of the infosession, used for detecting changes
    // guarrentee when pop up, any unsaved changes will be save.
    self.infoSessionBackup = [self.infoSession copy];
}

- (void)shareButton:(id)sender {
    NSArray *activity;
    if ([_infoSession.location length] <= 1 || [_infoSession.location isEqualToString:@"TBD*"] || [_infoSession.location isEqualToString:@"TBD"]) {
        activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init], [[LINEActivity alloc] init]];
    } else {
        // google map
        JNJGoogleMapsActivity *googleMapsActivity = [[JNJGoogleMapsActivity alloc] init];
        if (latitude != nil) {
            NSLog(@"set GPS");
            googleMapsActivity.latitude = latitude;
            googleMapsActivity.longitude = longitude;
            googleMapsActivity.zoomLevel = 15;
            googleMapsActivity.building = building;
        }
        
        // apple map
        TTAppleMapsActivity *appleMapsActivity = [[TTAppleMapsActivity alloc] init];
        if (latitude != nil) {
            appleMapsActivity.latitude = latitude;
            appleMapsActivity.longitude = longitude;
            appleMapsActivity.building = building;
        }
        activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init], [[LINEActivity alloc] init], googleMapsActivity, appleMapsActivity];
    }
    
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"cccc, MMM d"];
    NSDateFormatter *timeFormatter = [InfoSession estDateFormatter];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *timeString = [NSString stringWithFormat:@"%@ - %@", [timeFormatter stringFromDate:_infoSession.startTime], [timeFormatter stringFromDate:_infoSession.endTime]];
    NSString *dateString = [dateFormatter stringFromDate:_infoSession.date];
    
    NSString *postText = [NSString stringWithFormat:@"%@, %@, %@, at %@", _infoSession.employer, timeString, dateString, _infoSession.location];
    //UIImage *postImage = [UIImage imageNamed:@"AppIcon-Rounded.png"];
    NSURL *postURL = [NSURL URLWithString:@"http://goo.gl/bQyyH0"];
    NSArray *location = [[NSArray alloc] initWithObjects:latitude, longitude, nil];
    
    NSArray *activityItems = @[postText, /*postImage,*/ postURL, location];
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activity];
    activityController.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

//- (void)registerInfoSwitch:(id)sender {
//    BOOL state = [sender isOn];
//    // if current is off, means to turn on
//    if (state) {
//        NSLog(@"off -> on");
//        [self registerInfo:YES];
//    } else {
//        NSLog(@"on -> off");
//        [self registerInfo:NO];
//    }
////    if (state) {
////
////    }
////    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

//- (void)registerInfo:(BOOL)on {
//    BOOL usernamePasswordState = [self checkUsernameAndPassword];
//    if (!usernamePasswordState) {
//        [self setUsernameAndPassword];
//    } else {
//        NSLog(@"connect");
//        NSURLSession *session = [NSURLSession sharedSession];
//        NSString *baseURL = @"info.uwaterloo.ca/infocecs/students/rsvp/index.php";
//        NSString *onOff;
//        if (on) {
//            onOff = @"on";
//        } else {
//            onOff = @"off";
//        }
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@%@?id=%d&mode=%@", _infoSessionModel.uwUsername, _infoSessionModel.uwPassword, baseURL, _infoSession.sessionId, onOff]];
//        NSLog(@"url: %@", [url absoluteString]);
//        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            NSLog(@"wtf");
//            NSLog(@"%@", response);
//            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//            //[self checkResponse:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//            
//        }];
//        [dataTask resume];
//    }
//}

- (BOOL)checkResponse:(NSString *)responseData {
//    NSString *responseData1 = @"asdasdasdYou have been registered for the above information session.asdadasasd";
    NSString *notRegisterString = @"RSVP (students)";
    NSString *registerString = @"You have been registered for the above information session.";
    if ([responseData containsString:registerString]) {
        NSLog(@"register!");
        //[registerUISwitch setOn:YES animated:YES];
        return YES;
    } else if ([responseData containsString:notRegisterString]) {
        NSLog(@"not register!");
        //[registerUISwitch setOn:NO animated:YES];
        return NO;
    }
    return NO;
}

#pragma mark - UIScrollView Delegate method
/**
 *  Resgin FirstResponder
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"scroll did begin");
    //[self.noteCell.contentText resignFirstResponder];
    startContentOffset = scrollView.contentOffset.y;
    //NSLog(@"startContentOffset: %f", startContentOffset);
    //if (startContentOffset < -10.0) {
       // NSLog(@"scroll tableview");
        //NSLog(@"%@", NSStringFromCGRect(self.tableView.contentOffset));
        //[self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentOffset.y - 100, 320, 320) animated:YES];
        //[self.tableView scrollRectToVisible:<#(CGRect)#> animated:<#(BOOL)#>];
    //}
//    NSMutableArray *indexPathToReload = [[NSMutableArray alloc] init];
//    [indexPathToReload addObject:[NSIndexPath indexPathForRow:0 inSection:3]];
//    [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationFade];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.descriptionCell.contentText && (scrollView.contentOffset.y < 0 || scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height)) {
//        CGPoint newOffset = self.tableView.contentOffset;
//        newOffset.y += scrollView.contentOffset.y;
//        [self.tableView setContentOffset:newOffset animated:YES];
//    }
//}
////    if (scrollView == self.tableView) {
////        CGFloat currentOffset = scrollView.contentOffset.y;
////        CGFloat differenceFromStart = startContentOffset - currentOffset;
////        CGFloat differenceFromLast = lastContentOffset - currentOffset;
////        NSLog(@"start: %0.0f, current: %0.0f, last: %0.0f", startContentOffset, currentOffset, lastContentOffset);
////        //    lastContentOffset = currentOffset;
////        //
////        // start < current, scroll down
////        NSLog(@"diff_start: %0.0f, diff_last: %0.0f", differenceFromStart, differenceFromLast);
////        if(differenceFromStart > 0)
////        {
////            // scroll up
////            if(!scrollView.isTracking && (abs(differenceFromLast)>3))
////                [self.noteCell.contentText resignFirstResponder];
////        }
////        lastContentOffset = scrollView.contentOffset.y;
////    }
////    NSLog(@"tableView did scroll :%f", scrollView.contentOffset.y);
////    [nextPullView pullViewScrollViewDidScroll:scrollView];
////	[prevPullView pullViewScrollViewDidScroll:scrollView];
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
////    NSLog(@"tableView did end dragging :%f", scrollView.contentOffset.y);
////    [nextPullView pullViewScrollViewDidEndDragging:scrollView];
////	[prevPullView pullViewScrollViewDidEndDragging:scrollView];
//}

//#pragma mark - touch event handling
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    return YES;
//}

#pragma mark - AlertViewController Delegate method
/**
 *  Used for handling alert section rows reloading.
 *
 *  @param alertController AlertViewController instance
 *  @param alertIndex      the index of the selected alert
 */
- (void)alertViewController:(AlertViewController *)alertController didSelectAlertChoice:(NSInteger)alertIndex{
    // if before refreshing alerts, alerts list is not full, then either delete row or reload row,
    // the last row: "add more row" doesn't disappear
    if (![_infoSession alertsIsFull]) {
        NSMutableArray *indexPathToReload = [[NSMutableArray alloc] init];
        if ([_infoSession isRemovedAfterRefreshingAlerts]) {
            if (_infoSession.alertIsOn == NO) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                // delete this row
                [indexPathToReload addObject:[NSIndexPath indexPathForRow:alertIndex + 1 inSection:1]];
                [self.tableView deleteRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationLeft];
                // reload rows below
                [indexPathToReload removeAllObjects];
                NSInteger numberOfRows = [self.tableView numberOfRowsInSection:1];
                for (NSInteger i = alertIndex + 1; i < numberOfRows; i++) {
                    [indexPathToReload addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                }
                [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            [indexPathToReload addObject:[NSIndexPath indexPathForRow:alertIndex + 1 inSection:1]];
            [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    // if before refreshing alerts, alerts list is full
    else {
        NSMutableArray *indexPathToReload = [[NSMutableArray alloc] init];
        // if one row is deleted, then need to reload this row to last row of this section
        if ([_infoSession isRemovedAfterRefreshingAlerts]) {
            NSInteger numberOfRows = [self.tableView numberOfRowsInSection:1];
            for (NSInteger i = alertIndex + 1; i < numberOfRows; i++) {
                [indexPathToReload addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        // if no row is deleted, just reload this row.
        else {
            [indexPathToReload addObject:[NSIndexPath indexPathForRow:alertIndex + 1 inSection:1]];
            [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowAlert"]) {
        _performedNavigation = @"ShowAlert";
        AlertViewController *controller = segue.destinationViewController;
        controller.infoSession = self.infoSession;
        controller.infoSessionModel = self.infoSessionModel;
        NSIndexPath *choosedIndexPath = sender;
        controller.alertIndex =choosedIndexPath.row - 1;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowMap"]) {
        _performedNavigation = @"ShowMap";
        MapViewController *controller = segue.destinationViewController;
        controller.tabBarController = _tabBarController;
        controller.infoSessionModel = _infoSessionModel;
    }
}

//#pragma mark - pull to navigation methods
//
//- (void)pullViewDidTrigger:(ZHHPullView*)view {
//	if (view == prevPullView) {
//		NSLog(@"Go previous action");
//		[self goPrevious:nil];
//	} else {
//		NSLog(@"Go next action");
//		[self goNext:nil];
//	}
//	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
//}
//
//- (BOOL)pullViewSourceIsLoading:(ZHHPullView*)view {
//	return isLoading; // should return if data source model is reloading
//}
//
//- (NSString*)pullViewSubtext:(ZHHPullView*)view {
//	NSString *subText;
//	if (view == prevPullView) {
//		subText = @"[Previous article title]";
//	} else {
//		subText = @"[Next article title]";
//	}
//    //	  NSLog(@"returns subText: %@", subText);
//	return subText;
//}
//
//- (void)goNext:(id)sender {
//    NSLog(@"goNext");
//    InfoSession *nextInfo = [_infoSessionModel getNextInfoSessionAccordingInfoSession:_infoSession];
//    NSLog(@"%@", nextInfo.employer);
////    DetailViewController *nextDetailVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
////    _tabBarController.detailViewControllerOfTabbar0 = nextDetailVC;
////    nextDetailVC.caller = @"InfoSessionsViewController";
////    nextDetailVC.infoSession = nextInfo;
////    nextDetailVC.infoSessionModel = _infoSessionModel;
////    nextDetailVC.tabBarController = _tabBarController;
//    self.infoSession = nextInfo;
//    [self preformTransitionToViewController:self direction:kCATransitionFromTop];
//}
//
//- (void)goPrevious:(id)sender {
//    NSLog(@"goPrevious");
//    InfoSession *preInfo = [_infoSessionModel getPreviousInfoSessionAccordingInfoSession:_infoSession];
//    NSLog(@"%@", preInfo.employer);
//    
////    DetailViewController *preDetailVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
////    
////    _tabBarController.detailViewControllerOfTabbar0 = preDetailVC;
////    preDetailVC.caller = @"InfoSessionsViewController";
////    preDetailVC.infoSession = preInfo;
////    preDetailVC.infoSessionModel = _infoSessionModel;
////    preDetailVC.tabBarController = _tabBarController;
//    
//    self.infoSession = preInfo;
//    [self preformTransitionToViewController:self direction:kCATransitionFromBottom];
//
//}
//
//- (void)reloadTableViewDataSource{
//	//	should be calling your tableviews data source model to reload
//	//	put here just for demo
//    NSLog(@"reload table view data source");
//	isLoading = YES;
//	
//}
////
//- (void)doneLoadingTableViewData{
//	//	model should call this when its done loading
//    NSLog(@"done reloading table view data");
//	isLoading = NO;
//	[nextPullView pullViewScrollViewDataSourceDidFinishedLoading:self.tableView];
//	[prevPullView pullViewScrollViewDataSourceDidFinishedLoading:self.tableView];
//}

///**
// *  Go to destionation View Controller
// *
// *  @param dest      the destionation View Controller
// *  @param direction Transition direction
// */
//- (void)preformTransitionToViewController:(UIViewController*)dest direction:(NSString*)direction {
//	//NSLog(@"segue identifier: %@, source: %@, destination: %@", self.identifier, sourceViewController, destinationController);
//	CATransition* transition = [CATransition animation];
//	transition.duration = 0.5;
//	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//	transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//	transition.subtype = direction; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//	
//    //[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.tableView.layer addAnimation:transition forKey:kCATransition];
//    DetailViewController *destinationVC = (DetailViewController *)dest;
//    [destinationVC.tableView.layer addAnimation:transition forKey:kCATransition];
////    NSMutableArray *stack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
////	[stack removeLastObject];
////	[self.navigationController popViewControllerAnimated:NO];
////    [self.navigationController pushViewController:dest animated:NO];
//	NSMutableArray *stack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//	[stack removeLastObject];
//	[stack addObject:destinationVC];
////	//	  [sourceViewController.navigationController pushViewController:destinationController animated:NO];
//	[self.navigationController setViewControllers:stack animated:NO];
//    if (self == dest) {
//        //[self.tableView reloadData];
////        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
////        dispatch_group_t group = dispatch_group_create();
////        dispatch_group_async(group, queue, ^{
//            [self viewWillDisappear:YES];
//            [self viewDidDisappear:YES];
//            [self viewDidLoad];
//            [self viewWillAppear:YES];
////        });
//    }
////    if (direction == kCATransitionFromTop) {
////        [self.tableView ]
////        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
////    }
////    destinationViewController = dest;
////    [self.view addSubview:dest.view];
////    // match the new view size to the current view size
////    dest.view.frame = self.view.bounds;
////    // position it just below the bottom edge of the current view
////    dest.view.transform =
////    CGAffineTransformMakeTranslation(0,self.view.bounds.size.height);
////    [UIView beginAnimations:nil context:(__bridge void *)(dest)];
////    [UIView setAnimationDuration:0.4];
////    [UIView setAnimationDelegate:self];
////    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
////    // slide it upwards until it eclipses the current view
////    dest.view.transform = CGAffineTransformMakeTranslation(0,0);
////    // here I would also slide up the post button to give it the attached appearance
////    [UIView commitAnimations];
//}

//- (void)animationDidStop:(NSString *)animationID
//                finished:(NSNumber *)finished
//                 context:(void *)context {
//    // remove the new PostingVC from our own view (we passed it in as the
//    // animation context)
//    UIViewController *postingVC = (__bridge UIViewController*)context;
//    [postingVC.view removeFromSuperview];
//    // setup a crossfade which will apply mainly to the nav bar as we push
//    // the new controller onto the UINavigationController stack
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.2; // fairly quick
//    transition.type = kCATransitionFade;
//    [self.navigationController.view.layer addAnimation:transition
//                                                forKey:kCATransition];
//    [self.navigationController pushViewController:postingVC animated:NO];
//    //[postingVC release];
//}


#pragma mark - iAd delegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"iad banner show");
    //[self.navigationController.navigationBar addSubview:_adBannerView];
    //self.tableView.tableHeaderView = _adBannerView;
    //[self.tableView addSubview:ad.iAdBannerView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //[banner setAlpha:1];
    [self.tableView setContentInset:UIEdgeInsetsMake(banner.frame.size.height + 43, 0, self.tabBarController.tabBar.frame.size.height, 0)];
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"iad banner show error");
//    [banner removeFromSuperview];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //[banner setAlpha:0];
    [UIView commitAnimations];
    
}

#pragma mark - Google Ad delegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)banner {
    NSLog(@"google banner show");
    //[self.navigationController.navigationBar addSubview:_googleBannerView];
    //self.tableView.tableHeaderView = _googleBannerView;
    //[self.tableView addSubview:ad.googleBannerView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //[banner setAlpha:1];
    [self.tableView setContentInset:UIEdgeInsetsMake(banner.frame.size.height + 44, 0, self.tabBarController.tabBar.frame.size.height, 0)];
    NSLog(@"table edge inset: %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    NSLog(@"table content size: %@", NSStringFromCGSize(self.tableView.contentSize));
    [UIView commitAnimations];
    
}

- (void)adView:(GADBannerView *)banner
didFailToReceiveAdWithError:(GADRequestError *)error {
    self.tableView.tableHeaderView = nil;
    NSLog(@"google banner show error");
    //[banner removeFromSuperview];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    //[banner setAlpha:0];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 10, 0, self.tabBarController.tabBar.frame.size.height, 0)];
    [UIView commitAnimations];
}

//#pragma mark - KVO methods
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if (context == &kObservingContentInsetChangesContext) {
//        //UIScrollView *scrollView = object;
//        //NSLog(@"scrollView contentSize changed to %@", NSStringFromCGSize(scrollView.contentSize));
//        //NSLog(@"scrollView contentInset changed to %@", NSStringFromUIEdgeInsets(scrollView.contentInset));
//		//[self pullViewScrollViewDidChange:scrollView];
//        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
//    } else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

@end
