//
//  SearchViewController1.h
//  UW Info
//
//  Created by Zhang Honghao on 3/2/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UWTabBarController;
@class InfoSessionModel;

@interface SearchViewController1 : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, weak) UWTabBarController *tabBarController;

- (void)reloadTable;

@end
