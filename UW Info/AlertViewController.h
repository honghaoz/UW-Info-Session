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

@interface AlertViewController : UITableViewController

@property (nonatomic, strong) InfoSession *infoSession;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, strong) NSArray *alertChoices;

@end
