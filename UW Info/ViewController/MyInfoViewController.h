//
//  MyInfoViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoSessionModel;
@class UWTabBarController;

@interface MyInfoViewController : UITableViewController

@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, weak) UWTabBarController *tabBarController;

- (void)reloadTable;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;


@end
