//
//  UWManagerViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 5/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWManagerViewController.h"
#import <Parse/Parse.h>
#import "UWDevice.h"
#import "UWDeviceCell.h"

@interface UWManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation UWManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// lazy initialization
- (NSMutableArray* )devices {
    if (_devices == nil) {
        _devices = [[NSMutableArray alloc] init];
        return _devices;
    } else {
        return _devices;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
//    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    self.title = @"UW Info Manager";
    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:UWGold];
    self.navigationController.navigationBar.tintColor = UWBlack;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat heightOfTop = 20 + self.navigationController.navigationBar.frame.size.height;
    CGFloat heightOfCountView = 50.0;
    UIView *countView = [[UIView alloc] initWithFrame:CGRectMake(0, heightOfTop, screenSize.width, heightOfCountView)];
    countView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    _countOfDevice = [[UILabel alloc] initWithFrame:CGRectInset(countView.bounds, 30, 10)];
    _countOfDevice.backgroundColor = [UIColor clearColor];
    //_countOfDevice.text =
    [self.view addSubview:countView];
    [countView addSubview:_countOfDevice];
    
    __block NSInteger numberOfDevice = 0;
    PFQuery *query = [PFQuery queryWithClassName:@"Device"];
    //[queryForId whereKey:@"Installation" notEqualTo:nil];
    [query setLimit: 1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            numberOfDevice = [objects count];
            NSLog(@"count %d", numberOfDevice);
            [self setNumberOfDevices:numberOfDevice];
            for (PFObject *object in objects) {
                // create a new device object and initialize it
                UWDevice *newDevice = [[UWDevice alloc] init];
                newDevice.deviceName = object[@"Device_Name"];
                NSString *Query_Key = object[@"Query_Key"];
                if (Query_Key == nil) {
                    newDevice.queryKey = @"(undefined)";
                } else {
                    newDevice.queryKey = Query_Key;
                }
                newDevice.openTimes = [NSNumber numberWithInteger:[object[@"Opens"] integerValue]];
                
                NSString *App_Version = object[@"App_Version"];
                if (App_Version == nil) {
                    newDevice.appVersion = @"(undefined)";
                } else {
                    newDevice.appVersion = App_Version;
                }
                
                NSString *Note = object[@"Note"];
                if (Note == nil) {
                    newDevice.note = @"(undefined)";
                } else {
                    newDevice.note = Note;
                }
                
                NSString *Device_Type = object[@"Device_Type"];
                if (Device_Type == nil) {
                    newDevice.deviceType = @"(undefined)";
                } else {
                    newDevice.deviceType = Device_Type;
                }
                
                NSString *System_Version = object[@"System_Version"];
                if (System_Version == nil) {
                    newDevice.systemVersion = @"(undefined)";
                } else {
                    newDevice.systemVersion = System_Version;
                }
                
                newDevice.createTime = object[@"createdAt"];
                newDevice.updateTime = object[@"updatedAt"];
                
                // add this new device object to the array
                [self.devices addObject:newDevice];
//                for (UWDevice *eachDevice in self.devices) {
//                    NSLog(@"Device Name: %@", eachDevice.deviceName);
//                }
            }
            NSLog(@"devices: %d", [self.devices count]);
            [_tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    _countOfDevice.text = [NSString stringWithFormat:@"Devices: %d+", numberOfDevice];
    [_countOfDevice setTextAlignment:NSTextAlignmentCenter];
    [_countOfDevice setFont:[UIFont boldSystemFontOfSize:22]];
    [_countOfDevice setTextColor:[UIColor darkGrayColor]];
    
    // set tableview
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, heightOfTop + heightOfCountView, screenSize.width, screenSize.height - heightOfTop - heightOfCountView) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)setNumberOfDevices:(NSInteger )number {
    _countOfDevice.text = [NSString stringWithFormat:@"Devices: %d+", number];
}

#pragma mark - tableView data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"return number of rows %d", [self.devices count]);
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *resueIdentifier = @"DeviceCell";
    UWDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:resueIdentifier];
    if (cell == nil) {
        cell = [[UWDeviceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resueIdentifier];
    }
    UWDevice *theDevice = [self.devices objectAtIndex:indexPath.row];
    cell.deviceNameTextLabel.text = theDevice.deviceName;
    cell.queryKeyTextLabel.text = theDevice.queryKey;
    cell.openTimesTextLabel.text = [NSString stringWithFormat:@"%d", [theDevice.openTimes integerValue]];
    return cell;
}

#pragma mark - tableView delegate

@end
