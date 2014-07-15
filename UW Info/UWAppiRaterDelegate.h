//
//  UWAppiRaterDelegate.h
//  UW Info
//
//  Created by Honghao on 7/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Appirater.h"

@interface UWAppiRaterDelegate : NSObject <AppiraterDelegate>

+ (UWAppiRaterDelegate *)sharediRateDelegate;

- (void)appiraterDidDisplayAlert:(Appirater *)appirater;
- (void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated;
- (void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated;

@end
