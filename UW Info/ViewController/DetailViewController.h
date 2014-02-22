//
//  DetailViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertViewController.h"
@class InfoSession;
@class InfoSessionModel;
@class DetailViewController;
@class UWTabBarController;
@class DetailDescriptionCell;

//@protocol DetailViewControllerDelegate <NSObject>
//
//- (void)detailViewController:(DetailViewController *)detailController didAddInfoSession:(InfoSession *)infoSession;
//
//@end

@interface DetailViewController : UITableViewController <AlertViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *caller;
@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSession *infoSessionBackup;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, weak) DetailDescriptionCell *noteCell;

@property (nonatomic, weak) UWTabBarController *tabBarController;
@property (nonatomic, copy) NSString *performedNavigation;

//@property (nonatomic, weak) UITabBarController <DetailViewControllerDelegate> *delegate;

@end
