//
//  UWTermMenu.m
//  UW Info
//
//  Created by Zhang Honghao on 2/27/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWTermMenu.h"
#import "REMenu.h"
#import "InfoDetailedTitleButton.h"
#import "InfoSessionModel.h"

@implementation UWTermMenu

- (UWTermMenu *)initWithNavigationController:(UINavigationController *)navigationController {
    if (navigationController == nil) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        self.navigationController = navigationController;
    }
    return self;
}

- (InfoDetailedTitleButton *)getMenuButton {
    NSLog(@"get get get");
    _titleButton = [[InfoDetailedTitleButton alloc] initWithText:@"Info Sessions" detailText:@"• • • ▾"];
    [_titleButton addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    REMenuItem *today = [[REMenuItem alloc] initWithTitle:@"2013 Fall"
												 subtitle:nil
													image:nil
										 highlightedImage:nil
												   action:^(REMenuItem *item) {
												   }];
	REMenuItem *dayInAWeek = [[REMenuItem alloc] initWithTitle:@"2014 Winter"
													  subtitle:nil
														 image:nil
											  highlightedImage:nil
														action:^(REMenuItem *item) {
														}];
    REMenuItem *dayInAWeek1 = [[REMenuItem alloc] initWithTitle:@"2014 Spring"
													  subtitle:nil
														 image:nil
											  highlightedImage:nil
														action:^(REMenuItem *item) {
														}];
    
    [self setMenuWithItems:@[today, dayInAWeek, dayInAWeek1]];
    
    //[self setMenu];
    return _titleButton;
}

- (void)setTitleTerm{
    [_titleButton setText:@"Info Sessions" andDetailText:[NSString stringWithFormat:@"%@ ▾", _infoSessionModel.currentTerm == nil ? @"• • •" : _infoSessionModel.currentTerm]];
}

- (void)setMenuWithItems:(NSArray *)items {
    _menu = [[REMenu alloc] initWithItems:items];
//    _menu.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
//    _menu.font = [UIFont systemFontOfSize:19];
//    _menu.textColor = UWBlack;
//    _menu.textShadowColor = [UIColor grayColor];
//    _menu.textShadowOffset = CGSizeMake(0.0, 1.0);
//    _menu.separatorColor = [UIColor lightGrayColor];
//    _menu.borderColor = [UIColor lightGrayColor];
//    
//    _menu.highlightedBackgroundColor = UWGold;
//    _menu.highlightedTextColor = [UIColor lightGrayColor];
//    _menu.highlightedTextShadowColor = [UIColor grayColor];
//    _menu.highlightedSeparatorColor = [UIColor lightGrayColor];
    
    
//    _menu.borderWidth = 0.5;
//    _menu.separatorHeight = 0.5;
//    _menu.itemHeight = 38.0;
//    _menu.bounce = NO;
//    _menu.animationDuration = 0.4;
    
//    _menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//	_menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	_menu.backgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    
    [self.menu setClosePreparationBlock:^{
        NSLog(@"Menu will close");
    }];
    
    [self.menu setCloseCompletionHandler:^{
        NSLog(@"Menu did close");
    }];
}

- (void)toggleMenu:(id)sender
{
    if (self.menu.isOpen)
        return [self.menu close];
    [self.menu showFromNavigationController:_navigationController];
}

@end
