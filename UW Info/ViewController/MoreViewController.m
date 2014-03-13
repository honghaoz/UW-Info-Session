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

@interface MoreViewController ()

@end

@implementation MoreViewController

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
    
    [self.tableView registerClass:[CenterTextCell class] forCellReuseIdentifier:@"CenterCell"];
//    [self.tableView style];
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];
//    NSDictionary *dimensions = @{
//                                 // What type of news is this?
//                                 @"category": @"politics",
//                                 // Is it a weekday or the weekend?
//                                 @"dayType": @"weekday",
//                                 };
//    // Send the dimensions to Parse along with the 'read' event
//    
//    [PFAnalytics trackEvent:@"read" dimensions:dimensions];
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
        if (indexPath.row == 0) {
            NSString *resueIdentifier = @"AccessoryCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = @"Help";
            [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
            return cell;
        } else if (indexPath.row == 1) {
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
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *resueIdentifier = @"CenterCell";
            CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[CenterTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            cell.centerTextLabel.text = @"Tell Friends";
            return cell;
        } else if (indexPath.row == 1) {
            NSString *resueIdentifier = @"CenterCell";
            CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
            if (cell == nil) {
                cell = [[CenterTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resueIdentifier];
            }
            cell.centerTextLabel.text = @"Send Feedback";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
        
        } else if (indexPath.row == 1) {
            
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/app/uw-info-session/id837207884?mt=8"]];
        }
    }
}


#pragma mark - Navigation

- (void)done {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}
@end
