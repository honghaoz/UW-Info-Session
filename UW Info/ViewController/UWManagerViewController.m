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
#import <objc/runtime.h>

@interface UWManagerViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@end

@implementation UWManagerViewController {
    CGPoint lastPosition;
    CGPoint lastUpdatedPosition;
    CGFloat widthOfTable;
    BOOL deviceNameSortAscending;
    BOOL queryKeySortAscending;
    BOOL openTimesSortAscending;
    BOOL appVersionSortAscending;
    BOOL noteSortAscending;
    BOOL deviceTypeSortAscending;
    BOOL systemVersionSortAscending;
    BOOL createTimeSortAscending;
    BOOL updateTimeSortAscending;
    BOOL channelsSortAscending;
    
    NSMutableArray *pfobjects;
    UIButton *deviceButton;
    UIButton *queryKeyButton;
    UIButton *openTimesButton;
    UIButton *appVersionButton;
    UIButton *deviceTypeButton;
    UIButton *systemVersionButton;
    UIButton *channelsButton;
    UIButton *createdButton;
    UIButton *updatedButton;
    UIButton *noteButton;
    
    NSMutableArray *displayedCells;
    UWCellScrollView *titleBarScrollView;
    BOOL shouldPostResignKeyboard;
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
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)],
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(pushToChannels:)],
                                                nil] animated:YES];
    
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
    titleBarScrollView = [[UWCellScrollView alloc] initWithFrame:CGRectMake(0, heightOfTop + heightOfCountView, widthOfTable, heightOfTitleBar)];
    [titleBarScrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleBarScrollView];
    [titleBarScrollView setDelegate:self];
    //[[NSNotificationCenter defaultCenter] addObserver:titleBarScrollView selector:@selector(updateContentOffset:) name:@"UpdateContentOffset" object:nil];
    
    CGFloat seperatorWidth = 10;
    CGFloat deviceNameWidth = 200;
    deviceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deviceButton setTitle:@"Device Name" forState:UIControlStateNormal];
    [deviceButton setTitleColor:UWBlack forState:UIControlStateNormal];
    deviceButton.frame = CGRectMake(seperatorWidth, 0, deviceNameWidth, heightOfTitleBar);
    deviceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:deviceButton];
    [deviceButton addTarget:self action:@selector(deviceNameSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat queryKeyWidth = 30;
    queryKeyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [queryKeyButton setTitle:@"Key" forState:UIControlStateNormal];
    [queryKeyButton setTitleColor:UWBlack forState:UIControlStateNormal];
    queryKeyButton.frame = CGRectMake(deviceButton.frame.origin.x + deviceButton.frame.size.width + seperatorWidth, 0, queryKeyWidth, heightOfTitleBar);
    queryKeyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:queryKeyButton];
    [queryKeyButton addTarget:self action:@selector(queryKeySort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat openTimesWidth = 40;
    openTimesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [openTimesButton setTitle:@"Open" forState:UIControlStateNormal];
    [openTimesButton setTitleColor:UWBlack forState:UIControlStateNormal];
    openTimesButton.frame = CGRectMake(queryKeyButton.frame.origin.x + queryKeyButton.frame.size.width + seperatorWidth, 0, openTimesWidth, heightOfTitleBar);
    openTimesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:openTimesButton];
    [openTimesButton addTarget:self action:@selector(openTimesSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat appVersionWidth = 70;
    appVersionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appVersionButton setTitle:@"Version" forState:UIControlStateNormal];
    [appVersionButton setTitleColor:UWBlack forState:UIControlStateNormal];
    appVersionButton.frame = CGRectMake(openTimesButton.frame.origin.x + openTimesButton.frame.size.width + seperatorWidth, 0, appVersionWidth, heightOfTitleBar);
    appVersionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:appVersionButton];
    [appVersionButton addTarget:self action:@selector(appVersionSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat deviceTypeWidth = 200;
    deviceTypeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deviceTypeButton setTitle:@"Device Type" forState:UIControlStateNormal];
    [deviceTypeButton setTitleColor:UWBlack forState:UIControlStateNormal];
    deviceTypeButton.frame = CGRectMake(appVersionButton.frame.origin.x + appVersionButton.frame.size.width + seperatorWidth, 0, deviceTypeWidth, heightOfTitleBar);
    deviceTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:deviceTypeButton];
    [deviceTypeButton addTarget:self action:@selector(deviceTypeSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat systemVersionWidth = 70;
    systemVersionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [systemVersionButton setTitle:@"System" forState:UIControlStateNormal];
    [systemVersionButton setTitleColor:UWBlack forState:UIControlStateNormal];
    systemVersionButton.frame = CGRectMake(deviceTypeButton.frame.origin.x + deviceTypeButton.frame.size.width + seperatorWidth, 0, systemVersionWidth, heightOfTitleBar);
    systemVersionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:systemVersionButton];
    [systemVersionButton addTarget:self action:@selector(systemVersionSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat channelsWidth = 120;
    channelsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [channelsButton setTitle:@"Channels" forState:UIControlStateNormal];
    [channelsButton setTitleColor:UWBlack forState:UIControlStateNormal];
    channelsButton.frame = CGRectMake(systemVersionButton.frame.origin.x + systemVersionButton.frame.size.width + seperatorWidth, 0, channelsWidth, heightOfTitleBar);
    channelsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:channelsButton];
    [channelsButton addTarget:self action:@selector(channelsSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat createdWidth = 130;
    createdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createdButton setTitle:@"Created" forState:UIControlStateNormal];
    [createdButton setTitleColor:UWBlack forState:UIControlStateNormal];
    //[createdButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    createdButton.frame = CGRectMake(channelsButton.frame.origin.x + channelsButton.frame.size.width + seperatorWidth, 0, createdWidth, heightOfTitleBar);
    createdButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:createdButton];
    [createdButton addTarget:self action:@selector(createTimeSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat updatedWidth = 130;
    updatedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [updatedButton setTitle:@"Updated" forState:UIControlStateNormal];
    [updatedButton setTitleColor:UWBlack forState:UIControlStateNormal];
    updatedButton.frame = CGRectMake(createdButton.frame.origin.x + createdButton.frame.size.width + seperatorWidth, 0, updatedWidth, heightOfTitleBar);
    updatedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:updatedButton];
    [updatedButton addTarget:self action:@selector(updateTimeSort) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat noteWidth = 100;
    noteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [noteButton setTitle:@"Notes" forState:UIControlStateNormal];
    [noteButton setTitleColor:UWBlack forState:UIControlStateNormal];
    noteButton.frame = CGRectMake(updatedButton.frame.origin.x + updatedButton.frame.size.width + seperatorWidth, 0, noteWidth, heightOfTitleBar);
    noteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleBarScrollView addSubview:noteButton];
    [noteButton addTarget:self action:@selector(noteSort) forControlEvents:UIControlEventTouchUpInside];
    
    pfobjects = [[NSMutableArray alloc] init];
    
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
                objc_setAssociatedObject(newDevice, @"PFObject", object, OBJC_ASSOCIATION_RETAIN);
                // add this new device object to the array
                [self.devices addObject:newDevice];
                //[pfobjects addObject:object];
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime"
                                                                           ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [_devices sortUsingDescriptors:sortDescriptors];
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
//    [_tableView setContentInset:UIEdgeInsetsMake(30, 0, 0, 0)];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -10 - 30, 100, 10)];
//    [view setBackgroundColor:[UIColor redColor]];
//    [_tableView addSubview:view];
    
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
    if (displayedCells == nil) {
        displayedCells = [[NSMutableArray alloc] init];
    }
    //[displayedCells addObject:titleBarScrollView];
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
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    cell.deviceName.userInteractionEnabled = YES;
    [cell.deviceName addGestureRecognizer:singleTap];
    //[cell.scrollView addGestureRecognizer:singleTap];
    
    cell.queryKey.text = theDevice.queryKey;
    if ([theDevice.queryKey isEqualToString:@"null"]) {
        cell.queryKey.textColor = [UIColor lightGrayColor];
    } else {
        cell.queryKey.textColor = [UIColor blackColor];
    }
    //cell.queryKey.delegate = self;
    [cell.queryKey setDelegate:self];
    //[cell.queryKey setKeyboardType:UIKeyboardTypeDefault];
    [cell.queryKey setReturnKeyType:UIReturnKeyDone];
    [cell.queryKey addTarget:self action:@selector(queryKeyChangedDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ResignKeyboard" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //[cell.queryKey.delegate textFieldShouldReturn:cell.queryKey];
        [cell.queryKey resignFirstResponder];
    }];
    [cell.queryKey setAutocorrectionType:UITextAutocorrectionTypeNo];
    //[[NSNotificationCenter defaultCenter] addObserver:cell.queryKey selector:@selector() name:@"ResignKeyboard" object:nil];
    objc_setAssociatedObject(cell.queryKey, @"Device", theDevice, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(cell.queryKey, @"Key", @"QueryKey", OBJC_ASSOCIATION_RETAIN);
    
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
    [dateFormatter setDateFormat:@"MMM d, y, HH:mm"];
    cell.created.text = [dateFormatter stringFromDate:theDevice.createTime];
    cell.updated.text = [dateFormatter stringFromDate:theDevice.updateTime];
    cell.channels.text = [theDevice.channels componentsJoinedByString:@", "];
    [cell.channels setDelegate:self];
    [cell.channels setReturnKeyType:UIReturnKeyDone];
    [cell.channels addTarget:self action:@selector(channelsChangedDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ResignKeyboard" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //[cell.queryKey.delegate textFieldShouldReturn:cell.queryKey];
        [cell.channels resignFirstResponder];
    }];
    objc_setAssociatedObject(cell.channels, @"Device", theDevice, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(cell.channels, @"Key", @"Channels", OBJC_ASSOCIATION_RETAIN);
    [cell.channels setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    cell.note.text = theDevice.note;
    if ([theDevice.note isEqualToString:@"null"]) {
        cell.note.textColor = [UIColor lightGrayColor];
    } else {
        cell.note.textColor = [UIColor blackColor];
    }
    [cell.note setDelegate:self];
    [cell.note setReturnKeyType:UIReturnKeyDone];
    [cell.note addTarget:self action:@selector(noteChangedDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ResignKeyboard" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //[cell.queryKey.delegate textFieldShouldReturn:cell.queryKey];
        [cell.note resignFirstResponder];
    }];
    objc_setAssociatedObject(cell.note, @"Device", theDevice, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(cell.note, @"Key", @"Note", OBJC_ASSOCIATION_RETAIN);
    [cell.note setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [cell.scrollView setDelegate:self];
    cell.scrollView.contentOffset = lastUpdatedPosition;
    //[[NSNotificationCenter defaultCenter] addObserver:cell.scrollView selector:@selector(updateContentOffset:) name:@"UpdateContentOffset" object:nil];
//    [cell.contentView addSubview:cell.scrollView];
    //NSLog(@"add observer: %d", indexPath.row);
//    objc_setAssociatedObject(cell.scrollView, @"PFObject", [pfobjects objectAtIndex:indexPath.row], OBJC_ASSOCIATION_RETAIN);
    [displayedCells addObject:cell];
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UWDeviceCell *theCell = (UWDeviceCell *)cell;
    [displayedCells removeObject:theCell];
    //[[NSNotificationCenter defaultCenter] removeObserver:theCell.scrollView];
//    [theCell.scrollView removeFromSuperview];
    //NSLog(@"remove observer: %d", indexPath.row);
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"last y: %0.2f", lastPosition.y);
    //NSLog(@"scroll y: %0.2f", scrollView.contentOffset.y);
    if ([scrollView isMemberOfClass:[UWCellScrollView class]]) {
        lastUpdatedPosition = scrollView.contentOffset;
        [self updateContentOffset];
    }
    //NSLog(@"offset.y = %f", scrollView.contentOffset.y);
//    if (lastUpdatedPosition.y == scrollView.contentOffset.y) {
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateContentOffset" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:scrollView.contentOffset] forKey:@"CurrentContentOffset"]];
//        
//    }
    //lastPosition = scrollView.contentOffset;
    //NSLog(@"scrollView offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
    //NSLog(@"post notification");
}

- (void)updateContentOffset {
    //NSLog(@"update contentOffset");
    titleBarScrollView.contentOffset = lastUpdatedPosition;
    for (UWDeviceCell *eachCell in displayedCells) {
        eachCell.scrollView.contentOffset = lastUpdatedPosition;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (shouldPostResignKeyboard) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignKeyboard" object:nil];
    }
}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignKeyboard" object:nil];
//}

#pragma mark - textField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@"null"]) {
        textField.text = @"";
    }
    textField.textColor = [UIColor blackColor];
    shouldPostResignKeyboard = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *key = objc_getAssociatedObject(textField, @"Key");
    if ([key isEqualToString:@"Note"]) {
        UWDevice *theDevice = objc_getAssociatedObject(textField, @"Device");
        textField.text = theDevice.note;
    } else if ([key isEqualToString:@"QueryKey"]) {
        UWDevice *theDevice = objc_getAssociatedObject(textField, @"Device");
        textField.text = theDevice.queryKey;
    }
    if ([textField.text isEqualToString:@"null"]) {
        textField.textColor = [UIColor lightGrayColor];
    } else {
        textField.textColor = [UIColor blackColor];
    }
    shouldPostResignKeyboard = NO;
}

#pragma mark - others
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    //NSLog(@"single Tap on imageview");
    UILabel *labelTapped = (UILabel *)gestureRecognizer.view;
    //NSLog(@"%@", labelTapped.text);
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:[NSString stringWithFormat:@"%@", labelTapped.text] message:[NSString stringWithFormat:@"Send notification to %@", labelTapped.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert addButtonWithTitle:@"Send"];
    alert.tag = 0;
    objc_setAssociatedObject(alert, @"DeviceName", labelTapped.text, OBJC_ASSOCIATION_RETAIN);
    [alert show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {  //Send
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"Device_Name" equalTo:objc_getAssociatedObject(alertView, @"DeviceName")];
            // Send push notification to query
            UITextField *message = [alertView textFieldAtIndex:0];
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"YES", @"ShouldReply",
                                  [[UIDevice currentDevice] name], @"Sender",
                                  message.text, @"Message",
                                  message.text, @"alert",
                                  @"Increment", @"badge",
                                  @"alarm.caf", @"sound",
                                  nil];
            NSLog(@"sender: %@", [[UIDevice currentDevice] name]);
            NSLog(@"receiver: %@", objc_getAssociatedObject(alertView, @"DeviceName"));
            NSLog(@"message: %@", message.text);
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery]; // Set our Installation query
            
            [push setData:data];
            [push sendPushInBackground];
        }
    } else if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *message = [alertView textFieldAtIndex:0];
            NSString *channelsString = message.text;
            
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Send to Channels" message:channelsString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert addButtonWithTitle:@"Send"];
            alert.tag = 2;
            [alert show];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            NSArray *channels = [alertView.message componentsSeparatedByString:@", "];
//            for (NSString *eachChannel in channels) {
//                NSLog(@"%@", eachChannel);
//            }
            UITextField *message = [alertView textFieldAtIndex:0];
            NSLog(@"send: %@", message);
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"NO", @"ShouldReply",
                                  [[UIDevice currentDevice] name], @"Sender",
                                  message.text, @"Message",
                                  message.text, @"alert",
                                  @"Increment", @"badge",
                                  @"alarm.caf", @"sound",
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            [push setChannels:channels];
            //[push setMessage:message.text];
            [push setData:data];
            [push sendPushInBackground];
        }
    }
}

#pragma mark -

- (void)deviceNameSort{
    deviceNameSortAscending = !deviceNameSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName"
                                                                   ascending:deviceNameSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!deviceNameSortAscending) {
    //        [deviceButton setTitle:@"Device Name ▾" forState:UIControlStateNormal];
    //    } else {
    //        [deviceButton setTitle:@"Device Name ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)queryKeySort{
    queryKeySortAscending = !queryKeySortAscending;
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"queryKey"
    //                                                                   ascending:queryKeySortAscending];
    //    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //    [_devices sortUsingDescriptors:sortDescriptors];
    NSLog(@"queryKey sort");
    _devices = [NSMutableArray arrayWithArray:[_devices sortedArrayUsingComparator:^NSComparisonResult(UWDevice *a, UWDevice *b){
        NSNumber *aKey = [NSNumber numberWithInteger:[a.queryKey integerValue]];
        NSNumber *bKey = [NSNumber numberWithInteger:[b.queryKey integerValue]];
        if (queryKeySortAscending) {
            return [aKey compare:bKey];
        } else {
            return [bKey compare:aKey];
        }
    }]];
    [_tableView reloadData];
}

- (void)openTimesSort{
    openTimesSortAscending = !openTimesSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"openTimes"
                                                                   ascending:openTimesSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    [_tableView reloadData];
}

- (void)appVersionSort{
    appVersionSortAscending = !appVersionSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appVersion"
                                                                   ascending:appVersionSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!appVersionSortAscending) {
    //        [appVersionButton setTitle:@"Version ▾" forState:UIControlStateNormal];
    //    } else {
    //        [appVersionButton setTitle:@"Version ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)noteSort{
    noteSortAscending = !noteSortAscending;
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"note"
//                                                                   ascending:noteSortAscending];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    [_devices sortUsingDescriptors:sortDescriptors];
    _devices = [NSMutableArray arrayWithArray:[_devices sortedArrayUsingComparator:^NSComparisonResult(UWDevice *a, UWDevice *b){
//        NSNumber *aKey = [NSNumber numberWithInteger:[a.queryKey integerValue]];
//        NSNumber *bKey = [NSNumber numberWithInteger:[b.queryKey integerValue]];
        if ([a.note isEqualToString:@"null"] && [b.note isEqualToString:@"null"]) {
            return NSOrderedSame;
        }
        if (noteSortAscending) {
            if ([a.note isEqualToString:@"null"]) {
                return NSOrderedDescending;
            } else if ([b.note isEqualToString:@"null"]) {
                return NSOrderedAscending;
            } else {
                return [a.note compare:b.note];
            }
        } else {
            if ([a.note isEqualToString:@"null"]) {
                return NSOrderedAscending;
            } else if ([b.note isEqualToString:@"null"]) {
                return NSOrderedDescending;
            } else {
                return [b.note compare:a.note];
            }
        }
    }]];
    [_tableView reloadData];
}

- (void)deviceTypeSort{
    deviceTypeSortAscending = !deviceTypeSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceType"
                                                                   ascending:deviceTypeSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!deviceTypeSortAscending) {
    //        [deviceTypeButton setTitle:@"Device Type ▾" forState:UIControlStateNormal];
    //    } else {
    //        [deviceTypeButton setTitle:@"Device Type ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)systemVersionSort{
    systemVersionSortAscending = !systemVersionSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"systemVersion"
                                                                   ascending:systemVersionSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!systemVersionSortAscending) {
    //        [systemVersionButton setTitle:@"System ▾" forState:UIControlStateNormal];
    //    } else {
    //        [systemVersionButton setTitle:@"System ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)createTimeSort{
    createTimeSortAscending = !createTimeSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime"
                                                                   ascending:createTimeSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!createTimeSortAscending) {
    //        [createdButton setTitle:@"Created ▾" forState:UIControlStateNormal];
    //    } else {
    //        [createdButton setTitle:@"Created ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)updateTimeSort{
    updateTimeSortAscending = !updateTimeSortAscending;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTime"
                                                                   ascending:updateTimeSortAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_devices sortUsingDescriptors:sortDescriptors];
    [_devices sortUsingDescriptors:sortDescriptors];
    //    if (!updateTimeSortAscending) {
    //        [updatedButton setTitle:@"Updated ▾" forState:UIControlStateNormal];
    //    } else {
    //        [updatedButton setTitle:@"Updated ▴" forState:UIControlStateNormal];
    //    }
    [_tableView reloadData];
}

- (void)channelsSort{
    channelsSortAscending = !channelsSortAscending;
    _devices = [NSMutableArray arrayWithArray:[_devices sortedArrayUsingComparator:^NSComparisonResult(UWDevice *a, UWDevice *b){
        NSString *aa = [a.channels objectAtIndex:0];
        NSString *bb = [b.channels objectAtIndex:0];
        //NSNumber *aKey = [NSNumber numberWithInteger:[a.queryKey integerValue]];
        //NSNumber *bKey = [NSNumber numberWithInteger:[b.queryKey integerValue]];
        if (channelsSortAscending) {
            return [aa compare:bb];
        } else {
            return [bb compare:aa];
        }
    }]];
    [_tableView reloadData];

    //    channelsSortAscending = !channelsSortAscending;
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"channels"
    //                                                                   ascending:channelsSortAscending];
    //    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    //    [_devices sortUsingDescriptors:sortDescriptors];
    //    [_tableView reloadData];
}

- (void)queryKeyChangedDone:(id)sender {
    UWDevice *theDevice = objc_getAssociatedObject(sender, @"Device");
    //NSLog(@"%@", theDevice.deviceName);
    PFObject *thePFObject = objc_getAssociatedObject(theDevice, @"PFObject");
    thePFObject[@"Query_Key"] = [(UITextField *)sender text];
    theDevice.queryKey = [(UITextField *)sender text];
    [thePFObject saveInBackground];
    //NSLog(@"%@", [(UITextField *)sender text]);
}

- (void)noteChangedDone:(id)sender {
    UWDevice *theDevice = objc_getAssociatedObject(sender, @"Device");
    //NSLog(@"%@", theDevice.deviceName);
    PFObject *thePFObject = objc_getAssociatedObject(theDevice, @"PFObject");
    if ([[(UITextField *)sender text] isEqualToString:@"null"] ||
        [[(UITextField *)sender text] isEqualToString:@""]) {
        //thePFObject[@"Note"] = nil;
        [thePFObject removeObjectForKey:@"Note"];
        theDevice.note = @"null";
    } else {
        thePFObject[@"Note"] = [(UITextField *)sender text];
        theDevice.note = [(UITextField *)sender text];
    }
    [thePFObject saveInBackground];
    //NSLog(@"%@", [(UITextField *)sender text]);
}

- (void)channelsChangedDone:(id)sender {
    UWDevice *theDevice = objc_getAssociatedObject(sender, @"Device");
    //NSLog(@"%@", theDevice.deviceName);
    PFObject *thePFObject = objc_getAssociatedObject(theDevice, @"PFObject");
    if ([[(UITextField *)sender text] isEqualToString:@""]) {
        //thePFObject[@"Note"] = nil;
        [thePFObject removeObjectForKey:@"Channels"];
        theDevice.channels = nil;
    } else {
        thePFObject[@"Channels"] = [[(UITextField *)sender text] componentsSeparatedByString:@", "];
        theDevice.channels = [[(UITextField *)sender text] componentsSeparatedByString:@", "];
    }
    [thePFObject saveInBackground];
    //NSLog(@"%@", [(UITextField *)sender text]);
}

- (void)reload:(id)sender {
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
            [self.devices removeAllObjects];
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
                objc_setAssociatedObject(newDevice, @"PFObject", object, OBJC_ASSOCIATION_RETAIN);
                // add this new device object to the array
                [self.devices addObject:newDevice];
                //[pfobjects addObject:object];
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime"
                                                                           ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [_devices sortUsingDescriptors:sortDescriptors];
            NSLog(@"devices: %d", [self.devices count]);
            [_tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)pushToChannels:(id)sender {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Send to Channels" message:@"Set channels..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert addButtonWithTitle:@"Set"];
    alert.tag = 1;
    [alert show];
}

@end
