//
//  DetailViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/8/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoSession;
@class InfoSessionModel;
@class DetailViewController;

//@protocol DetailViewControllerDelegate <NSObject>
//
//- (void)detailViewController:(DetailViewController *)detailController didAddInfoSession:(InfoSession *)infoSession;
//
//@end

@interface DetailViewController : UITableViewController

@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

@property (nonatomic, weak) UITabBarController *tabBarController;

//@property (nonatomic, weak) UITabBarController <DetailViewControllerDelegate> *delegate;

@end
