//
//  UWAds.m
//  UW Info
//
//  Created by Zhang Honghao on 4/5/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWAds.h"

@implementation UWAds

-(id)init {
    if (self = [super init]) {
        // iAd
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _iAdBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _iAdBannerView = [[ADBannerView alloc] init];
        }
        _iAdBannerView.backgroundColor = [UIColor clearColor];
        _iAdBannerView.delegate = self;
        
        // Google ad
        _googleBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _googleBannerView.adUnitID = @"ca-app-pub-5080537428726834/9792615501";
        _googleBannerView.delegate = self;
        _googleAdisLoaded = NO;
        
        
    }
    return self;
}

//-(id)initWithOriginY:(CGFloat)y {
//    if (self = [super init]) {
//        // iAd
//        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
//            _iAdBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//        } else {
//            _iAdBannerView = [[ADBannerView alloc] init];
//        }
//        _iAdBannerView.backgroundColor = [UIColor clearColor];
//        CGRect bannerFrame = _iAdBannerView.frame;
//        bannerFrame.origin.y = y;
//        [_iAdBannerView setFrame:bannerFrame];
//        _iAdBannerView.delegate = self;
//        
//        // Google ad
//        _googleBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
//        _googleBannerView.adUnitID = @"ca-app-pub-5080537428726834/9792615501";
//        bannerFrame = _googleBannerView.frame;
//        bannerFrame.origin.y = y;
//        [_googleBannerView setFrame:bannerFrame];
//        _googleBannerView.delegate = self;
//        _googleAdisLoaded = NO;
//        
//    }
//    return self;
//}

+(UWAds *)singleton {
    static dispatch_once_t pred;
    static UWAds *shared;
    // Will only be run once, the first time this is called
    dispatch_once(&pred, ^{
        shared = [[UWAds alloc] init];
    });
    return shared;
}

-(void)resetAdView:(UIViewController *)rootViewController OriginY:(CGFloat)y {
    CGRect bannerFrame = _iAdBannerView.frame;
    bannerFrame.origin.y = y;
    [_iAdBannerView setFrame:bannerFrame];
    
    bannerFrame = _googleBannerView.frame;
    bannerFrame.origin.y = y;
    [_googleBannerView setFrame:bannerFrame];
    
    // Always keep track of currentDelegate for notification forwarding
    _currentDelegate = rootViewController;
    NSLog(@"%@", rootViewController);
    
    // iAd
    if (_iAdBannerView.bannerLoaded) {
        NSLog(@"UWAds iad banner is loaded");
        [_googleBannerView removeFromSuperview];
        [rootViewController.view addSubview:_iAdBannerView];
    } else {
        NSLog(@"UWAds iad banner is not loaded");
        [_iAdBannerView removeFromSuperview];
        // Google Ad
        // Ad already requested, simply add it into the view
        //if (_googleAdisLoaded) {
            NSLog(@"UWAds add google banner");
            [rootViewController.view addSubview:_googleBannerView];
        //}
        //else {
            _googleBannerView.rootViewController = rootViewController;
            NSLog(@"UWAds google ad request");
            GADRequest *request = [GADRequest request];
            //request.testDevices = [NSArray arrayWithObjects: GAD_SIMULATOR_ID, @"b8ab61a5a3e7e3e252774bab62655fd3", nil];
            [request setLocationWithDescription:@"N2L3G1 CA"];
            GADAdMobExtras *extras = [[GADAdMobExtras alloc] init];
            extras.additionalParameters =
            [NSMutableDictionary dictionaryWithObjectsAndKeys:
             @"DDDDDD", @"color_bg",
             @"999999", @"color_bg_top",
             @"BBBBBB", @"color_border",
             @"FF9735", @"color_link",
             @"999999", @"color_text",
             @"FF9735", @"color_url",
             nil];
            [request registerAdNetworkExtras:extras];
            [request setKeywords:[NSMutableArray arrayWithObjects:@"UWaterloo", @"Waterloo", @"Job", @"Internship", @"Full time job", @"Part time job", nil]];
            [_googleBannerView loadRequest:request];
            
            [rootViewController.view addSubview:_googleBannerView];
            //_googleAdisLoaded = YES;
        //}
    }
}

#pragma mark - iAd delegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"UWAds iad did load");
    //NSLog(@"iad banner show");
    [((UIViewController *)_currentDelegate).view addSubview:_iAdBannerView];
    //[_googleBannerView removeFromSuperview];
    if ([_currentDelegate respondsToSelector:@selector(bannerViewDidLoadAd:)]){
        [_currentDelegate bannerViewDidLoadAd:banner];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"UWAds iad load failed");
    [_iAdBannerView removeFromSuperview];
    [((UIViewController *)_currentDelegate).view addSubview:_googleBannerView];
    if ([_currentDelegate respondsToSelector:@selector(bannerView:didFailToReceiveAdWithError:)]){
        [_currentDelegate bannerView:banner didFailToReceiveAdWithError:error];
    }
}

#pragma mark - Google Ad delegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)banner {
    NSLog(@"UWAds google ad did load");
    if (!_iAdBannerView.bannerLoaded) {
        [_iAdBannerView removeFromSuperview];
        [((UIViewController *)_currentDelegate).view addSubview:_googleBannerView];
        if ([_currentDelegate respondsToSelector:@selector(adViewDidReceiveAd:)]){
            [_currentDelegate adViewDidReceiveAd:banner];
        }
    }
}

- (void)adView:(GADBannerView *)banner
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"UWAds google ad load failed");
    //_googleAdisLoaded = NO;
    [_googleBannerView removeFromSuperview];
    if ([_currentDelegate respondsToSelector:@selector(adView:didFailToReceiveAdWithError:)]){
        [_currentDelegate adView:banner didFailToReceiveAdWithError:error];
    }
}

@end
