//
//  InfoSessionsViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSessionsViewController.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "InfoSession.h"
#import "InfoSessionCell.h"
#import "LoadingCell.h"


#import "DetailViewController.h"
#import "InfoSessionModel.h"

#import "UWTabBarController.h"
#import "UWTermMenu.h"
#import "InfoDetailedTitleButton.h"

@interface InfoSessionsViewController ()

@property (nonatomic, strong) UWTermMenu *termMenu;

@end

@implementation InfoSessionsViewController {
    UIRefreshControl *refreshControl;
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    CGFloat previousScrollViewYOffset;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"need refresh today's colour");
}


/**
 *  initiate left & right bar buttons, reload data for the first time.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"InfoSessionVC DidLoad");
    _tabBarController.lastTapped = -1;
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
    
    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:UWGold];
    // black
    //[UIColor colorWithRed:0.13 green:0.14 blue:0.17 alpha:1]
    // yellow
    //[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]
    self.navigationController.navigationBar.tintColor = UWBlack;
    //[self.tableView setBackgroundColor:[UIColor blackColor]];
    
    // show refresh button
    //[[UIBarButtonItem appearance] setTintColor:[UIColor yellowColor]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
    
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(scrollToToday)];
    self.navigationItem.leftBarButtonItem = todayButton;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // init menu button (term selection)
//    self.termSelection = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, 180, 60)];
//
//    [self.termSelection setTitle:@"ASDASDASDASD" forState:UIControlStateNormal];
//    [self.termSelection setTitle:@"tap!" forState:UIControlStateSelected];
//    [self.termSelection setUserInteractionEnabled:YES];
//    [self.termSelection setBackgroundColor:[UIColor blueColor]];
//    //[self.termSelection setSelected:YES];
//     [self.navigationController.navigationBar addSubview:self.termSelection];
    
    _termMenu = [[UWTermMenu alloc] initWithNavigationController:self.navigationController];
    _termMenu.infoSessionModel = _infoSessionModel;
    _termMenu.infoSessionViewController = self;
    
    self.navigationItem.titleView = (UIView *)[_termMenu getMenuButton];

//    showOrigin =[[UILabel alloc] initWithFrame:(CGRectMake(10, 70, 190, 44))];
//    [self.view addSubview:showOrigin];
//    showOrigin.text = @"(%i, %i)";
//    [showOrigin setBackgroundColor:[UIColor yellowColor]];
    
    //reload data
    [self reload:nil];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to reload data"];
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
    NSLog(@"reload data");
    // end refreshControl
    [self.refreshControl endRefreshing];
    [_infoSessionModel clearInfoSessions];
    [_termMenu setDetailLabel];
    NSLog(@"infosessions: %@", _infoSessionModel.infoSessions);
    [self.tableView reloadData];
    [self reloadSection:-1 WithAnimation:UITableViewRowAnimationBottom];
    
    NSLog(@"reloaded table");
    
    //change right bar button to indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView] animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
//    NSLog(@"%@", NSStringFromClass([NSDictionary class]));
//    NSLog(@"%@", );
    if ([NSStringFromClass([sender class]) isEqualToString:@"__NSDictionaryI"]){
        _infoSessionModel.year = [sender[@"Year"] integerValue];
        _infoSessionModel.term = sender[@"Term"];
    } else {
        _infoSessionModel.year = 0;
        _infoSessionModel.term = nil;
    }
    NSURLSessionTask *task = [InfoSessionModel infoSessions:_infoSessionModel.year andTerm:_infoSessionModel.term withBlock:^(NSArray *sessions, NSString *currentTerm,  NSError *error) {
        if (!error) {
            // initiate infoSessionModel
            _infoSessionModel.infoSessions = sessions;
            _infoSessionModel.currentTerm = currentTerm;
            [_infoSessionModel setYearAndTerm];
            
            _termMenu.infoSessionModel = _infoSessionModel;
            [_termMenu setDetailLabel];
            
            [_infoSessionModel processInfoSessionsDictionary:_infoSessionModel.infoSessionsDictionary withInfoSessions:_infoSessionModel.infoSessions];
            
            // reload TableView data
            [self.tableView reloadData];
            // scroll TableView to current date
            [self scrollToToday];
            
            // reload sections animations
            [self reloadSection:-1 WithAnimation:UITableViewRowAnimationBottom];
            // end refreshControl
            [self.refreshControl endRefreshing];
            
        }
        // restore right bar button to refresh button
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    //[self.refreshControl setRefreshingWithStateOfTask:task];
    [activityIndicatorView setAnimatingWithStateOfTask:task];
}

/**
 *  Get the week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger, week number of the date
 */
- (NSUInteger)getWeekNumber:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"w"];
    return [[dateFormatter stringFromDate:date] intValue];
}

/**
 *  scroll to the row of today
 */
- (void)scrollToToday {
    if (_infoSessionModel.year == [_termMenu getCurrentYear:[NSDate date]] && [_infoSessionModel.term isEqualToString:[_termMenu getCurrentTermFromDate:[NSDate date]]]) {
        // scroll TableView to current date
        InfoSession *firstInfoSession = [_infoSessionModel.infoSessions firstObject];
        NSUInteger currentWeekNum = [self getWeekNumber:[NSDate date]];
        NSUInteger sectionNumToScroll = currentWeekNum - [firstInfoSession weekNum];
        
        NSArray *infoSessionsOfCurrentWeek = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(currentWeekNum)];
        NSInteger rowNumToScroll = -1;
        for (InfoSession *eachCell in infoSessionsOfCurrentWeek) {
            // current date is later than startTime
            if ([[NSDate date] compare:eachCell.endTime] == NSOrderedDescending ) {
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
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumToScroll inSection:sectionNumToScroll] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        // reload current
        [self reloadSection:sectionNumToScroll WithAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view data source

/**
 *  Return the number of sections. the number of sessions in this week
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_infoSessionModel.infoSessionsDictionary count] == 0) {
        return 1;
    } else {
        NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
        NSInteger lastWeekNumber = [[_infoSessionModel.infoSessions lastObject] weekNum];
        return  lastWeekNumber - firstWeekNumber + 2;// add one "No more info sessions"
    }
}

/**
 *  @Return the title of sections. show week start date to end date
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // if no any one infoSession in this term, show "No info sessions"
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil) {
        return @"No info sessions";
    }
    // if there's info sessions, so for certain week with no info session
    else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil) {
        return @"Refreshing...";
    }
    // show last one
    else if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return @"No more info sessions";
    }
    else {
        InfoSession *firstInfoSession = [_infoSessionModel.infoSessions firstObject];
        NSUInteger weekNum = section + [firstInfoSession weekNum];
        
        NSArray *infoSessionsOfThisWeek = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(weekNum)];
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
 *  Return the number of rows in the section.
 *  if infosessionDictionary is nil, return 1 to show refreshing cell
 *  if sessions in this week is 0, return 1 to show empty cell
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // refreshing cell
    if (([_infoSessionModel.infoSessionsDictionary count] == 0) ||
        (section == [self numberOfSectionsInTableView:tableView] - 1) ||
        ([[self getInfoSessionsAccordingSection:section] count] == 0)) {
        return 1;
    }
    else {
        // info session cell
        return [[self getInfoSessionsAccordingSection:section] count];
    }
}

/**
 *  configure different cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if no any one infoSession in this term, show "No info sessions"
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil) {
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = YES;
        cell.loadingLabel.text = @"No info sessions";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
        return cell;
    }
    else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil) {
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = NO;
        [cell.loadingIndicator startAnimating];
        cell.loadingLabel.text = @"      Refreshing...";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentLeft];
        [cell.loadingLabel setTextColor:[UIColor darkGrayColor]];
        return cell;
    }
    else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        cell.loadingIndicator.hidden = YES;
        cell.loadingLabel.text = @"No more info sessions";
        [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
        return cell;
    }
    else {
        if ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0) {
            LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            cell.loadingIndicator.hidden = YES;
            cell.loadingLabel.text = @"No info sessions";
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
    
//    [cell setBackgroundColor:[UIColor blackColor]];
//    
//    // if current time is befor start time, set dark (future sessions)
//    if ([[NSDate date] compare:infoSession.startTime] == NSOrderedAscending) {
//        [cell.employer setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.locationLabel setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.location setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.dateLabel setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.date setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//    }
//    // if current time is between start time and end time, set blue (ongoing sessions)
//    else if ( ([infoSession.startTime compare:[NSDate date]] == NSOrderedAscending) && ([[NSDate date] compare:infoSession.endTime] == NSOrderedAscending) ){
//        [cell.employer setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
//        [cell.locationLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
//        [cell.location setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
//        [cell.dateLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
//        [cell.date setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
//    }
//    // set light grey (past sessions)
//    else {
//        [cell.employer setTextColor: [UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.locationLabel setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.location setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.dateLabel setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//        [cell.date setTextColor:[UIColor colorWithRed:1 green:0.87 blue:0.02 alpha:1]];
//    
//    }

    
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
        UIColor *fontColor = UWGold;
        //[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]
        [cell.employer setTextColor:fontColor];
        cell.employer.shadowColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        cell.employer.shadowOffset  = CGSizeMake(0.0, 1.0);
        [cell.locationLabel setTextColor:fontColor];
        [cell.location setTextColor:fontColor];
        [cell.dateLabel setTextColor:fontColor];
        [cell.date setTextColor:fontColor];
    }
    // set light grey (past sessions)
    else {
        [cell.employer setTextColor: [UIColor lightGrayColor]];
        [cell.locationLabel setTextColor:[UIColor lightGrayColor]];
        [cell.location setTextColor:[UIColor lightGrayColor]];
        [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
        [cell.date setTextColor:[UIColor lightGrayColor]];

    }
    NSMutableAttributedString *employerString = [[NSMutableAttributedString alloc] initWithString:infoSession.employer];
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:infoSession.location];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    // set the locale to fix the formate to read and write;
    NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [timeFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MMM d, y"];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSString *dateNSString = [NSString stringWithFormat:@"%@ - %@, %@", [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime], [dateFormatter stringFromDate:infoSession.date]];
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:dateNSString];
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
 *  set different cell height for different cell
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 *
 *  @return for LoadingCell, return 44.0f, for InfoSessionCell, return 70.0f
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // refreshing cell // no more info sessions // no info session cell
    if (([_infoSessionModel.infoSessionsDictionary count] == 0) ||
        (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) ||
        ([[self getInfoSessionsAccordingSection:indexPath.section] count] == 0)) {
        return 44.0f;
    }else {
        // info session cell
        return 70.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // refreshing cell
    if ([_infoSessionModel.infoSessionsDictionary count] == 0 || section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 0.0f;
    }
    return 25.0f;
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
        if (_infoSessionModel.year == [_termMenu getCurrentYear:[NSDate date]] && [_infoSessionModel.term isEqualToString:[_termMenu getCurrentTermFromDate:[NSDate date]]]) {
            InfoSession *firstInfoSession = [_infoSessionModel.infoSessions firstObject];
            sectionNumToScroll = [self getWeekNumber:[NSDate date]] - [firstInfoSession weekNum];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionNumToScroll] withRowAnimation:animation];
        }
        else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions != nil){
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if ([_infoSessionModel.infoSessionsDictionary count] == 0 && _infoSessionModel.infoSessions == nil){
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            //sectionNumToScroll = 0;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:animation];
        }
    }
    
}
/**
 *  get the array of infoSession according give section
 *
 *  @param section NSIndexPath
 *
 *  @return the corresponding array of infoSession
 */
- (NSArray *)getInfoSessionsAccordingSection:(NSUInteger)section {
    NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
    NSArray *infoSessions = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(section + firstWeekNumber)];
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
    NSInteger firstWeekNumber = [[_infoSessionModel.infoSessions firstObject] weekNum];
    InfoSession *infoSession = _infoSessionModel.infoSessionsDictionary[NSIntegerToString(indexPath.section + firstWeekNumber)][indexPath.row];
    return infoSession;
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

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
//        
//        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
//        tableViewHeaderFooterView.textLabel.textColor = [UIColor blueColor];
//    }
//}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    //[headerView setTintColor:[UIColor yellowColor]];
//    //headerView.tintColor = [UIColor yellowColor];
//    
//    // if you have index/header text in your tableview change your index text color
////    UITableViewHeaderFooterView *headerIndexText = (UITableViewHeaderFooterView *)view;
//    //[headerView.textLabel setTextColor:[UIColor blackColor]];
//    //[headerView setBackgroundColor:[UIColor yellowColor]];
//    return headerView;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
} */

#pragma mark - Set Hide When Scroll

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"scrollViewWillBeginDragging");
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    //NSLog(@"current: %0.0f, start: %0.0f, last: %0.0f", currentOffset, startContentOffset, lastContentOffset);
    lastContentOffset = currentOffset;
    
    // start < current, scroll down
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1) && ![self isBottomRowisVisible])
            [self.tabBarController hideTabBar];
    }
    // start > current, scroll up
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self.tabBarController showTabBar];
    }
    
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = currentOffset + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 0;
    if(y > h + reload_distance) {
        //NSLog(@"load more rows");
        // bottom row reached, show tabbar
        [self.tabBarController showTabBar];
    }
//    if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
//        [self.tabBarController showTabBar];
}

-(BOOL)isBottomRowisVisible {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexPaths) {
        if (index.section == [self numberOfSectionsInTableView:self.tableView] - 1 && index.row == 0) {
            return YES;
        }
    }
    return NO;
}

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailViewController *controller = segue.destinationViewController;
    _tabBarController.detailViewControllerOfTabbar0 = controller;
    controller.caller = sender[0];
    controller.infoSession = sender[1];
    controller.infoSessionModel = sender[2];
    controller.tabBarController = _tabBarController;
}

@end
