//
//  SearchViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 3/2/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "SearchViewController.h"
#import "InfoSessionModel.h"
#import "InfoSessionCell.h"
#import "LoadingCell.h"
#import "UWTabBarController.h"
#import "DetailViewController.h"
#import "UWGoogleAnalytics.h"

#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADAdMobExtras.h"
#import "UWColorSchemeCenter.h"

@interface SearchViewController () <ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionIndex;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIView *statusBarCoverView;
@property (nonatomic, strong) UIView *searchBarCoverView;

@property (nonatomic, strong) NSArray *searchResult;

@end

@implementation SearchViewController {
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    CGFloat previousScrollViewYOffset;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // set color
//    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:UWGold];
//    self.navigationController.navigationBar.tintColor = UWBlack;
    
    // initiate search bar
    NSInteger statusBarHeight = 20;
    NSInteger navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,  statusBarHeight + navigationBarHeight, 320, 44)];
    _searchBar.delegate = self;
    _searchBar.scopeButtonTitles = [[NSArray alloc] initWithObjects:@"Employer", @"Program", @"Note", nil];
    
//    _searchBar.tintColor = [UWColorSchemeCenter uwBlack];
    _searchBar.placeholder = @"Search Info Session";
    
    
    // initiate table view
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height/* - bannerFrame.size.height*/)];
    [_tableView setContentInset:UIEdgeInsetsMake(navigationBarHeight, 0, 0, 0)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[InfoSessionCell class]  forCellReuseIdentifier:@"InfoSessionCell"];
    [_tableView registerClass:[LoadingCell class] forCellReuseIdentifier:@"LoadingCell"];
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_searchBar];
//    [self.view addSubview:_adBannerView];
//    [self.view addSubview:_googleBannerView];
    
    // initiate search bar controller
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;

    // initiate titleView
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 32.0)];
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 1.0, 180, 17.0)];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _textLabel.font = [UIFont boldSystemFontOfSize:17];
//    textLabel.textColor = [UWColorSchemeCenter uwBlack];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 180, 14.0)];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] - 2.0];
//    _detailLabel.textColor = [UWColorSchemeCenter uwBlack];
    [titleView addSubview:_textLabel];
    [titleView addSubview:_detailLabel];
    
    _textLabel.text = @"Info Session Search";
    _detailLabel.text = _infoSessionModel.currentTerm;
    
    [self.navigationItem setTitleView:titleView];
    
    // reload data
    [self reloadTable];
    

    _statusBarCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 20)];
//    _statusBarCoverView.backgroundColor = [UWColorSchemeCenter uwGold];
    _searchBarCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, _searchBar.frame.size.height)];
//    _searchBarCoverView.backgroundColor = [UWColorSchemeCenter uwGold];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToFirstRow) name:@"infoSessionsChanged" object:nil];
    
    // Register Color Scheme Update Function
    [self updateColorScheme];
    [UWColorSchemeCenter registerColorSchemeNotificationForObserver:self selector:@selector(updateColorScheme)];
    
    // Google Analytics
    [UWGoogleAnalytics analyticScreen:@"Search Screen"];
    
}

- (void)updateColorScheme {
    [self.navigationController.navigationBar setBarTintColor:[UWColorSchemeCenter uwGold]];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.navigationController.navigationBar.tintColor = [UWColorSchemeCenter uwBlack];
                         [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UWColorSchemeCenter uwBlack]}];
                         _searchBar.tintColor = [UWColorSchemeCenter uwBlack];
                         _detailLabel.textColor = [UWColorSchemeCenter uwBlack];
                         _textLabel.textColor = [UWColorSchemeCenter uwBlack];
                         _statusBarCoverView.backgroundColor = [UWColorSchemeCenter uwGold];
                         _searchBarCoverView.backgroundColor = [UWColorSchemeCenter uwGold];
                         _searchBar.scopeBarBackgroundImage = [self imageWithColor:[UWColorSchemeCenter uwGold]];
                     }
                     completion:nil];
}

- (void)scrollToFirstRow{
    [self reloadTable];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)reloadTable {
    [_infoSessionModel processInfoSessionsIndexDic];
    [self setSectionIndex];
    _detailLabel.text = _infoSessionModel.currentTerm;
    [self.tableView reloadData];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tablw View helper functions

- (NSString *)getKeyForSection:(NSInteger)section {
    return _sectionIndex[section];
}

- (NSArray *)setSectionIndex{
    _sectionIndex = [_infoSessionModel.infoSessionsIndexDic.allKeys sortedArrayUsingComparator:^(NSString *key1, NSString *key2){
        if ([key1 isEqualToString:@"#"]) {
            return NSOrderedDescending;
        } else if ([key2 isEqualToString:@"#"]) {
            return NSOrderedAscending;
        } else {
            return [key1 compare:key2];
        }
    }];
    return _sectionIndex;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchController.searchResultsTableView == tableView) {
        if ([_searchResult count] == 0) {
            return 1;
        } else {
            return 2;
        }
    }
    else {
        return [_infoSessionModel.infoSessionsIndexDic count] + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchController.searchResultsTableView == tableView) {
        return @"";
    } else {
        if (section < [_infoSessionModel.infoSessionsIndexDic count]) {
            return [self getKeyForSection:section];
        } else {
            return @"";
        }
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_searchController.searchResultsTableView != tableView) {
        return _sectionIndex;
    } else {
        return nil;
    }
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchController.searchResultsTableView == tableView) {
        if (section == 0) {
            return [_searchResult count];
        } else {
            return 1;
        }
    }
    else {
        if (section < [_infoSessionModel.infoSessionsIndexDic count]) {
            NSArray *infoSessionForThisSection = [_infoSessionModel.infoSessionsIndexDic objectForKey:[self getKeyForSection:section]];
            return [infoSessionForThisSection count] ;
        } else {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchController.searchResultsTableView == tableView) {
        if (indexPath.section == 0) {
            static NSString *cellIdentifier = @"InfoSessionCell";
            InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            //cell == nil? NSLog(@"nil") : NSLog(@"not nil");
            if (cell == nil) {
                cell = [[InfoSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            [self configureCell:cell withIndexPath:indexPath usingInfoSessions:_searchResult];
            return cell;
        } else {
            static NSString *cellIdentifier = @"LoadingCell";
            LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            //cell == nil? NSLog(@"nil") : NSLog(@"not nil");
            if (cell == nil) {
                cell = [[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            if ([_searchResult count] == 0) {
                cell.loadingLabel.text =  @"No Info Sessions";
            } else {
                cell.loadingLabel.text = [NSString stringWithFormat:@"%lu Info Sessions", (unsigned long)[_searchResult count]];
            }
            cell.loadingIndicator.hidden = YES;
            [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
            return cell;
        }
        
    }
    else {
        if (indexPath.section < [_infoSessionModel.infoSessionsIndexDic count]) {
            // Configure the cell...
            static NSString *cellIdentifier = @"InfoSessionCell";
            InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            //cell == nil? NSLog(@"nil") : NSLog(@"not nil");
            if (cell == nil) {
                cell = [[InfoSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            NSArray *infoSessionForThisSection = [_infoSessionModel.infoSessionsIndexDic objectForKey:[self getKeyForSection:indexPath.section]];
            
            [self configureCell:cell withIndexPath:indexPath usingInfoSessions:infoSessionForThisSection];
            return cell;
        } else {
            static NSString *cellIdentifier = @"LoadingCell";
            LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            //cell == nil? NSLog(@"nil") : NSLog(@"not nil");
            if (cell == nil) {
                cell = [[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            if ([_infoSessionModel.infoSessions count] == 0) {
                cell.loadingLabel.text =  @"No Info Sessions";
            } else {
                cell.loadingLabel.text = [NSString stringWithFormat:@"%lu Info Sessions", (unsigned long)[_infoSessionModel.infoSessions count]];
            }
            cell.loadingIndicator.hidden = YES;
            [cell.loadingLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.loadingLabel setTextColor:[UIColor lightGrayColor]];
            return cell;
        }
    }
}

- (void)configureCell:(InfoSessionCell *)cell withIndexPath:(NSIndexPath *)indexPath usingInfoSessions:(NSArray *)infoSessions {
    InfoSession *infoSession = [infoSessions objectAtIndex:indexPath.row];
    if (infoSession.isCancelled == YES) {
        [cell.employer setTextColor: [UIColor lightGrayColor]];
        [cell.locationLabel setTextColor:[UIColor lightGrayColor]];
        [cell.location setTextColor:[UIColor lightGrayColor]];
        [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
        [cell.date setTextColor:[UIColor lightGrayColor]];
    }
    else {
        [cell.employer setTextColor: [UIColor blackColor]];
        [cell.locationLabel setTextColor:[UIColor darkGrayColor]];
        [cell.location setTextColor:[UIColor darkGrayColor]];
        [cell.dateLabel setTextColor:[UIColor darkGrayColor]];
        [cell.date setTextColor:[UIColor darkGrayColor]];
    }
    
    NSMutableAttributedString *employerString = [[NSMutableAttributedString alloc] initWithString:infoSession.employer];
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:infoSession.location];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
    NSDateFormatter *timeFormatter = [InfoSession estDateFormatter];
    // set the locale to fix the formate to read and write;
    //NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //[dateFormatter setLocale:enUSPOSIXLocale];
    //[timeFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MMM d, ccc"];
    [timeFormatter setDateFormat:@"h:mm a"];
    // set timezone to EST
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    // set timezone to EST
    //[timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    
    NSString *dateNSString = [NSString stringWithFormat:@"%@, %@ - %@", [dateFormatter stringFromDate:infoSession.date], [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchController.searchResultsTableView == tableView) {
        if (indexPath.section == 0) {
            return 72.0f;
        } else {
            return 44.0f;
        }
    } else {
        if (indexPath.section < [_infoSessionModel.infoSessionsIndexDic count]) {
            return 72.0f;
        } else {
            return 44.0f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_searchController.searchResultsTableView == tableView) {
        return 0.0f;
    }
    else {
        if (section < [_infoSessionModel.infoSessionsIndexDic count]) {
            return 23.0f;
        } else {
            return 0.0f;
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.0f;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *background = [[UIView alloc] init];
    background.frame = CGRectMake(0, 0, 320, 23);
    background.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, 320, 23);
    myLabel.font = [UIFont boldSystemFontOfSize:17];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:background];
    [background addSubview:myLabel];
    
    return headerView;
}

#pragma mark - UITable view delegate methods 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_searchController.searchResultsTableView == tableView) {
        if (indexPath.section == 0) {
            [self performSegueWithIdentifier:@"ShowDetailFromSearchViewController" sender:[[NSArray alloc] initWithObjects:@"SearchViewController", [_searchResult objectAtIndex:indexPath.row], _infoSessionModel, nil]];
        }
    }
    else {
        if (indexPath.section < [_infoSessionModel.infoSessionsIndexDic count]) {
            [self performSegueWithIdentifier:@"ShowDetailFromSearchViewController" sender:[[NSArray alloc] initWithObjects:@"SearchViewController", [_infoSessionModel.infoSessionsIndexDic[[self getKeyForSection:indexPath.section]] objectAtIndex:indexPath.row], _infoSessionModel, nil]];
        }
    }
}


#pragma mark - Set Hide When Scroll
//// ???? Why scroll canbe detected? This is a simple ViewController, not scroll view
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    if (_searchController.searchResultsTableView == self.tableView) {
//        //NSLog(@"scrollViewWillBeginDragging");
//        startContentOffset = lastContentOffset = scrollView.contentOffset.y;
//    }
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (_searchController.searchResultsTableView == self.tableView) {
//        CGFloat currentOffset = scrollView.contentOffset.y;
//        CGFloat differenceFromStart = startContentOffset - currentOffset;
//        CGFloat differenceFromLast = lastContentOffset - currentOffset;
//        //NSLog(@"current: %0.0f, start: %0.0f, last: %0.0f", currentOffset, startContentOffset, lastContentOffset);
//        lastContentOffset = currentOffset;
//        
//        // start < current, scroll down
//        if((differenceFromStart) < 0)
//        {
//            // scroll up
//            if(scrollView.isTracking && (abs(differenceFromLast)>1) && ![self isBottomRowisVisible]){
//                [self.tabBarController hideTabBar];
//            }
//        }
//        // start > current, scroll up
//        else {
//            if(scrollView.isTracking && (abs(differenceFromLast)>1))
//                [self.tabBarController showTabBar];
//        }
//        
//        CGRect bounds = scrollView.bounds;
//        CGSize size = scrollView.contentSize;
//        UIEdgeInsets inset = scrollView.contentInset;
//        float y = currentOffset + bounds.size.height - inset.bottom;
//        float h = size.height;
//        // NSLog(@"offset: %f", offset.y);
//        // NSLog(@"content.height: %f", size.height);
//        // NSLog(@"bounds.height: %f", bounds.size.height);
//        // NSLog(@"inset.top: %f", inset.top);
//        // NSLog(@"inset.bottom: %f", inset.bottom);
//        // NSLog(@"pos: %f of %f", y, h);
//        
//        float reload_distance = 0;
//        if(y > h + reload_distance) {
//            //NSLog(@"load more rows");
//            // bottom row reached, show tabbar
//            [self.tabBarController showTabBar];
//        }
//        //    if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
//        //        [self.tabBarController showTabBar];
//    }
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
//}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSPredicate *resultPredicate;
    if ([scope isEqualToString:@"Employer"]) {
        resultPredicate = [NSPredicate predicateWithFormat:@"employer contains[c] %@", searchText];
    } else if ([scope isEqualToString:@"Program"]) {
        resultPredicate = [NSPredicate predicateWithFormat:@"programs contains[c] %@", searchText];
    } else if ([scope isEqualToString:@"Note"]){
        resultPredicate = [NSPredicate predicateWithFormat:@"note contains[c] %@", searchText];
    }
    _searchResult = [_infoSessionModel.infoSessionsIndexed filteredArrayUsingPredicate:resultPredicate];
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    //    [self filterContentForSearchText:searchString
    //                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    //                                      objectAtIndex:[self.searchDisplayController.searchBar
    //                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

//- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
//    NSLog(@"will begin search");
//}

//- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    NSLog(@"will end search");
//}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    self.tableView.hidden = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
    self.tableView.hidden = NO;
    //[self searchBarShouldEndEditing:_searchBar];
}

#pragma mark - UISearchBar Delegate Methods
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    NSLog(@"type");
//    return YES;
//}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self showSearchBar];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (self.tableView.hidden == NO) {
        [self hideSearchBar];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self filterContentForSearchText:searchBar.text
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
}

//#pragma mark - other methods
//- (void)keyboardWillShow:(NSNotification *)notification {
//    NSLog(@"keyboard changed");
//    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    NSLog(@"%@", NSStringFromCGSize(keyboardSize));
//}


- (void)showSearchBar {
    // if search bar is not already shown
    if (_searchBar.frame.origin.y > 20) {
        [_searchBar addSubview:_statusBarCoverView];
        [_searchBar addSubview:_searchBarCoverView];
        //move the search bar up to the correct location eg
        [UIView animateWithDuration:.3
                         animations:^{
                             // move search bar up
                             _searchBar.frame = CGRectMake(_searchBar.frame.origin.x,
                                                           20,
                                                           _searchBar.frame.size.width,
                                                           _searchBar.frame.size.height);
                             // move tableView down
                             [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                                 _searchBar.frame.size.height,
                                                                 self.tableView.frame.size.width,
                                                                 [UIScreen mainScreen].bounds.size.height - 210)];
                             
                             _searchBar.barTintColor = [UIColor clearColor];
                             UITextField *textSearchField = [_searchBar valueForKey:@"_searchField"];
                             NSLog(@"%f, %f", textSearchField.layer.borderWidth, textSearchField.layer.cornerRadius);
                             textSearchField.layer.borderWidth = 0.5f;
                             textSearchField.layer.cornerRadius = 5.0f;
                             textSearchField.layer.borderColor = [UWColorSchemeCenter uwBlack].CGColor;
                             [_searchBarCoverView addSubview:textSearchField];
                             _searchBar.scopeBarBackgroundImage = [self imageWithColor:[UWColorSchemeCenter uwGold]];
                        
                         }
                         completion:^(BOOL finished){
                             //whatever else you may need to do
                         }];

    }
}

- (void)hideSearchBar {
    NSInteger statusBarHeight = 20;
    NSInteger navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    if (_searchBar.frame.origin.y < statusBarHeight + navigationBarHeight) {
        [_statusBarCoverView setFrame:CGRectMake(_statusBarCoverView.frame.origin.x, _statusBarCoverView.frame.origin.y - 22, _statusBarCoverView.frame.size.width, _statusBarCoverView.frame.size.height + 22)];
        //move the search bar down to the correct location eg
        [UIView animateWithDuration:.3
                         animations:^{
                             // move search bar down
                             _searchBar.frame = CGRectMake(_searchBar.frame.origin.x,
                                                           statusBarHeight + navigationBarHeight,
                                                           _searchBar.frame.size.width,
                                                           _searchBar.frame.size.height);
                             // move table view up
                             [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                                 0,
                                                                 self.tableView.frame.size.width,
                                                                 [UIScreen mainScreen].bounds.size.height)];
                             
                             
                         }
                         completion:^(BOOL finished){
                             //whatever else you may need to do
                             _searchBar.barTintColor = nil;
                             [_statusBarCoverView removeFromSuperview];
                             UITextField *textSearchField = [_searchBar valueForKey:@"_searchField"];
                             textSearchField.layer.borderWidth = 0;
                             textSearchField.layer.cornerRadius = 0;
                             textSearchField.layer.borderColor = nil;
                             [_searchBar addSubview:textSearchField];
                             [_searchBarCoverView removeFromSuperview];
                             
                             [_statusBarCoverView setFrame:CGRectMake(_statusBarCoverView.frame.origin.x, _statusBarCoverView.frame.origin.y + 22, _statusBarCoverView.frame.size.width, _statusBarCoverView.frame.size.height - 22)];
                         }];
//        [UIView animateWithDuration:4 animations:^(){
//            _searchBar.barTintColor = nil;
//        }];
    }
}


- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *controlletr = segue.destinationViewController;
    _tabBarController.detailViewControllerOfTabbar2 = controlletr;
    controlletr.caller = sender[0];
    controlletr.infoSession = sender[1];
    controlletr.infoSessionModel = sender[2];
    controlletr.tabBarController = _tabBarController;
}
//
//#pragma mark - iAd delegate methods
//
//- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
//    NSLog(@"iad banner show");
//    [self.view addSubview:_adBannerView];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1];
//    [banner setAlpha:1];
//    [_tableView setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - banner.frame.size.height)];
//    [UIView commitAnimations];
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//    [_adBannerView removeFromSuperview];
//    if (_googleBannerView.alpha == 0) {
//        googleAdRequested = NO;
//    }
//    if (googleAdRequested == NO) {
//        NSLog(@"google ad request");
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
//    [_googleBannerView setAlpha:1];
//    [_tableView setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - bannerView.frame.size.height)];
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
//    [_tableView setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
//    [UIView commitAnimations];
//}
//

@end
