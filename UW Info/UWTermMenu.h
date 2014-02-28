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

@interface UWTermMenu : NSObject

@property (nonatomic, strong) InfoDetailedTitleButton *titleButton;
@property (strong, readwrite, nonatomic) REMenu *menu;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) InfoSessionModel *infoSessionModel;

- (UWTermMenu *)initWithNavigationController:(UINavigationController *)navigationController;
- (InfoDetailedTitleButton *)getMenuButton;
- (void)setTitleTerm;

@end
