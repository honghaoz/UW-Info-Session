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
#import "InfoSessionsViewController.h"
#import "UWColorSchemeCenter.h"

@implementation UWTermMenu

- (UWTermMenu*)initWithNavigationController:(UINavigationController*)navigationController
{
    if (navigationController == nil) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        self.navigationController = navigationController;
    }
    return self;
}

- (InfoDetailedTitleButton*)getMenuButton
{
    _titleButton = [[InfoDetailedTitleButton alloc] initWithText:@"Info Sessions" detailText:@"• • • ▾"];
    [_titleButton addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];

    [self setTermMenu];

    return _titleButton;
}

- (void)setMenuButtonColor:(UIColor *)color {
    [_titleButton setTitleColor:color detailTextColor:color];
}

/**
 *  Get year number from NSDate
 *
 *  @param date NSDate object
 *
 *  @return NSUInteger for year of NSDate
 */
- (NSUInteger)getCurrentYear:(NSDate*)date
{
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"y"];
    return [[dateFormatter stringFromDate:date] intValue];
}

/**
 *  Get term string from NSDate
 *
 *  @param date NSDate object
 *
 *  @return NSString term string
 */
- (NSString*)getCurrentTermFromDate:(NSDate*)date
{
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter* dateFormatter = [InfoSession estDateFormatter];
    [dateFormatter setDateFormat:@"M"];
    NSUInteger month = [[dateFormatter stringFromDate:date] intValue];
    //NSLog(@"month: %d", month);
    if (1 <= month && month <= 4) {
        return @"Winter";
    } else if (5 <= month && month <= 8) {
        return @"Spring";
    } else {
        return @"Fall";
    }
}

/**
 *  Convert UWTerm toNSString formatted term
 *
 *  @param term UWTerm like UWSpring
 *
 *  @return　NSString like ＠"Spring"
 */
- (NSString*)convertUWTermToTermString:(UWTerm)term
{
    if (term == UWWinter) {
        return @"Winter";
    } else if (term == UWSpring) {
        return @"Spring";
    } else {
        return @"Fall";
    }
}

/**
 *  Convert NSString formatted term to UWTerm
 *
 *  @param term NSString like ＠"Spring"
 *
 *  @return UWTerm like UWSpring
 */
- (UWTerm)convertTermStringToUWTerm:(NSString*)term
{
    if ([term isEqualToString:@"Winter"]) {
        return UWWinter;
    } else if ([term isEqualToString:@"Spring"]) {
        return UWSpring;
    } else {
        return UWFall;
    }
}

/**
 *  Get UWTerm: UWSpring From term string like 2014 Spring
 *
 *  @param termString term string like 2014 Spring
 *
 *  @return UWTerm, like UWSpring
 */
- (UWTerm)getTermFromString:(NSString*)termString
{
    NSLog(@"%@ %d", termString, [termString length]);
    NSRange range = [termString rangeOfString:@" "];
    NSLog(@"%@", NSStringFromRange(range));
    NSString* term = [termString substringFromIndex:range.location + 1];
    NSLog(@"%@ %d", term, [term length]);
    return [self convertTermStringToUWTerm:term];
}

/**
 *  Get next term from a NSString term, eg: return @"Fall" if passed in @"Spring"
 *
 *  @param term NSString like "Spring"
 *
 *  @return NSString like "Spring"
 */
- (NSString*)getNextTermFromString:(NSString*)term
{
    if ([term isEqualToString:@"Winter"]) {
        return @"Spring";
    } else if ([term isEqualToString:@"Spring"]) {
        return @"Fall";
    } else {
        return @"Winter";
    }
}

/**
 *  Get next term from a UWTerm, eg: return UWFall if passed in UWSpring
 *
 *  @param term UWTerm, like UWSpring
 *
 *  @return UWTerm, like UWSpring
 */
- (NSString*)getNextTermFromUWTerm:(UWTerm)term
{
    if (term == UWWinter) {
        return @"Spring";
    } else if (term == UWSpring) {
        return @"Fall";
    } else {
        return @"Winter";
    }
}

- (void)setTermMenu
{
    NSInteger year = [self getCurrentYear:[NSDate date]];
    NSString* currentTerm = [self getCurrentTermFromDate:[NSDate date]];
    NSMutableArray* menuItems = [[NSMutableArray alloc] init];

    NSInteger theNumberOfYearsBefore = 2;

    for (int i = (int)theNumberOfYearsBefore; i > 0; i--) {
        REMenuItem* yearItem = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%li  ▾", year - i]
                                                           image:nil
                                                highlightedImage:nil
                                                          action:^(REMenuItem* item) {
                                                          [self.menu setCloseCompletionHandler:^{
                                                          }];
                                                          [self tapYearAction:year - i];
                                                          }];
        yearItem.textColor = [UIColor lightGrayColor];
        yearItem.highlightedTextColor = [UIColor blackColor];
        [menuItems addObject:yearItem];
    }
    for (int i = UWWinter; i <= UWFall; i++) {
        REMenuItem* termIterm = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%li %@", (long)year, [self convertUWTermToTermString:i]]
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem* item) {
                                                              [self tapTermAction:year term:[self convertUWTermToTermString:i]];
                                                           }];
        if ([currentTerm isEqualToString:[self convertUWTermToTermString:i]]) {
            termIterm.font = [UWColorSchemeCenter helveticaNeueRegularFont:20];//[UIFont boldSystemFontOfSize:20];
            termIterm.textColor = [UIColor blackColor];
            termIterm.highlightedTextColor = [UIColor blackColor];
        }
        if (i < [self convertTermStringToUWTerm:currentTerm]) {
            termIterm.textColor = [UIColor lightGrayColor];
        } else {
            termIterm.textColor = [UIColor blackColor];
        }
        [menuItems addObject:termIterm];
    }

    REMenuItem* yearItem = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%li  ▾", year + 1]
                                                       image:nil
                                            highlightedImage:nil
                                                      action:^(REMenuItem* item) {
                                                          [self.menu setCloseCompletionHandler:^{
                                                          }];
                                                          [self tapYearAction:year + 1];
                                                      }];
    yearItem.textColor = [UIColor blackColor];
    yearItem.highlightedTextColor = [UIColor blackColor];
    [menuItems addObject:yearItem];

    [self setMenuWithItems:menuItems];

    //    [self.menu setClosePreparationBlock:^{
    //        NSLog(@"Menu will close");
    //    }];

    __weak typeof(self) weakSelf = self;
    __weak typeof(_infoSessionViewController) weakInfoSessionVC = _infoSessionViewController;
    [self.menu setCloseCompletionHandler:^{
        [weakSelf setSignOfDetailLabelTo:@"down"];
        weakInfoSessionVC.navigationItem.rightBarButtonItem.enabled = YES;
        weakInfoSessionVC.navigationItem.leftBarButtonItem.enabled = YES;
    }];
}

- (void)setTermMenuForYear:(NSInteger)year
{
    NSMutableArray* menuItems = [[NSMutableArray alloc] init];

    for (int i = UWWinter; i <= UWFall; i++) {
        REMenuItem* termIterm = [[REMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%li %@", (long)year, [self convertUWTermToTermString:i]]
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem* item) {
                                                               [self tapTermAction:year term:[self convertUWTermToTermString:i]];
                                                           }];
        termIterm.textColor = [UIColor blackColor];
        [menuItems addObject:termIterm];
    }

    [self setMenuWithItems:menuItems];

    __weak typeof(self) weakSelf = self;
    __weak typeof(_infoSessionViewController) weakInfoSessionVC = _infoSessionViewController;
    [self.menu setCloseCompletionHandler:^{
        [weakSelf setDetailLabel];
        [weakSelf setTermMenu];
        weakInfoSessionVC.navigationItem.rightBarButtonItem.enabled = YES;
        weakInfoSessionVC.navigationItem.leftBarButtonItem.enabled = YES;
    }];
}

- (void)setDetailLabel
{
    [_titleButton setText:@"Info Sessions" andDetailText:@""];

    // create font
    UIFont* smallerFont = [UWColorSchemeCenter helveticaNeueLightFont:[UIFont systemFontSize] - 6.0];//[UIFont systemFontOfSize:[UIFont systemFontSize] - 6.0];
    UIFont* regularFont = [UWColorSchemeCenter helveticaNeueLightFont:[UIFont systemFontSize] - 2.0];//[UIFont systemFontOfSize:[UIFont systemFontSize] - 2.0];
    // create the attributes
    NSDictionary* attrsForSmaller = [NSDictionary dictionaryWithObjectsAndKeys:smallerFont, NSFontAttributeName, nil];
    NSDictionary* attrsForRegular = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, nil];

    NSString* detailStr = _infoSessionModel.currentTerm == nil ? @"• • •" : _infoSessionModel.currentTerm;

    NSMutableAttributedString* detailString = [[NSMutableAttributedString alloc] initWithString:detailStr attributes:attrsForRegular];
    NSMutableAttributedString* sign = [[NSMutableAttributedString alloc] initWithString:@"  ▼" attributes:attrsForSmaller];
    [detailString appendAttributedString:sign];

    [_titleButton setDetailTextWithAttributedString:detailString];
}

- (void)setDetailLabelWithYear:(NSInteger)year andTerm:(NSString*)term to:(NSString*)sign
{
    NSMutableAttributedString* newText = [[NSMutableAttributedString alloc] initWithAttributedString:_titleButton.detailTextLabel.attributedText];

    NSRange yearTermRange;
    if ([newText length] > 8) {
        yearTermRange = NSMakeRange(0, 11);
    } else {
        yearTermRange = NSMakeRange(0, 4);
    }
    [newText replaceCharactersInRange:yearTermRange withString:[NSString stringWithFormat:@"%li %@", (long)year, term]];
    NSRange signRange = NSMakeRange([newText length] - 1, 1);

    if ([sign isEqualToString:@"up"]) {
        [newText replaceCharactersInRange:signRange withString:@"▲"];
        [_titleButton setDetailTextWithAttributedString:newText];
    } else if ([sign isEqualToString:@"down"]) {
        [newText replaceCharactersInRange:signRange withString:@"▼"];
        [_titleButton setDetailTextWithAttributedString:newText];
    }
}

- (void)setSignOfDetailLabelTo:(NSString*)sign
{
    NSMutableAttributedString* newText = [[NSMutableAttributedString alloc] initWithAttributedString:_titleButton.detailTextLabel.attributedText];

    NSRange range = NSMakeRange([newText length] - 1, 1);

    if ([sign isEqualToString:@"up"]) {
        [newText replaceCharactersInRange:range withString:@"▲"];
        [_titleButton setDetailTextWithAttributedString:newText];
    } else if ([sign isEqualToString:@"down"]) {
        [newText replaceCharactersInRange:range withString:@"▼"];
        [_titleButton setDetailTextWithAttributedString:newText];
    }
}

- (void)setMenuWithItems:(NSArray*)items
{
    _menu = [[REMenu alloc] initWithItems:items];

    _menu.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.97];
    _menu.font = [UWColorSchemeCenter helveticaNeueLightFont:20];//[UIFont systemFontOfSize:20];
    _menu.textColor = [UIColor darkGrayColor];
    _menu.textShadowColor = [UIColor blackColor];
    //    _menu.textShadowOffset = CGSizeMake(0.0, 1.0);
    _menu.separatorColor = [UIColor lightGrayColor];
    _menu.borderColor = [UIColor lightGrayColor];
    //
    _menu.highlightedBackgroundColor = [UIColor lightGrayColor];
    _menu.highlightedTextColor = [UIColor blackColor];
    _menu.highlightedTextShadowColor = [UIColor lightGrayColor];
    _menu.highlightedSeparatorColor = [UIColor lightGrayColor];

    //    _menu.cornerRadius = 2.0;
    //    _menu.shadowColor = [UIColor blackColor];

    _menu.borderWidth = 0.5;
    _menu.separatorHeight = 0.5;
    _menu.itemHeight = 38.0;
    _menu.bounce = NO;
    _menu.animationDuration = 0.4;
    _menu.liveBlur = YES;
    _menu.liveBlurTintColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1.0];

    _menu.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _menu.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _menu.backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (void)toggleMenu:(id)sender
{
    if (self.menu.isOpen) {
        [self.menu close];
        _infoSessionViewController.navigationItem.rightBarButtonItem.enabled = NO;
        _infoSessionViewController.navigationItem.leftBarButtonItem.enabled = NO;
        [self setSignOfDetailLabelTo:@"down"];
    } else {
        [self.menu showFromNavigationController:_navigationController];
        _infoSessionViewController.navigationItem.rightBarButtonItem.enabled = NO;
        _infoSessionViewController.navigationItem.leftBarButtonItem.enabled = NO;
        [self setSignOfDetailLabelTo:@"up"];
    }
}

- (void)tapYearAction:(NSInteger)year
{
    [self.menu closeWithCompletion:^() {
        [self setTermMenuForYear:year];
        [self.menu showFromNavigationController:_navigationController];
        _infoSessionViewController.navigationItem.rightBarButtonItem.enabled = NO;
        _infoSessionViewController.navigationItem.leftBarButtonItem.enabled = NO;
        [self setDetailLabelWithYear:year andTerm:@"" to:@"up"];
    }];
}

- (void)tapTermAction:(NSInteger)year term:(NSString*)term
{
    [self.menu closeWithCompletion:^() {
        _infoSessionViewController.navigationItem.rightBarButtonItem.enabled = YES;
        _infoSessionViewController.navigationItem.leftBarButtonItem.enabled = YES;
        NSDictionary *yearAndTermDic = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:year], term] forKeys:@[@"Year", @"Term"]];
        [_infoSessionViewController reload:yearAndTermDic];
    }];
}

@end
