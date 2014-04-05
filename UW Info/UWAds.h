//
//  UWAds.h
//  UW Info
//
//  Created by Zhang Honghao on 4/5/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import "GADAdMobExtras.h"

@interface UWAds : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *iAdBannerView;
@property (nonatomic, strong) GADBannerView *googleBannerView;

@property (nonatomic, assign) BOOL googleAdisLoaded;
@property (nonatomic, strong) id currentDelegate;

+(UWAds *)singleton;
//-(id)initWithOriginY:(CGFloat)y;
-(void)resetAdView:(UIViewController *)rootViewController OriginY:(CGFloat)y;

@end
