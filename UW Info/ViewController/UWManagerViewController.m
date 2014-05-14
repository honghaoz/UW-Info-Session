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
#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
//#import "UWGridTableView.h"
#import "UWCellScrollView.h"
#import "InfoSession.h"

@interface UWManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation UWManagerViewController {
    CGPoint lastPosition;
    CGFloat widthOfTable;
}

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
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    //[self.navigationItem setRightBarButtonItem:doneButton];
    
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
    
    CGFloat heightOfTitleBar = 25;
    widthOfTable = 640;
    UWCellScrollView *titleBarScrollView = [[UWCellScrollView alloc] initWithFrame:CGRectMake(0, heightOfTop + heightOfCountView, widthOfTable, heightOfTitleBar)];
    [titleBarScrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleBarScrollView];
    [titleBarScrollView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:titleBarScrollView selector:@selector(updateContentOffset:) name:@"UpdateContentOffset" object:nil];
    
    CGFloat seperatorWidth = 10;
    CGFloat deviceNameWidth = 200;
    UIButton *deviceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deviceButton setTitle:@"Device Name" forState:UIControlStateNormal];
    [deviceButton setTitleColor:UWBlack forState:UIControlStateNormal];
    deviceButton.frame = CGRectMake(seperatorWidth, 0, deviceNameWidth, heightOfTitleBar);
    deviceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:deviceButton];
    
    CGFloat queryKeyWidth = 30;
    UIButton *queryKeyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [queryKeyButton setTitle:@"Key" forState:UIControlStateNormal];
    [queryKeyButton setTitleColor:UWBlack forState:UIControlStateNormal];
    queryKeyButton.frame = CGRectMake(deviceButton.frame.origin.x + deviceButton.frame.size.width + seperatorWidth, 0, queryKeyWidth, heightOfTitleBar);
    queryKeyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:queryKeyButton];
    
    CGFloat openTimesWidth = 40;
    UIButton *openTimesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [openTimesButton setTitle:@"Open" forState:UIControlStateNormal];
    [openTimesButton setTitleColor:UWBlack forState:UIControlStateNormal];
    openTimesButton.frame = CGRectMake(queryKeyButton.frame.origin.x + queryKeyButton.frame.size.width + seperatorWidth, 0, openTimesWidth, heightOfTitleBar);
    openTimesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:openTimesButton];
    
    CGFloat appVersionWidth = 70;
    UIButton *appVersionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appVersionButton setTitle:@"Version" forState:UIControlStateNormal];
    [appVersionButton setTitleColor:UWBlack forState:UIControlStateNormal];
    appVersionButton.frame = CGRectMake(openTimesButton.frame.origin.x + openTimesButton.frame.size.width + seperatorWidth, 0, appVersionWidth, heightOfTitleBar);
    appVersionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:appVersionButton];
    
    CGFloat deviceTypeWidth = 200;
    UIButton *deviceTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deviceTypeButton setTitle:@"Device Type" forState:UIControlStateNormal];
    [deviceTypeButton setTitleColor:UWBlack forState:UIControlStateNormal];
    deviceTypeButton.frame = CGRectMake(appVersionButton.frame.origin.x + appVersionButton.frame.size.width + seperatorWidth, 0, deviceTypeWidth, heightOfTitleBar);
    deviceTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:deviceTypeButton];
    
    CGFloat systemVersionWidth = 70;
    UIButton *systemVersionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [systemVersionButton setTitle:@"System" forState:UIControlStateNormal];
    [systemVersionButton setTitleColor:UWBlack forState:UIControlStateNormal];
    systemVersionButton.frame = CGRectMake(deviceTypeButton.frame.origin.x + deviceTypeButton.frame.size.width + seperatorWidth, 0, systemVersionWidth, heightOfTitleBar);
    systemVersionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:systemVersionButton];
    
    CGFloat channelsWidth = 120;
    UIButton *channelsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [channelsButton setTitle:@"Channels" forState:UIControlStateNormal];
    [channelsButton setTitleColor:UWBlack forState:UIControlStateNormal];
    channelsButton.frame = CGRectMake(systemVersionButton.frame.origin.x + systemVersionButton.frame.size.width + seperatorWidth, 0, channelsWidth, heightOfTitleBar);
    channelsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:channelsButton];
    
    CGFloat createdWidth = 130;
    UIButton *createdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createdButton setTitle:@"Created" forState:UIControlStateNormal];
    [createdButton setTitleColor:UWBlack forState:UIControlStateNormal];
    createdButton.frame = CGRectMake(channelsButton.frame.origin.x + channelsButton.frame.size.width + seperatorWidth, 0, createdWidth, heightOfTitleBar);
    createdButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:createdButton];
    
    CGFloat updatedWidth = 130;
    UIButton *updatedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [updatedButton setTitle:@"Updated" forState:UIControlStateNormal];
    [updatedButton setTitleColor:UWBlack forState:UIControlStateNormal];
    updatedButton.frame = CGRectMake(createdButton.frame.origin.x + createdButton.frame.size.width + seperatorWidth, 0, updatedWidth, heightOfTitleBar);
    updatedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:updatedButton];
    
    CGFloat noteWidth = 100;
    UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [noteButton setTitle:@"Notes" forState:UIControlStateNormal];
    [noteButton setTitleColor:UWBlack forState:UIControlStateNormal];
    noteButton.frame = CGRectMake(updatedButton.frame.origin.x + updatedButton.frame.size.width + seperatorWidth, 0, noteWidth, heightOfTitleBar);
    noteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:noteButton];
    
    
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
                    newDevice.queryKey = @"null";
                } else {
                    newDevice.queryKey = Query_Key;
                }
                newDevice.openTimes = [NSNumber numberWithInteger:[object[@"Opens"] integerValue]];
                
                NSString *App_Version = object[@"App_Version"];
                if (App_Version == nil) {
                    newDevice.appVersion = @"null";
                } else {
                    newDevice.appVersion = App_Version;
                }
                
                NSString *Device_Type = object[@"Device_Type"];
                if (Device_Type == nil) {
                    newDevice.deviceType = @"null";
                } else {
                    newDevice.deviceType = Device_Type;
                }
                
                NSString *System_Version = object[@"System_Version"];
                if (System_Version == nil) {
                    newDevice.systemVersion = @"null";
                } else {
                    newDevice.systemVersion = System_Version;
                }
                
                newDevice.createTime = object.createdAt;
                newDevice.updateTime = object.updatedAt;
                
                newDevice.channels = object[@"Channels"];
                
                NSString *Note = object[@"Note"];
                if (Note == nil) {
                    newDevice.note = @"null";
                } else {
                    newDevice.note = Note;
                }
                
                // add this new device object to the array
                [self.devices addObject:newDevice];
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, heightOfTop + heightOfCountView + heightOfTitleBar, screenSize.width, screenSize.height - heightOfTop - heightOfCountView - heightOfTitleBar) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
//    CGRect gridTableFrame = CGRectMake(0, heightOfTop + heightOfCountView, screenSize.width, screenSize.height - heightOfTop - heightOfCountView);
//    CGSize gridTableContentSize = CGSizeMake(2 * gridTableFrame.size.width, 2 * gridTableFrame.size.height);
//    UWGridTableView *gridTable = [[UWGridTableView alloc] initWithFrame:gridTableFrame andContentSize:gridTableContentSize byNumberOfColumns:9 andRows:50];
//    
//    [self.view addSubview:gridTable];
    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(200, 200)];
//    [path addLineToPoint:CGPointMake(100, 100)];
//    
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = [path CGPath];
//    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
//    shapeLayer.lineWidth = 3.0;
//    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
//    
//    [self.view.layer addSublayer:shapeLayer];
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
    cell.deviceName.text = theDevice.deviceName;
    cell.queryKey.text = theDevice.queryKey;
    if ([theDevice.queryKey isEqualToString:@"null"]) {
        cell.queryKey.textColor = [UIColor lightGrayColor];
    } else {
        cell.queryKey.textColor = [UIColor blackColor];
    }
    cell.openTimes.text = [NSString stringWithFormat:@"%d", [theDevice.openTimes integerValue]];
    cell.appVersion.text = theDevice.appVersion;
    if ([theDevice.appVersion isEqualToString:@"null"]) {
        cell.appVersion.textColor = [UIColor lightGrayColor];
    } else {
        cell.appVersion.textColor = [UIColor blackColor];
    }
    cell.deviceType.text = theDevice.deviceType;
    if ([theDevice.deviceType isEqualToString:@"null"]) {
        cell.deviceType.textColor = [UIColor lightGrayColor];
    } else {
        cell.deviceType.textColor = [UIColor blackColor];
    }
    cell.systemVersion.text = theDevice.systemVersion;
    if ([theDevice.systemVersion isEqualToString:@"null"]) {
        cell.systemVersion.textColor = [UIColor lightGrayColor];
    } else {
        cell.systemVersion.textColor = [UIColor blackColor];
    }
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"MMM d, y, H:m"];
    cell.created.text = [dateFormatter stringFromDate:theDevice.createTime];
    cell.updated.text = [dateFormatter stringFromDate:theDevice.updateTime];
    cell.channels.text = [theDevice.channels componentsJoinedByString:@", "];
//    if ([theDevice.channels isEqualToString:@"null"]) {
//        cell.channels.textColor = [UIColor lightGrayColor];
//    } else {
//        cell.channels.textColor = [UIColor blackColor];
//    }
    cell.note.text = theDevice.note;
    if ([theDevice.note isEqualToString:@"null"]) {
        cell.note.textColor = [UIColor lightGrayColor];
    } else {
        cell.note.textColor = [UIColor blackColor];
    }
    
    
    [cell.scrollView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:cell.scrollView selector:@selector(updateContentOffset:) name:@"UpdateContentOffset" object:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

#pragma makr - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((lastPosition.y - scrollView.contentOffset.y) == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateContentOffset" object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:scrollView.contentOffset] forKey:@"CurrentContentOffset"]];
    }
    //NSLog(@"scrollView offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
    //NSLog(@"post notification");
    lastPosition = scrollView.contentOffset;
}

@end
