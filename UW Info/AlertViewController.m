//
//  AlertViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/11/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AlertViewController.h"
#import "InfoSession.h"
#import "InfoSessionModel.h"

@interface AlertViewController ()

@end

@implementation AlertViewController

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
    // initiated alertChoices
    _alertChoices = [[NSMutableArray alloc] initWithCapacity:[_infoSessionModel.alertChoiceDictionary count]];
    NSMutableArray *allKeys = [[_infoSessionModel.alertChoiceDictionary allKeys] mutableCopy];
    [allKeys sortUsingComparator:^(NSString *key1, NSString *key2) {
        return [key1 compare:key2];
    }];
    for (NSString *key in allKeys) {
        [_alertChoices addObject:[_infoSessionModel.alertChoiceDictionary objectForKey:key]];
    }
    
    NSMutableDictionary *theAlert = _infoSession.alerts[_alertIndexOfAlertArray];
    _checkRow = [theAlert[@"alertChoice"] integerValue];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_alertChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = _alertChoices[indexPath.row];
    
    if (_checkRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // set check mark to new selected row
    UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_checkRow inSection:0]];
    checkedCell.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell *newlyCheckedCell = [tableView cellForRowAtIndexPath:indexPath];
    newlyCheckedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // set choosed alert choice to infosession.alerts
    [_infoSession setAlertChoiceForAlertDictionaryAtIndex:_alertIndexOfAlertArray newChoice:indexPath.row];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
