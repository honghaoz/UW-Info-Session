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

#import "UIImageView+AFNetworking.h"

@interface InfoSessionsViewController ()

@property (nonatomic, strong) NSArray *infoSessions;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // show refresh button
    //[[UIBarButtonItem appearance] setTintColor:[UIColor yellowColor]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
    
    //reload data
    [self reload:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload:(__unused id)sender {
    //change right bar button to indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView] animated:YES];
    
    NSURLSessionTask *task = [InfoSession infoSessionsWithBlock:^(NSArray *sessions, NSError *error) {
        if (!error) {
            self.infoSessions = sessions;
            // reload TableView data
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            // scroll TableView to current date
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:40 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
        // restore right bar button to refresh button
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] animated:YES];
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [activityIndicatorView setAnimatingWithStateOfTask:task];

}

#pragma mark - Table view data source
// Return the title of sections.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"11111";
    } else {
        return @"22222";
    }
}

// Return the number of sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.infoSessions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoSessionCell"];
        [self configureCell:cell withIndexPath:indexPath];
        return cell;
    } else {
        InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoSessionCell"];
        return cell;
    }
}
/**
 *  Configure InfoSessionCell
 *
 *  @param cell      InfoSessionCell
 *  @param indexPath IndexPath for the cell
 */
- (void)configureCell:(InfoSessionCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    InfoSession *infoSession = [self.infoSessions objectAtIndex:indexPath.row];
    
    cell.employer.text = infoSession.employer;
    cell.location.text = infoSession.location;
    cell.date.text = [NSString stringWithFormat:@"%@ %@ - %@", infoSession.date, infoSession.startTime, infoSession.endTime];
//    [cell.logo setImageWithURL:infoSession.logoImageURL];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowDetail" sender:nil];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
