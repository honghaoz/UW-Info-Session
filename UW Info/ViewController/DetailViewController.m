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
#import "MyInfoViewController.h"

#import "LoadingCell.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "UWTabBarController.h"
#import "MapViewController.h"

@interface DetailViewController () <EKEventEditViewDelegate>

- (IBAction)addToMyInfo:(id)sender;

@end

@implementation DetailViewController

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
    self.title = @"Details";
    
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
    
    // Create an instance of EKEventEditViewController
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
	
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
 *  Check the authorization status of our application for Calendar
 */
-(void)checkEventStoreAccessForCalendar
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar.\nWithout permission, no info session can be added."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
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
    } else if (action == EKEventEditViewActionDeleted) {
        _infoSession.ekEvent = nil;
        NSLog(@"Deleted edited");
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
    // Return the number of sections.
    return 4;
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
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.contentLabel.text = @"Tap here to RSVP.";
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
                return cell;
            }
            // the last row, add more alert
            else if (indexPath.row == [_infoSession.alerts count] + 1) {
                LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddAlertCell"];
                cell.loadingLabel.text = @"Add more alert";
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
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.titleLabel.text = @"Website";
            if ([_infoSession.website length] <= 7) {
                [cell.contentLabel setFont:[UIFont systemFontOfSize:16]];
                [cell.contentLabel setTextColor: [UIColor lightGrayColor]];
                cell.contentLabel.text = @"No Website Provided";
                return cell;
            } else {
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
                        height = 240.0f + 55.0f;
                    } else {
                        height = size.height + 45.0f;
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
                    
                    height = size.height + 45.0f;
                    
                    break;
                }
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
    // select note section
    else if (indexPath.section == 3) {
        [self.noteCell.contentText becomeFirstResponder];
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
    [_infoSessionModel addInfoSessionInOrder:_infoSession to:_infoSessionModel.myInfoSessions];
    //[_infoSessionModel.myInfoSessions addObject:_infoSession];
    
    //[_infoSessionModel processInfoSessionsDictionary:_infoSessionModel.myInfoSessionsDictionary withInfoSessions:_infoSessionModel.myInfoSessions];
    
    //    dispatch_queue_t q = dispatch_queue_create("com.honghaoz", NULL);
    //    dispatch_sync(q, ^ {
    
    //    [UIView  beginAnimations:nil context:NULL];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationDuration:0.75];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    //    [UIView commitAnimations];
    //
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDelay:0.375];
    //    [self.navigationController popViewControllerAnimated:NO];
    //    [UIView commitAnimations];
    
    
    //    [UIView animateWithDuration:0.75
    //                     animations:^{
    //                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    //
    //                     }];
    //    [self.navigationController popViewControllerAnimated:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    UINavigationController *navigation = (UINavigationController *)_tabBarController.viewControllers[1];
    [[navigation tabBarItem] setBadgeValue:NSIntegerToString([_infoSessionModel.myInfoSessions count])];
    
    MyInfoViewController *myInfoViewController = (MyInfoViewController *)navigation.topViewController;
    myInfoViewController.infoSessionModel = _infoSessionModel;
    
    //    });
    //    dispatch_sync(q, ^{
    //[self.delegate detailViewController:self didAddInfoSession:_infoSession];
    //    });
    
    //[self.delegate detailViewController:self didAddInfoSession:_infoSession];
    //[self.tabBarController setSelectedIndex:10];
    //NSLog(@"%i", [self.tabBarController.viewControllers count]);
    //    UINavigationController *navController=(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:0];
    //    [navController popToRootViewControllerAnimated:YES];
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
        AlertViewController *controller = segue.destinationViewController;
        controller.infoSession = self.infoSession;
        controller.infoSessionModel = self.infoSessionModel;
        NSIndexPath *choosedIndexPath = sender;
        controller.alertIndex =choosedIndexPath.row - 1;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowMap"]) {
        MapViewController *controller = segue.destinationViewController;
        controller.tabBarController = _tabBarController;
        controller.infoSessionModel = _infoSessionModel;
        NSLog(@"show map");
    }
}

@end
