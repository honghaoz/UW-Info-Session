//
//  DetailViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertViewController.h"
//#import "PullHeaderView.h"

@class InfoSession;
@class InfoSessionModel;
@class DetailViewController;
@class UWTabBarController;
@class DetailDescriptionCell;

@interface DetailViewController : UITableViewController <AlertViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *caller;
@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSession *infoSessionBackup;
// orginal is the infoSession in tab0, if caller is myInfoSessionView, then nil
@property (nonatomic, strong) InfoSession *originalInfoSession;
@property (nonatomic, assign) BOOL openedMyInfo;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, weak) UWTabBarController *tabBarController;

// performedNavigation is a string records what navigation action causes DetailView disappears
@property (nonatomic, copy) NSString *performedNavigation;

//// add pull up/down to prev/next
//@property(nonatomic) PullHeaderView *prevPullHeaderView;
//
//- (void)goNext:(id)sender;
//- (void)goPrevious:(id)sender;
//- (void)preformTransitionToViewController:(UIViewController*)view direction:(NSString*)direction;

@end
