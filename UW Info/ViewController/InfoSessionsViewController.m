//
//  InfoSessionsViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

//  Need implement update today's info session color

#import "InfoSessionsViewController.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "InfoSession.h"
#import "InfoSessionModel.h"
#import "InfoSessionCell.h"
#import "LoadingCell.h"

#import "DetailViewController.h"
#import "UWTabBarController.h"
#import "UWTermMenu.h"
#import "InfoDetailedTitleButton.h"

#import "REMenu.h"
#import "UWTodayButton.h"
#import "UWGoogleAnalytics.h"

//#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
//#import "GADAdMobExtras.h"

#import "UWAds.h"
#import "SVProgressHUD.h"
//#import "MYBlurIntroductionView.h"
//#import "MYIntroductionPanel.h"

#import "UWColorSchemeCenter.h"

@interface InfoSessionsViewController () <GADBannerViewDelegate/*, MYIntroductionDelegate*/>

@property (nonatomic, strong) UWTodayButton *todayButton;
@property (nonatomic, strong) UWTermMenu *termMenu;
@property (nonatomic, assign) NSInteger shownYear;
@property (nonatomic, copy) NSString *shownTerm;

@end

@implementation InfoSessionsViewController {
    UIRefreshControl *refreshControl;
//    CGFloat startContentOffset;
//    CGFloat lastContentOffset;
//    CGFloat previousScrollViewYOffset;
    BOOL isReloading;
    NSString *classOfRefreshSender;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 *  Initiate left & right bar buttons, reload data for the first time.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    _infoSessionModel.delegate = self;
    _tabBarController.lastTapped = -1;
    
    // Show refresh button
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];

    self.navigationItem.leftBarButtonItem = [self getTodayButtonItem];
    self.navigationItem.leftBarButtonItem.enabled = NO;

    // Init menu button (term selection)
    _termMenu = [[UWTermMenu alloc] initWithNavigationController:self.navigationController];
    _termMenu.infoSessionModel = _infoSessionModel;
    _termMenu.infoSessionViewController = self;

    //    NSLog(@"%@", [NSDate date]);
    _shownYear = [_termMenu getCurrentYear:[NSDate date]];
    _shownTerm = [_termMenu getCurrentTermFromDate:[[NSDate date] dateByAddingTimeInterval:7 * 24 * 60 * 60]];
    NSLog(@"shown year: %d, shown term: %@", _shownYear, _shownTerm);

    self.navigationItem.titleView = (UIView*)[_termMenu getMenuButton];

    
    // Register Color Scheme Update Function
    [self updateColorScheme];
    [UWColorSchemeCenter registerColorSchemeNotificationForObserver:self selector:@selector(updateColorScheme)];
    
    
    // Reload data
    isReloading = NO;
    [self reload:nil];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    //    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to reload data"];

    // Receive every minute from notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEveryMinute) name:@"OneMinute" object:nil];

    // Google Analytics
    [UWGoogleAnalytics analyticScreen:@"UW Info Session Screen"];

    // Fasten the ad loading
    [[UWAds singleton] resetAdView:nil OriginY:0];
}

- (void)updateColorScheme {
    [self.navigationController.navigationBar setBarTintColor:[UWColorSchemeCenter uwGold]];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationController.navigationBar.tintColor = [UWColorSchemeCenter uwBlack];
                         [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UWColorSchemeCenter uwBlack]}];
                         [_termMenu setMenuButtonColor:[UWColorSchemeCenter uwBlack]];
                         [_todayButton setColor:[UWColorSchemeCenter uwBlack]];
                     }
                     completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Initiate Today barButtonItem
 *
 *  @return UIBarButtonItem
 */
- (UIBarButtonItem*)getTodayButtonItem
{
    if (_todayButton == nil) {
        _todayButton = [[UWTodayButton alloc] initWithTitle:@"Today:" date:[NSDate date]];
    }
    
    [_todayButton addTarget:self action:@selector(scrollToToday) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* todayButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_todayButton];

    return todayButtonItem;
}

/**
 *  Update data. send request to network and instance variables.
 *
 *  @param sender
 */
- (void)reload:(__unused id)sender
{
    classOfRefreshSender = NSStringFromClass([sender class]);
    //NSLog(@"sender: %@", classOfRefreshSender);
    if ([classOfRefreshSender isEqualToString:@"UIBarButtonItem"] ||
        [classOfRefreshSender isEqualToString:@"UIRefreshControl"]) {
        [_infoSessionModel setOfflineMode:NO];
    }
    if (isReloading == NO) {
        //NSLog(@"reload");
        isReloading = YES;
        // if reload sender is not UIRefreshControll, do not clear table
        if (![classOfRefreshSender isEqualToString:@"UIRefreshControl"]) {
            // reload ended, end refreshing
            [self.refreshControl endRefreshing];
            self.refreshControl = nil;
            //[_infoSessionModel clearInfoSessions];
            _infoSessionModel.infoSessions = nil;
            _infoSessionModel.infoSessionsDictionary = nil;
            _infoSessionModel.currentTerm = nil;
            [_infoSessionModel setYearAndTerm];
            [self.tableView reloadData];
            [self reloadSection:0 WithAnimation:UITableViewRowAnimationBottom];
        }
        // reset titile's detail label
        [_termMenu setDetailLabel];

        // if sender is from choosed term, set show year and term
        if ([classOfRefreshSender isEqualToString:@"__NSDictionaryI"]) {
            _shownYear = [sender[@"Year"] integerValue];
            _shownTerm = sender[@"Term"];
        }

        // if shown year and term is not current term, hide todayButton
        if (_shownYear != [_termMenu getCurrentYear:[NSDate date]] || ![_shownTerm isEqualToString:[_termMenu getCurrentTermFromDate:[NSDate date]]]) {
            self.navigationItem.leftBarButtonItem = nil;
        } else {
            self.navigationItem.leftBarButtonItem = [self getTodayButtonItem];
        }

        // when reload is in processing, disable left and right button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;

        // if the target term is already saved in _infoSessionModel.termInfoDic, then read it directly.
        if (![classOfRefreshSender isEqualToString:@"UIBarButtonItem"] && ![classOfRefreshSender isEqualToString:@"UIRefreshControl"] && [_infoSessionModel readInfoSessionsWithTerm:[NSString stringWithFormat:@"%li %@", (long)_shownYear, _shownTerm]]) {

            //            // set termMenu
            //            _termMenu.infoSessionModel = _infoSessionModel;
            //            [_termMenu setDetailLabel];

            //            // reload ended, end refreshing
            //            [self.refreshControl endRefreshing];
            //            // reload TableView data
            //            [self.tableView reloadData];
            //            // is sender is not UIRefreshControl, scroll TableView to current date
            //            if (![NSStringFromClass([sender class]) isEqualToString:@"UIRefreshControl"]) {
            //                [self scrollToToday];
            //            }

            //            // reload sections animations
            //            [self reloadSection:-1 WithAnimation:UITableViewRowAnimationAutomatic];
            //
            //            // restore left and right buttons
            //            self.navigationItem.rightBarButtonItem.enabled = YES;
            //            self.navigationItem.leftBarButtonItem.enabled = YES;
            //            isReloading = NO;
            //            //self.refreshControl.enabled = YES;
            //            self.refreshControl = [[UIRefreshControl alloc] init];
            //            [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
        }
        // else, no infoSession saved for this target term, need update
        else {
            //NSLog(@"updateInfoSessionsWithYear");
            [_infoSessionModel updateInfoSessionsWithYear:_shownYear andTerm:_shownTerm];
        }
    }
}

/**
 *  Get Called when information is updated through internet
 *
 *  @param model InfoSessionModel
 */
- (void)infoSessionModeldidUpdateInfoSessions:(InfoSessionModel*)model
{
    // set termMenu
    _termMenu.infoSessionModel = _infoSessionModel;
    [_termMenu setDetailLabel];

    // reload TableView data
    [self.tableView reloadData];
    // scroll TableView to current date
    if (![classOfRefreshSender isEqualToString:@"UIRefreshControl"]) {
        [self scrollToToday];
    }
    // reload sections animations
    [self reloadSection:-1 WithAnimation:UITableViewRowAnimationAutomatic];
    // end refreshControl
    [self.refreshControl endRefreshing];

    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    isReloading = NO;
    //self.refreshControl.enabled = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
}

- (void)infoSessionModeldidUpdateFailed:(InfoSessionModel*)model
{
    //NSLog(@"infoSessionModel did Update Failed");
    // reload TableView data
    [self.tableView reloadData];
    // reload sections animations
    [self reloadSection:-1 WithAnimation:UITableViewRowAnimationBottom];
    // end refreshControl
    [self.refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    isReloading = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
}

/**
 *  Get the week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger, week number of the date
 */
- (NSUInteger)getWeekNumber:(NSDate*)date
{
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"w"];
    return [[dateFormatter stringFromDate:date] intValue];
}

/**
 *  scroll to the row of today
 */
- (void)scrollToToday
{
    if (_shownYear == [_termMenu getCurrentYear:[NSDate date]] && [_shownTerm isEqualToString:[_termMenu getCurrentTermFromDate:[NSDate date]]]) {
        // scroll TableView to current date
        InfoSession* firstInfoSession = [_infoSessionModel.infoSessions firstObject];
        //InfoSession *lastInfoSession = [_infoSessionModel.infoSessions lastObject];
        NSInteger currentWeekNum = [self getWeekNumber:[NSDate date]];
        NSLog(@"current: %d, first: %d", currentWeekNum, [firstInfoSession weekNum]);
        NSInteger sectionNumToScroll = (NSInteger)currentWeekNum - (NSInteger)[firstInfoSession weekNum];
        NSLog(@"section to scroll: %d", sectionNumToScroll);
        NSInteger rowNumToScroll = -1;

        if (0 <= sectionNumToScroll && sectionNumToScroll < [self numberOfSectionsInTableView:self.tableView]) {
            NSLog(@"normal");
            NSArray* infoSessionsOfCurrentWeek = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(currentWeekNum)];
            rowNumToScroll = -1;
            for (InfoSession* eachCell in infoSessionsOfCurrentWeek) {
                // current date is later than startTime
                if ([[NSDate date] compare:eachCell.endTime] == NSOrderedDescending) {
                    rowNumToScroll++;
                }
            }
            // if current date is the first date of this section
            if (rowNumToScroll == -1) {
                rowNumToScroll = 0;
            }
            // if this week is empty and next week is not empty, show next week's first item
            //    if (rowNumToScroll + 1 == [infoSessionsOfCurrentWeek count] &&
            //         ([self numberOfSectionsInTableView:self.tableView] > sectionNumToScroll + 1)) {
            //        rowNumToScroll = 0;
            //        sectionNumToScroll += 1;
            //    }
            // scroll!
        } else if (sectionNumToScroll == -1) {
            NSLog(@"too early");
            sectionNumToScroll = 0;
            rowNumToScroll = 0;
        } else {
            NSLog(@"too late");
            sectionNumToScroll = [self numberOfSectionsInTableView:self.tableView] - 1;
            rowNumToScroll = 0;
        }
        NSLog(@"scroll to section: %d, row: %d", sectionNumToScroll, rowNumToScroll);
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumToScroll inSection:sectionNumToScroll] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        // reload current
        //[self reloadSection:sectionNumToScroll WithAnimation:UITableViewRowAnimationFade];
        //[_tabBarController showTabBar];
    }
}

- (void)refreshEveryMinute {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

/**
 *  Return the number of sections. the number of sessions in this week
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if ([_infoSessionModel.infoSessionsDictionary count] == 0) {
        return 1;
    } else {
        NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
        NSInteger lastWeekNumber = [[_infoSessionModel.infoSessions lastObject] weekNum];
        return lastWeekNumber - firstWeekNumber + 2; // add one "No more info sessions"
    }
}

/**
 *  @Return the title of sections. show week start date to end date
 */
- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    // if no any one infoSession in this term, show "No info sessions"
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil) {
        return @"No Info Sessions";
    }
    // if there's info sessions, so for certain week with no info session
    else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil) {
        return @"Refreshing...";
    }
    // show last one
    else if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return @"No more info sessions";
    } else {
        InfoSession* firstInfoSession = [_infoSessionModel.infoSessions firstObject];
        NSUInteger weekNum = section + [firstInfoSession weekNum];

        NSArray* infoSessionsOfThisWeek = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(weekNum)];
        NSDate* dateOfFirstObjectOfThisWeek;
        if (infoSessionsOfThisWeek == nil) {
            dateOfFirstObjectOfThisWeek = [NSDate date];
        } else {
            InfoSession* firstSessionOfThisWeek = [infoSessionsOfThisWeek firstObject];
            dateOfFirstObjectOfThisWeek = firstSessionOfThisWeek.date;
        }
        // set components necessary
        NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setLocale:[NSLocale currentLocale]];
        NSDateComponents* component = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit fromDate:dateOfFirstObjectOfThisWeek];

        // set component to monday of that week
        [component setWeekOfYear:weekNum]; //Week of the section
        [component setWeekday:2]; //Monday

        // initialize begin monday string
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];

        NSDate* beginningOfWeek = [gregorian dateFromComponents:component];
        NSString* beginDate = [dateFormatter stringFromDate:beginningOfWeek];

        // set to next monday and initialize next sunday string
        [component setWeekOfYear:weekNum + 1]; //Week of the section
        [component setWeekday:1]; // Sunday
        NSDate* beginningOfNextWeek = [gregorian dateFromComponents:component];
        NSString* endDate = [dateFormatter stringFromDate:beginningOfNextWeek];

        return [NSString stringWithFormat:@"%@ - %@ (Week: %ld)", beginDate, endDate, (long int)section + 1];
    }
}

/**
 *  Return the number of rows in the section.
 *  if infosessionDictionary is nil, return 1 to show refreshing cell
 *  if sessions in this week is 0, return 1 to show empty cell
 */
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // refreshing cell
    if (([_infoSessionModel.infoSessionsDictionary count] == 0) || (section == [self numberOfSectionsInTableView:tableView] - 1) || ([[self getInfoSessionsAccordingSection:section] count] == 0)) {
        return 1;
    } else {
        // info session cell
        return [[self getInfoSessionsAccordingSection:section] count];
    }
}

/**
 *  Configure different cell
 */
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // if no any one infoSession in this term, show "No info sessions"
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil) {
        LoadingCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = YES;
        cell.loadingLabel.text = @"No Info Sessions";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
        //        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    } else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil) {
        LoadingCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = NO;
        [cell.loadingIndicator startAnimating];
        cell.loadingLabel.text = @"         Refreshing...";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.loadingLabel setTextColor:[UIColor darkGrayColor]];
        //        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        return cell;
    } else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
        LoadingCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = YES;
        cell.loadingLabel.text = [NSString stringWithFormat:@"%lu Info Sessions", (unsigned long)[_infoSessionModel.infoSessions count]];
        [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
        //        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    } else {
        if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
            LoadingCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            cell.loadingIndicator.hidden = YES;
            cell.loadingLabel.text = @"No Info Sessions";
            [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
            //            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            return cell;
        } else {
            InfoSessionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"InfoSessionCell"];
            //            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
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
- (void)configureCell:(InfoSessionCell*)cell withIndexPath:(NSIndexPath*)indexPath
{
    InfoSession* infoSession = [self getInfoSessionAccordingIndexPath:indexPath];
    // if current time is befor start time, set dark (future sessions)
    if ([[NSDate date] compare:infoSession.startTime] == NSOrderedAscending) {
        [cell.employer setTextColor:[UIColor blackColor]];
//        [cell.locationLabel setTextColor:[UIColor darkGrayColor]];
        [cell.location setTextColor:[UIColor darkGrayColor]];
//        [cell.dateLabel setTextColor:[UIColor darkGrayColor]];
        [cell.date setTextColor:[UIColor darkGrayColor]];
    }
    // if current time is between start time and end time, set blue (ongoing sessions)
    else if (([infoSession.startTime compare:[NSDate date]] == NSOrderedAscending) && ([[NSDate date] compare:infoSession.endTime] == NSOrderedAscending)) {
        UIColor* fontColor = [UWColorSchemeCenter uwGold];
        //[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]
        [cell.employer setTextColor:fontColor];
        cell.employer.shadowColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];
        cell.employer.shadowOffset = CGSizeMake(0.0, 1.0);
//        [cell.locationLabel setTextColor:fontColor];
        [cell.location setTextColor:fontColor];
//        [cell.dateLabel setTextColor:fontColor];
        [cell.date setTextColor:fontColor];
    }
    // set light grey (past sessions)
    else {
        [cell.employer setTextColor:[UIColor lightGrayColor]];
//        [cell.locationLabel setTextColor:[UIColor lightGrayColor]];
        [cell.location setTextColor:[UIColor lightGrayColor]];
//        [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
        [cell.date setTextColor:[UIColor lightGrayColor]];
    }
    NSMutableAttributedString* employerString = [[NSMutableAttributedString alloc] initWithString:infoSession.employer];
    NSMutableAttributedString* locationString = [[NSMutableAttributedString alloc] initWithString:[infoSession.location length] < 2 ? @"No Location Provided" : infoSession.location];

    NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
    NSDateFormatter* timeFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"MMM d, ccc"];
    [timeFormatter setDateFormat:@"h:mm a"];

    NSString* dateNSString = [NSString stringWithFormat:@"%@, %@ - %@", [dateFormatter stringFromDate:infoSession.date], [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime]];
    NSMutableAttributedString* dateString = [[NSMutableAttributedString alloc] initWithString:dateNSString];
    if (infoSession.isCancelled) {
        [employerString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [employerString length])];
        [locationString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [locationString length])];
        [dateString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [dateString length])];
    }

    [cell.employer setAttributedText:employerString];
    [cell.location setAttributedText:locationString];
    [cell.date setAttributedText:dateString];
}

/**
 *  Set different cell height for different cell
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 *
 *  @return for LoadingCell, return 44.0f, for InfoSessionCell, return 72.0f
 */
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // refreshing cell // no more info sessions // no info session cell
    if (([_infoSessionModel.infoSessionsDictionary count] == 0) || (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) || ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0)) {
        return 44.0f;
    } else {
        // info session cell
        return 72.0f;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    // refreshing cell
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 || section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 0.0f;
    }
    return 24.0f;
}

/**
 *  Set headers' view in tableView
 *
 *  @param tableView tableView to be set
 *  @param section   section to be set
 *
 *  @return ui view for header
 */
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* background = [[UIView alloc] init];
    background.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 24);
    background.backgroundColor = [UIColor colorWithRed:0.96 green:0.94 blue:0.93 alpha:1];
//    [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];

    UILabel* myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width, 24);
    myLabel.font = [UWColorSchemeCenter helveticaNeueRegularFont:14];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];

    UIView* headerView = [[UIView alloc] init];
    [headerView addSubview:background];
    [background addSubview:myLabel];

    return headerView;
}

/**
 *  reload one section with animation
 *
 *  @param sectionToScroll section number that want to reload, if -1, then calculate in this method
 *  @param animation       UITableViewRowAnimation
 */
- (void)reloadSection:(NSUInteger)sectionToScroll WithAnimation:(UITableViewRowAnimation)animation
{
    if (sectionToScroll == -1) {
        if (_shownYear == [_termMenu getCurrentYear:[NSDate date]] && [_shownTerm isEqualToString:[_termMenu getCurrentTermFromDate:[NSDate date]]]) {
            NSUInteger sectionNumToScroll = sectionToScroll;
            InfoSession* firstInfoSession = [_infoSessionModel.infoSessions firstObject];
            sectionNumToScroll = [self getWeekNumber:[NSDate date]] - [firstInfoSession weekNum];
            if (sectionNumToScroll >= [self numberOfSectionsInTableView:self.tableView]) {
                sectionNumToScroll = [self numberOfSectionsInTableView:self.tableView] - 1;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionNumToScroll] withRowAnimation:animation];
            return;
        } else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        } else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        } else {
            //sectionNumToScroll = 0;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationBottom];
            return;
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionToScroll] withRowAnimation:animation];
}


/**
 *  get the array of infoSession according give section
 *
 *  @param section NSIndexPath
 *
 *  @return the corresponding array of infoSession
 */
- (NSArray*)getInfoSessionsAccordingSection:(NSUInteger)section
{
    NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
    NSArray* infoSessions = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(section + firstWeekNumber)];
    return infoSessions;
}

/**
 *  get the infoSession according given Indexpath
 *
 *  @param indexPath NSIndexPath
 *
 *  @return the corresponding InfoSession
 */
- (InfoSession*)getInfoSessionAccordingIndexPath:(NSIndexPath*)indexPath
{
    NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
    InfoSession* infoSession = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(indexPath.section + firstWeekNumber)][indexPath.row];
    return infoSession;
}

#pragma mark - Table view delegate
/**
 *  select row at indexPath
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 */
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Refreshing cell
    if ([_infoSessionModel.infoSessionsDictionary count] == 0) {
        return;
    }
    // No info session cell
    if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
        return;
    } else {
        // info session cells
        [self performSegueWithIdentifier:@"ShowDetailFromInfoSessions" sender:[[NSArray alloc] initWithObjects:@"InfoSessionsViewController", [self getInfoSessionAccordingIndexPath:indexPath], _infoSessionModel, nil]];
    }
}

#pragma mark - Set Hide When Scroll

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    //NSLog(@"scrollViewWillBeginDragging");
//    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
// 
//    CGFloat currentOffset = scrollView.contentOffset.y;
//    CGFloat differenceFromStart = startContentOffset - currentOffset;
//    CGFloat differenceFromLast = lastContentOffset - currentOffset;
//    //NSLog(@"current: %0.0f, start: %0.0f, last: %0.0f", currentOffset, startContentOffset, lastContentOffset);
//    lastContentOffset = currentOffset;
//    
//    // start < current, scroll down
//    if((differenceFromStart) < 0)
//    {
//        // scroll up
//        if(scrollView.isTracking && (abs(differenceFromLast)>1) && ![self isBottomRowisVisible])
//            [self.tabBarController hideTabBar];
//    }
//    // start > current, scroll up
//    else {
//        if(scrollView.isTracking && (abs(differenceFromLast)>1))
//            [self.tabBarController showTabBar];
//    }
//    
//    CGRect bounds = scrollView.bounds;
//    CGSize size = scrollView.contentSize;
//    UIEdgeInsets inset = scrollView.contentInset;
//    float y = currentOffset + bounds.size.height - inset.bottom;
//    float h = size.height;
//    // NSLog(@"offset: %f", offset.y);
//    // NSLog(@"content.height: %f", size.height);
//    // NSLog(@"bounds.height: %f", bounds.size.height);
//    // NSLog(@"inset.top: %f", inset.top);
//    // NSLog(@"inset.bottom: %f", inset.bottom);
//    // NSLog(@"pos: %f of %f", y, h);
//    
//    float reload_distance = 0;
//    if(y > h + reload_distance) {
//        //NSLog(@"load more rows");
//        // bottom row reached, show tabbar
//        [self.tabBarController showTabBar];
//    }
////    if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
////        [self.tabBarController showTabBar];
//}
//
//- (BOOL)isBottomRowisVisible {
//    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//    for (NSIndexPath *index in indexPaths) {
//        if (index.section == [self numberOfSectionsInTableView:self.tableView] - 1 && index.row == 0) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    [_tabBarController showTabBar];
//    [_termMenu.menu close];
//}


// ios7 facebook like fade navigation bar

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGRect frame = self.navigationController.navigationBar.frame;
//    CGFloat size = frame.size.height - 21;
//    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
//    CGFloat scrollOffset = scrollView.contentOffset.y;
//    CGFloat scrollDiff = scrollOffset - previousScrollViewYOffset;
//    CGFloat scrollHeight = scrollView.frame.size.height;
//    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
//    
//    if (scrollOffset <= -scrollView.contentInset.top) {
//        frame.origin.y = 20;
//    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
//        frame.origin.y = -size;
//    } else {
//        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
////        frame.origin.y = MIN(20,
////                             MAX(-size, frame.origin.y -
////                                 (frame.size.height * (scrollDiff / scrollHeight))));
//    }
//    
//    [self.navigationController.navigationBar setFrame:frame];
//    [self updateBarButtonItems:(1 - framePercentageHidden)];
//    previousScrollViewYOffset = scrollOffset;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self stoppedScrolling];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
//                  willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate) {
//        [self stoppedScrolling];
//    }
//}
//
//- (void)stoppedScrolling
//{
//    CGRect frame = self.navigationController.navigationBar.frame;
//    if (frame.origin.y < 20) {
//        [self animateNavBarTo:-(frame.size.height - 21)];
//    }
//}
//
//- (void)updateBarButtonItems:(CGFloat)alpha
//{
//    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
//        item.customView.alpha = alpha;
//    }];
//    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
//        item.customView.alpha = alpha;
//    }];
//    self.navigationItem.titleView.alpha = alpha;
//    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
//    ((UIView*)[[self.navigationController.navigationBar subviews] objectAtIndex:1]).alpha = alpha;
//}
//
//- (void)animateNavBarTo:(CGFloat)y
//{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect frame = self.navigationController.navigationBar.frame;
//        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
//        frame.origin.y = y;
//        [self.navigationController.navigationBar setFrame:frame];
//        [self updateBarButtonItems:alpha];
//    }];
//}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController* controller = segue.destinationViewController;
    _tabBarController.detailViewControllerOfTabbar0 = controller;
    controller.caller = sender[0];
    controller.infoSession = sender[1];
    controller.infoSessionModel = sender[2];
    controller.tabBarController = _tabBarController;
}

@end
