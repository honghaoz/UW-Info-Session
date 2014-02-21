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

#import "ProgressHUD.h"

@interface DetailViewController () <EKEventEditViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

- (IBAction)addToMyInfo:(id)sender;

@end

@implementation DetailViewController {
    BOOL openedMyInfo;
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
    NSLog(@"DetailVC DidLoad");
    self.title = @"Details";
    
    // if caller is Info
    if ([_caller isEqualToString:@"InfoSessionsViewController"]) {
        NSInteger existIndex = [InfoSessionModel findInfoSession:_infoSession in:_infoSessionModel.myInfoSessions];
        openedMyInfo = NO;
        if (existIndex != -1) {
            NSLog(@"opened myInfo");
            _infoSession = _infoSessionModel.myInfoSessions[existIndex];
            openedMyInfo = YES;
        }
    } else {
        openedMyInfo = YES;
    }
    
    [self backupInfoSession];
    
    // initiate the right buttons
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Download"] style:UIBarButtonItemStyleBordered target:self action:@selector(addToMyInfo:)];
    UIBarButtonItem *calButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar"] style:UIBarButtonItemStylePlain target:self action:@selector(addToCalendar:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, calButton, nil]];
    
    // set tap gesture to resgin first responser
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    // set notification for entering background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self.tabBarController showTabBar];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    _tabBarController.lastTapped = -1;
    [super viewWillAppear:animated];
    _performedNavigation = @"";
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"preformedNavigation: %@", _performedNavigation);
    if ([_performedNavigation isEqualToString:@""]) {
        if ([self.infoSessionBackup isChangedCompareTo:self.infoSession]) {
            [self addToMyInfo:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) applicationDidEnterBackground {
    [self.noteCell.contentText resignFirstResponder];
}

#pragma mark - Calendar related
/**
 *  Calendar button is taped
 *
 *  @param sender calendar button
 */
- (void)addToCalendar:(id)sender {
    if (_infoSessionModel.eventStore == nil) {
        _infoSessionModel.eventStore = [[EKEventStore alloc] init];
    }
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
    [_infoSessionModel.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
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
    // Let's get the default calendar associated with our event store
    _infoSessionModel.defaultCalendar = _infoSessionModel.eventStore.defaultCalendarForNewEvents;
    [self showEventEditViewController];
}

- (void)showEventEditViewController {
    // Create an instance of EKEventEditViewController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    [addController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]];
    addController.navigationBar.tintColor = [UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1];
    
    // Set addController's event store to the current event store
    addController.eventStore = _infoSessionModel.eventStore;
    
    // creat a new event
    EKEvent *event = [EKEvent eventWithEventStore:_infoSessionModel.eventStore];
    // if infosession's event is nil or refresh failed (means this event is deleted)
    if (_infoSession.ekEvent == nil || ![_infoSession.ekEvent refresh]) {
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
    [self presentViewController:addController animated:YES completion:nil];
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
         NSLog(@"Canceled edit");
    }
    else if (action == EKEventEditViewActionSaved) {
        NSLog(@"Saved edited");
//        NSLog(@"calendarId: %@", [controller.event.calendar calendarIdentifier]);
//        NSLog(@"eventId: %@", [controller.event eventIdentifier]);
        _infoSession.ekEvent = controller.event;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:_infoSessionModel.eventStore];
        [self backupInfoSession];
    } else if (action == EKEventEditViewActionDeleted) {
        _infoSession.ekEvent = nil;
        NSLog(@"Deleted edited");
        [self backupInfoSession];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Notification Handler, used handle eventStore is changed
 *
 *  @param sender Send?
 */
-(void)storeChanged:(id)sender {
    NSLog(@"event store changed");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // if showing infoSession is deleted, then pop up
    if (_infoSessionBackup == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (openedMyInfo == YES) {
        NSLog(@"return 5");
        return 5;
    } else {
        NSLog(@"return 4");
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
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Employer";
            cell.contentLabel.text = _infoSession.employer;
            return cell;
        }
        else if (indexPath.row == 1) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Date";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMMM d, y"];
            cell.contentLabel.text = [dateFormatter stringFromDate:_infoSession.date];
            return cell;
        }
        else if (indexPath.row == 2) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.text = @"Time";
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"h:mm a"];
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
            if (_infoSession.sessionId > 10) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell.contentLabel setTextColor: [UIColor darkGrayColor]];
                cell.contentLabel.text = @"Tap here to RSVP.";
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentLabel setTextColor: [UIColor lightGrayColor]];
                cell.contentLabel.text = @"Not Available to RSVP.";
            }
            
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        if (_infoSession.alertIsOn == YES) {
            // the alert switch row
            if (indexPath.row == 0) {
                DetailSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailSwitchCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.remindSwitch addTarget:self action:@selector(didSwitchChange:) forControlEvents:UIControlEventValueChanged];
                [cell.remindSwitch setOn:YES animated:YES];
                
                // if this infoSession is in the future, can turn on siwtch
                if ([_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
                    [cell.remindSwitch setEnabled:YES];
                } else {
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
                [cell.contentLabel setTextColor: [UIColor blackColor]];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
                NSMutableDictionary *theAlert = _infoSession.alerts[indexPath.row - 1];
                
                cell.titleLabel.text = [InfoSession getAlertSequence:[NSNumber numberWithInteger:indexPath.row]];
                cell.contentLabel.text = [InfoSession getAlertDescription:theAlert[@"alertChoice"]];
                return cell;
            }
        } else {
            DetailSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailSwitchCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.remindSwitch addTarget:self action:@selector(didSwitchChange:) forControlEvents:UIControlEventValueChanged];
            [cell.remindSwitch setOn:NO animated:YES];
            // if this infoSession is in the future, can turn on siwtch
            if ([_infoSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
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
                textViewFrame.size.height = 241.0f;
                cell.contentText.frame = textViewFrame;
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.programs;
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                textViewFrame.size.height = 241.0f;
                cell.contentText.frame = textViewFrame;
            }
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
                textViewFrame.size.height = 241.0f;
                cell.contentText.frame = textViewFrame;
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.description;
                // resize textView height
                CGRect textViewFrame = cell.contentText.frame;
                textViewFrame.size.height = 241.0f;
                cell.contentText.frame = textViewFrame;
            }
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
            
            if (_infoSession.note == nil || [_infoSession.note length] == 0) {
                cell.contentText.text = @"Take some notes here.";
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
            } else {
                cell.contentText.text = _infoSession.note;
                [cell.contentText setTextColor: [UIColor blackColor]];

            }
            // resize textView height
            CGRect textViewFrame = cell.contentText.frame;
            textViewFrame.size.height = 2000.0f; // make sure note's height is very large
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
 *  @return for LoadingCell, return 44.0f, for InfoSessionCell, return 70.0f
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    // use UITextView to calculate height of this label
                    UITextView *calculationView = [[UITextView alloc] init];
                    [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:_infoSession.employer]];
                    [calculationView setFont:[UIFont systemFontOfSize:16]];
                    CGSize size = [calculationView sizeThatFits:CGSizeMake(200.0f, FLT_MAX)];
                    
                    // text line = 1
                    if (size.height < 37.0f) {
                        height = 42.0f;
                    } else if (size.height < 56.0f) {
                    // text line = 2
                        height = 58.0f;
                    } else {
                    // text line = 3
                        height = 74.0f;
                    }
                    break;
                }
                case 1: height = 42.0f; break;
                case 2: height = 42.0f; break;
                case 3: height = 42.0f; break;
                case 4: height = 42.0f; break;
            } break;
        case 1: height = 42.0f; break;
        case 2:
            switch (indexPath.row) {
                case 0: height = 42.0f; break;
                case 1: {
                    // use UITextView to calculate height of this label
                    UITextView *calculationView = [[UITextView alloc] init];
                    [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:_infoSession.audience]];
                    [calculationView setFont:[UIFont systemFontOfSize:16]];
                    CGSize size = [calculationView sizeThatFits:CGSizeMake(200.0f, FLT_MAX)];
                    
                    // text line = 1
                    if (size.height < 37.0f) {
                        height = 42.0f;
                    } else if (size.height < 56.0f) {
                        // text line = 2
                        height = 58.0f;
                    } else {
                        // text line = 3
                        height = 74.0f;
                    }
                    break;
                }
                case 2: {
                    UITextView *calculationView = [[UITextView alloc] init];
                    [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:_infoSession.programs]];
                    [calculationView setFont:[UIFont systemFontOfSize:15]];
                    CGSize size = [calculationView sizeThatFits:CGSizeMake(280.0f, FLT_MAX)];
                    //NSLog(_infoSession.programs);
                    if (size.height > 240) {
                        height = 240.0f + 55.0f;
                    } else {
                        height = size.height + 45.0f;
                    }
                    break;
                }
                case 3: {
                    UITextView *calculationView = [[UITextView alloc] init];
                    [calculationView setAttributedText:[[NSAttributedString alloc] initWithString:_infoSession.description]];
                    [calculationView setFont:[UIFont systemFontOfSize:15]];
                    CGSize size = [calculationView sizeThatFits:CGSizeMake(280.0f, FLT_MAX)];
                    //NSLog(_infoSession.programs);
                    if (size.height > 240) {
                        height = 240.0f + 60.0f;
                    } else {
                        height = size.height + 50.0f;
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open RSVP. link in Safari?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", @"Cancel", nil];
            [alert setCancelButtonIndex:1];
            [alert setTag:0];
            [alert show];
        }
    }
    // select alert section
    else if (indexPath.section == 1) {
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
    else if (indexPath.section == 2) {
        if (indexPath.row == 0 && [_infoSession.website length] > 7) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Open\n%@\nin Safari?", _infoSession.website]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", @"Cancel", nil];
            [alert setCancelButtonIndex:1];
            [alert setTag:1];
            [alert show];
        }
    }
    // select note section
    else if (indexPath.section == 3) {
        [self.noteCell.contentText becomeFirstResponder];
    }
    else if (indexPath.section == 4) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete Info Session", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0 && buttonIndex == 0) {
        _performedNavigation = @"OpenRSVPLink";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=%@&mode=on", [NSString stringWithFormat:@"%lu", (unsigned long)_infoSession.sessionId]]]];
    }
    else if (alertView.tag == 1 && buttonIndex == 0) {
        _performedNavigation = @"OpenWebsiteLink";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_infoSession.website]];
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
    NSLog(@"delete operation");
    if ([InfoSessionModel deleteInfoSession:_infoSession in:_infoSessionModel.myInfoSessions] == UWDeleted) {
        
        UINavigationController *navigation = (UINavigationController *)_tabBarController.viewControllers[1];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.performedNavigation = @"DeleteInfoSession";
            [self.navigationController popViewControllerAnimated:YES];
        }completion:^(BOOL finished) {
            
            // set badge
            NSInteger futureInfoSessions = [_infoSessionModel countFutureInfoSessions:_infoSessionModel.myInfoSessions];
            [[navigation tabBarItem] setBadgeValue: futureInfoSessions == 0 ? nil: NSIntegerToString(futureInfoSessions)];
            
            // if caller is MyInfoViewController, after pop up, need reload data
            if ([_caller isEqualToString:@"MyInfoViewController"]) {
                MyInfoViewController *myInfoViewController = (MyInfoViewController *)navigation.topViewController;
                [myInfoViewController reloadTable];
            }
            _infoSessionBackup = nil;
            
            // if deletion operation is commited in MyInfoVC
            if ([_caller isEqualToString:@"MyInfoViewController"]) {
                UINavigationController *infoSessionVCNavigationController = self.tabBarController.infoSessionsViewController.navigationController;
                // if count > 1, means detailView is shown
                if ([infoSessionVCNavigationController.viewControllers count] > 1) {
                    UITableViewController *controller = infoSessionVCNavigationController.viewControllers[1];
                    if ([controller isKindOfClass:[DetailViewController class]]) {
                        DetailViewController *detailController = (DetailViewController *)controller;
                        if ([_infoSession isEqual:detailController.infoSession]) {
                            detailController.infoSessionBackup = nil;
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
                        if ([_infoSession isEqual:detailController.infoSession]) {
                            detailController.infoSessionBackup = nil;
                        }
                    }
                }
            }
        }];
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
    [self.noteCell.contentText setTextColor: [UIColor blackColor]];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self.noteCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _infoSession.note = textView.text;
    //NSLog(@"finishe editing: %@", _infoSession.note);
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"begin editing");
    if (_infoSession.note == nil || [_infoSession.note length] == 0) {
        textView.text = @"";
    }
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self.noteCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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


/**
 *  Add to my info sessions button
 *
 *  @param sender Button "Add"
 */
- (IBAction)addToMyInfo:(id)sender {
    NSLog(@"addToMyInfo called");
    UW addResult = UWNonthing;
    
    // this case is first time open an infosession from InfoSessionsVC
    // only this situation, openedMyInfo == NO
    if ([_caller isEqualToString:@"InfoSessionsViewController"] && openedMyInfo == NO) {
        addResult = [InfoSessionModel addInfoSessionInOrder:[_infoSession copy] to:_infoSessionModel.myInfoSessions];
        // if first time to add, the below if statement must be true!
        if (addResult == UWAdded) {
            NSLog(@"added!");
            [self backupInfoSession];
            UINavigationController *navigation = (UINavigationController *)_tabBarController.viewControllers[1];
            
            MyInfoViewController *myInfoViewController = (MyInfoViewController *)navigation.topViewController;
            myInfoViewController.infoSessionModel = _infoSessionModel;
            
            [UIView animateWithDuration:0.2 animations:^{
                [self animateSnapshotOfView:self.view.window toTab:navigation];
            }completion:^(BOOL finished) {
                // set badge
                NSInteger futureInfoSessions = [_infoSessionModel countFutureInfoSessions:_infoSessionModel.myInfoSessions];
                [[navigation tabBarItem] setBadgeValue: futureInfoSessions == 0 ? nil: NSIntegerToString(futureInfoSessions)];
                
                // if added, replace _infoSession to the added infoSession in myInfoSession
                NSInteger existIndex = [InfoSessionModel findInfoSession:_infoSession in:_infoSessionModel.myInfoSessions];
                _infoSession = _infoSessionModel.myInfoSessions[existIndex];
                // at this time, the data from myInfo, so set YES
                openedMyInfo = YES;
                // reload tabale
                [self.tableView reloadData];
            }];
        }
    }
    else if (openedMyInfo == YES) {
        // if opend saved one, then detect whether some changes made.
        if ([_infoSessionBackup isChangedCompareTo:_infoSession]) {
            [ProgressHUD showSuccess:@"Modified successfully!" Interacton:YES];
            [self backupInfoSession];
        }
    }
}

//    
//    if (addResult == UWReplaced) {
//        NSLog(@"replaced!");
//        [ProgressHUD showSuccess:@"Modified successfully!" Interacton:YES];
//
//    } else
//    
    
//    CALayer * layerToThrow = [CALayer layer]; [layerToThrow setFrame:[viewToThrow frame]]; UIImage * viewContentImage = [self imageRepresentationOfView:viewToThrow]; [layerToThrow setContents:(id)[viewContentImage CGImage]]; [[[self view] layer] insertSublayer:layerToThrow above:[viewToThrow layer]];
    
    
//    [UIView animateWithDuration:0.5 animations:^{
    
        
        
////        [navigation tabBarItem].image = [UIImage imageNamed:@"List"];
//        UIImageView *addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(147, 7, 25, 23)];
//        addImageView.image = [[UIImage imageNamed:@"Bookmarks-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        
//        [addImageView setTintColor:[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]];
//        //[addImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        
//        [UIView animateWithDuration:0.5
//                         animations:^
//         {
//             [self.tabBarController.tabBar addSubview:addImageView];
//             //move right
//             addImageView.center = CGPointMake(addImageView.center.x +2, addImageView.center.y +2);
//         }
//                         completion:^(BOOL completed)
//         {
//             
//             if (completed)
//             {
//                 //completed move right..now move left
//                 [UIView animateWithDuration:1
//                                  animations:^
//                  {
//                      addImageView.center = CGPointMake(addImageView.center.x -2, addImageView.center.y -2);
//                  }];
//                 [addImageView removeFromSuperview];
//             }
//         }];
//    }completion:^(BOOL finished) {
//        [[navigation tabBarItem] setBadgeValue:nil];
//    }];
    
    
    
    
    //    });
    //    dispatch_sync(q, ^{
    //[self.delegate detailViewController:self didAddInfoSession:_infoSession];
    //    });
    
    //[self.delegate detailViewController:self didAddInfoSession:_infoSession];
    //[self.tabBarController setSelectedIndex:10];
    //NSLog(@"%i", [self.tabBarController.viewControllers count]);
    //    UINavigationController *navController=(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:0];
    //    [navController popToRootViewControllerAnimated:YES];
//}
//

//- (UIImage *)imageRepresentationOfView:(UIView *)view {
//    CGSize imageSize = [view frame].size; BOOL imageIsOpaque = [view isOpaque];
//    CGFloat imageScale = 0.0; // automatically set to scale factor of main screen
//    UIGraphicsBeginImageContextWithOptions(imageSize, imageIsOpaque, imageScale); CALayer * drawingLayer = [view layer];
//    [drawingLayer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
//
//- (CGRect)approximateFrameForTabBarItemAtIndex:(NSUInteger)barItemIndex  inTabBar:(UITabBar *)tabBar {
//    CGFloat barMidX = CGRectGetMidX([tabBar frame]);
//    CGSize barItemSize = CGSizeMake(80.0, 45.0);
//    CGFloat distanceBetweenBarItems = 110.0;
//    CGFloat barItemX = barItemIndex*distanceBetweenBarItems + barItemSize.width*0.5;
//    CGFloat totalBarItemsWidth = ([tabBar.items count]-1)*distanceBetweenBarItems + barItemSize.width;
//    barItemX += barMidX - round(totalBarItemsWidth*0.5);
//    return CGRectMake(barItemX, CGRectGetMinY([tabBar frame]), 30.0, barItemSize.height);
//}
//
//- (CGFloat)scaleFactorForView:(UIView *)view toFitInSize:(CGSize)size { CGFloat viewWidth = CGRectGetWidth([view frame]); CGFloat viewHeight = CGRectGetHeight([view frame]);  CGFloat viewAspect = viewWidth/viewHeight; CGFloat sizeAspect = size.width/size.height;  if (viewAspect > sizeAspect) { return MIN(1.0, (size.width/viewWidth)); } else { return MIN(1.0, (size.height/viewHeight)); } }

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
    
    //NSLog(@"view.frame: %@, %@", NSStringFromCGPoint(view.frame.origin), NSStringFromCGSize(view.frame.size));
    //NSLog(@"view.bounds: %@, %@", NSStringFromCGPoint(view.bounds.origin), NSStringFromCGSize(view.bounds.size));
    
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

#pragma mark - UIScrollView Delegate method
/**
 *  Resgin FirstResponder
 *
 *  @param scrollView scrollView
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.noteCell.contentText resignFirstResponder];
    NSMutableArray *indexPathToReload = [[NSMutableArray alloc] init];
    [indexPathToReload addObject:[NSIndexPath indexPathForRow:0 inSection:3]];
    [self.tableView reloadRowsAtIndexPaths:indexPathToReload withRowAnimation:UITableViewRowAnimationFade];
}

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
        NSLog(@"show map");
    }
}

@end
