//
//  AlertViewController.h
//  UW Info
//
//  Created by Zhang Honghao on 2/11/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfoSession;
@class InfoSessionModel;
@class AlertViewController;

@protocol AlertViewControllerDelegate <NSObject>

- (void)alertViewController:(AlertViewController *)alertController didSelectAlertChoice:(NSInteger)alertIndex;

@end

@interface AlertViewController : UITableViewController

@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, assign) NSInteger alertIndex;

@property (nonatomic, assign) NSInteger checkRow;
@property (nonatomic, strong) NSMutableArray *alertChoices;

@property (nonatomic, weak) id <AlertViewControllerDelegate> delegate;

//@property (nonatomic, weak) UITabBarController <DetailViewControllerDelegate> *delegate;

@end
