//
//  InfoSessionsViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSessionsViewController.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "InfoSession.h"
#import "InfoSessionCell.h"
#import "LoadingCell.h"

#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"


#define NSIntegerToString(i) [NSString stringWithFormat:@"%d", i]

@interface InfoSessionsViewController ()

@property (nonatomic, strong) NSArray *infoSessions;
@property (nonatomic, strong) NSDictionary *infoSessionsDictionary;

@end

@implementation InfoSessionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 *  initiate left & right bar buttons, reload data for the first time.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // show refresh button
    //[[UIBarButtonItem appearance] setTintColor:[UIColor yellowColor]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(scrollToToday)];
    self.navigationItem.leftBarButtonItem = anotherButton;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    //reload data
    [self reload:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  update data. send request to network and instance variables.
 *
 *  @param sender
 */
- (void)reload:(__unused id)sender {
    self.infoSessions = nil;
    self.infoSessionsDictionary = nil;
    [self.tableView reloadData];
    [self reloadSection:0 WithAnimation:UITableViewRowAnimationBottom];
    //change right bar button to indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView] animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSURLSessionTask *task = [InfoSession infoSessionsWithBlock:^(NSArray *sessions, NSError *error) {
        if (!error) {
            self.infoSessions = sessions;
            [self processInfoSessionsDictionary];
        
            // reload TableView data
            [self.tableView reloadData];
            // scroll TableView to current date
            [self scrollToToday];
            
            // reload sections animations
            [self reloadSection:-1 WithAnimation:UITableViewRowAnimationBottom];
            
        }
        // restore right bar button to refresh button
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [activityIndicatorView setAnimatingWithStateOfTask:task];
}

/**
 *  To be called after self.infoSessions is initiated. 
 *  initiated self.infoSessionsDictionary with key: weekNum, value: corronsponding infoSession
 */
-(void)processInfoSessionsDictionary {
    self.infoSessionsDictionary = [[NSMutableDictionary alloc] init];
    for (InfoSession *eachSession in self.infoSessions) {
        // if key not exist
        if (self.infoSessionsDictionary[NSIntegerToString(eachSession.weekNum)] == nil) {
            [self.infoSessionsDictionary setValue:[[NSMutableArray alloc] initWithObjects:eachSession, nil] forKey:[NSString  stringWithFormat:@"%d", eachSession.weekNum]];
        } else {
        // key exists
            [self.infoSessionsDictionary[NSIntegerToString(eachSession.weekNum)] addObject:eachSession];
        }
    }
}

/**
 *  Get the week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger, week number of the date
 */
- (NSUInteger)getWeekNumbe:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"w"];
    return [[dateFormatter stringFromDate:date] intValue];
}

/**
 *  scroll to the row of today
 */
- (void)scrollToToday {
    // scroll TableView to current date
    InfoSession *firstInfoSession = [self.infoSessions firstObject];
    NSUInteger currentWeekNum = [self getWeekNumbe:[NSDate date]];
    NSUInteger sectionNumToScroll = currentWeekNum - [firstInfoSession weekNum];
    
    NSArray *infoSessionsOfCurrentWeek = self.infoSessionsDictionary[NSIntegerToString(currentWeekNum)];
    NSInteger rowNumToScroll = -1;
    for (InfoSession *eachCell in infoSessionsOfCurrentWeek) {
        if ([[NSDate date] compare:eachCell.startTime] == NSOrderedDescending ) {
            rowNumToScroll++;
        }
    }
    // if current date is the first date of this section
    if (rowNumToScroll == -1) {
        rowNumToScroll = 0;
    }
    // if this week is empty and next week is not empty, show next week's first item
    if (rowNumToScroll + 1 == [infoSessionsOfCurrentWeek count] &&
         ([self numberOfSectionsInTableView:self.tableView] > sectionNumToScroll + 1)) {
        rowNumToScroll = 0;
        sectionNumToScroll += 1;
    }
    // scroll!
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumToScroll inSection:sectionNumToScroll] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    // reload current
    [self reloadSection:sectionNumToScroll WithAnimation:UITableViewRowAnimationNone];
}

/**
 *  reload one section with animation
 *
 *  @param sectionToScroll section number that want to reload, if -1, then calculate in this method
 *  @param animation       UITableViewRowAnimation
 */
- (void)reloadSection:(NSUInteger)sectionToScroll WithAnimation:(UITableViewRowAnimation)animation {
    NSUInteger sectionNumToScroll = sectionToScroll;
    if (sectionToScroll == -1) {
        InfoSession *firstInfoSession = [self.infoSessions firstObject];
        sectionNumToScroll = [self getWeekNumbe:[NSDate date]] - [firstInfoSession weekNum];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionNumToScroll] withRowAnimation:animation];
}
/**
 *  get the array of infoSession according give section
 *
 *  @param section NSIndexPath
 *
 *  @return the corresponding array of infoSession
 */
- (NSArray *)getInfoSessionsAccordingSection:(NSUInteger)section {
    NSInteger firstWeekNumber = [[self.infoSessions firstObject] weekNum];
    NSArray *infoSessions = self.infoSessionsDictionary[NSIntegerToString(section + firstWeekNumber)];
    return infoSessions;
}

/**
 *  get the infoSession according given Indexpath
 *
 *  @param indexPath NSIndexPath
 *
 *  @return the corresponding InfoSession
 */
- (InfoSession *)getInfoSessionAccordingIndexPath:(NSIndexPath *)indexPath {
    NSInteger firstWeekNumber = [[self.infoSessions firstObject] weekNum];
    InfoSession *infoSession = self.infoSessionsDictionary[NSIntegerToString(indexPath.section + firstWeekNumber)][indexPath.row];
    return infoSession;
}

#pragma mark - Table view data source
/**
 *  @Return the title of sections. show week start date to end date
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.infoSessionsDictionary == nil) {
        return @"Refreshing...";
    } else {
        InfoSession *firstInfoSession = [self.infoSessions firstObject];
        NSUInteger weekNum = section + [firstInfoSession weekNum];
        
        NSArray *infoSessionsOfThisWeek = self.infoSessionsDictionary[NSIntegerToString(weekNum)];
        NSDate *dateOfFirstObjectOfThisWeek;
        if (infoSessionsOfThisWeek == nil) {
            dateOfFirstObjectOfThisWeek = [NSDate date];
        } else {
            InfoSession *firstSessionOfThisWeek = [infoSessionsOfThisWeek firstObject];
            dateOfFirstObjectOfThisWeek = firstSessionOfThisWeek.date;
        }
        // set components necessary
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setLocale:[NSLocale currentLocale]];
        NSDateComponents *component = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit fromDate:dateOfFirstObjectOfThisWeek];
        
        // set component to monday of that week
        [component setWeek: weekNum]; //Week of the section
        [component setWeekday:2]; //Monday
        
        // initialize begin monday string
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSDate *beginningOfWeek = [gregorian dateFromComponents:component];
        NSString *beginDate = [dateFormatter stringFromDate: beginningOfWeek];
        
        // set to next monday and initialize next sunday string
        [component setWeek: weekNum + 1]; //Week of the section
        [component setWeekday:1]; // Sunday
        NSDate *beginningOfNextWeek = [gregorian dateFromComponents:component];
        NSString *endDate = [dateFormatter stringFromDate: beginningOfNextWeek];
        
        return [NSString stringWithFormat:@"%@ - %@", beginDate, endDate];
    }
}

/**
 *  Return the number of sections. the number of sessions in this week
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.infoSessionsDictionary == nil) {
        return 1;
    } else {
        NSInteger firstWeekNumber = [[self.infoSessions firstObject] weekNum];
        NSInteger lastWeekNumber = [[self.infoSessions lastObject] weekNum];
        return  lastWeekNumber - firstWeekNumber + 1;
    }
}
/**
 *  Return the number of rows in the section.
 *  if infosessionDictionary is nil, return 1 to show refreshing cell
 *  if sessions in this week is 0, return 1 to show empty cell
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // refreshing cell
    if (self.infoSessionsDictionary == nil) {
        return 1;
    } else {
        // no info sessions cell
        if ([[self getInfoSessionsAccordingSection:section] count] == 0){
            return 1;
        } else {
            // info session cell
            return [[self getInfoSessionsAccordingSection:section] count];
        }
    }
}

/**
 *  configure different cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.infoSessionsDictionary == nil) {
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = NO;
        [cell.loadingIndicator startAnimating];
        cell.loadingLabel.text = @"Refreshing...";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.loadingLabel setTextColor:[UIColor darkGrayColor]];

        return cell;
    } else {
        if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
            LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            cell.loadingIndicator.hidden = YES;
            cell.loadingLabel.text = @"No Info Sessions";
            [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
            return cell;
        } else {
            InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoSessionCell"];
            [self configureCell:cell withIndexPath:indexPath];
            return cell;
        }
    }
}
/**
 *  Configure InfoSessionCell
 *
 *  @param cell      InfoSessionCell
 *  @param indexPath IndexPath for the cell
 */
- (void)configureCell:(InfoSessionCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    InfoSession *infoSession = [self getInfoSessionAccordingIndexPath:indexPath];
    
    // if current time is befor start time, set dark (future sessions)
    if ([[NSDate date] compare:infoSession.startTime] == NSOrderedAscending) {
        [cell.employer setTextColor:[UIColor blackColor]];
        [cell.locationLabel setTextColor:[UIColor darkGrayColor]];
        [cell.location setTextColor:[UIColor darkGrayColor]];
        [cell.dateLabel setTextColor:[UIColor darkGrayColor]];
        [cell.date setTextColor:[UIColor darkGrayColor]];
    }
    // if current time is between start time and end time, set blue (ongoing sessions)
    else if ( ([infoSession.startTime compare:[NSDate date]] == NSOrderedAscending) && ([[NSDate date] compare:infoSession.endTime] == NSOrderedAscending) ){
        [cell.employer setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.locationLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.location setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.dateLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.date setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
    }
    // set light grey (past sessions)
    else {
        [cell.employer setTextColor: [UIColor lightGrayColor]];
        [cell.locationLabel setTextColor:[UIColor lightGrayColor]];
        [cell.location setTextColor:[UIColor lightGrayColor]];
        [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
        [cell.date setTextColor:[UIColor lightGrayColor]];

    }
    
    cell.employer.text = infoSession.employer;
    cell.location.text = infoSession.location;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, y"];
    [timeFormatter setDateFormat:@"h:mm a"];

    cell.date.text = [NSString stringWithFormat:@"%@ - %@, %@", [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime], [dateFormatter stringFromDate:infoSession.date]];
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
    // refreshing cell
    if (self.infoSessionsDictionary == nil) {
        return 44.0f;
    }
    // no info session cell
    if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
        return 44.0f;
    } else {
        // info session cell
        return 70.0f;
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
    // Refreshing cell
    if (self.infoSessionsDictionary == nil) {
        return;
    }
    // No info session cell
    if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
        return;
    } else {
        // info session cells
        [self performSegueWithIdentifier:@"ShowDetail" sender:[self getInfoSessionAccordingIndexPath:indexPath]];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
} */


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController *controller = segue.destinationViewController;
    controller.infoSession = sender;
}

@end
