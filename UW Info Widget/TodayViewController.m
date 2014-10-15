//
//  TodayViewController.m
//  UW Info Widget
//
//  Created by Honghao on 10/14/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
//    InfoSessionModel *_infoSessionModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ZHH: [%@ %@]", NSStringFromClass(self.class),NSStringFromSelector(_cmd)); // Log out method name
    self.helloLabel.text = @"loaded";
}

- (NSString *)get {
    NSString* path = [[self class] dataFilePath:@"InfoSession.plist"];
    NSString *kk = @"Nothing";
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData* data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        //        _myInfoSessions = [unarchiver decodeObjectForKey:@"myInfoSessions"];
        kk = [unarchiver decodeObjectForKey:@"apiKey"];
//        NSLog(@"%@", apiKey);
        [unarchiver finishDecoding];
    }
    return kk;
}

+ (NSString*)documentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSString*)dataFilePath:(NSString*)fileName
{
    return [[self documentsDirectory] stringByAppendingPathComponent:fileName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    self.helloLabel.text = [self get];
    completionHandler(NCUpdateResultNewData);
}

@end
