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

#import "InfoSession.h"

@interface DetailViewController ()

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
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
        case 1: numberOfRows = 4; break;
        case 2: numberOfRows = 1; break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.titleLabel.text = @"Employer";
            cell.contentLabel.text = _infoSession.employer;
            return cell;
        }
        else if (indexPath.row == 1) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.titleLabel.text = @"Date";
            //
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMMM d, y"];
            cell.contentLabel.text = [dateFormatter stringFromDate:_infoSession.date];
            return cell;
        }
        else if (indexPath.row == 2) {
            DetailNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailNormalCell"];
            cell.titleLabel.text = @"Time";
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"h:mm a"];
            cell.contentLabel.text = [NSString stringWithFormat:@"%@ - %@", [timeFormatter stringFromDate:_infoSession.startTime], [timeFormatter stringFromDate:_infoSession.endTime]];
            return cell;
        }
        else if (indexPath.row == 3) {
            DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
            [cell.contentLabel setFont:[UIFont systemFontOfSize:16]];
            cell.titleLabel.text = @"Location";
            if ([_infoSession.website length] <= 1) {
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
            cell.contentLabel.text = @"Tap here to RSVP.";
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            DetailLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailLinkCell"];
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
            cell.titleLabel.text = @"Students";
            cell.contentLabel.text = _infoSession.audience;
            return cell;
        }
        else if (indexPath.row == 2) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            [cell.contentText setSelectable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            [cell.contentText setSelectable:NO];
            cell.titleLabel.text = @"Programs";
            if ([_infoSession.programs length] <= 1) {
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
                cell.contentText.text = @"No Programs Infomation";
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.programs;
            }
            return cell;
        }
        else if (indexPath.row == 3) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            [cell.contentText setSelectable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            [cell.contentText setSelectable:NO];
            cell.titleLabel.text = @"Descriptions";
            if ([_infoSession.description length] <= 1) {
                [cell.contentText setTextColor: [UIColor lightGrayColor]];
                cell.contentText.text = @"No Descriptions";
            } else {
                [cell.contentText setTextColor: [UIColor blackColor]];
                cell.contentText.text = _infoSession.description;
            }
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescriptionCell"];
            [cell.contentText setSelectable:YES];
            [cell.contentText setEditable:YES];
            [cell.contentText setFont:[UIFont systemFontOfSize:15]];
            cell.titleLabel.text = @"Notes";
            [cell.contentText setTextColor: [UIColor blackColor]];
            cell.contentText.text = @"Taking some notes here!";
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
        case 1:
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
        case 2:
            switch (indexPath.row) {
                case 0: height = 100.0f; break;
            } break;
    }
    return height;
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
