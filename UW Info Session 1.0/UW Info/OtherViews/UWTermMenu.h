//
//  UWTermMenu.h
//  UW Info
//
//  Created by Zhang Honghao on 2/27/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InfoSessionModel;
@class REMenu;
@class InfoDetailedTitleButton;
@class InfoSessionsViewController;

@interface UWTermMenu : NSObject

@property (nonatomic, strong) InfoDetailedTitleButton *titleButton;
@property (nonatomic, strong) REMenu *menu;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;
@property (nonatomic, weak) InfoSessionsViewController *infoSessionViewController;

- (UWTermMenu *)initWithNavigationController:(UINavigationController *)navigationController;
- (InfoDetailedTitleButton *)getMenuButton;
- (void)setDetailLabel;

- (NSUInteger)getCurrentYear:(NSDate *)date;
- (NSString *)getCurrentTermFromDate:(NSDate *)date;

- (void)setMenuButtonColor:(UIColor *)color;
@end
