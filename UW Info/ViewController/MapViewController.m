//
//  MapViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <UIScrollViewAccessibilityDelegate, UIScrollViewDelegate>

@end

@implementation MapViewController {
    UILabel *showOrigin;
    BOOL barIsHidden;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)loadView {
//    [super loadView];
//    
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Map of UWaterloo";
    
    showOrigin =[[UILabel alloc] initWithFrame:(CGRectMake(10, 70, 190, 44))];
    [self.view addSubview:showOrigin];
    showOrigin.text = @"(%i, %i)";
    [showOrigin setBackgroundColor:[UIColor yellowColor]];
    
    
    //self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_colour300.png"]];
    UIImage *map = [UIImage imageNamed:@"map_colour300.png"];
    [self.imageView setFrame:(CGRectMake(0, 0, map.size.width, map.size.height))];
    [self.imageView setImage:map];
    //[self.scrollView addSubview:self.imageView];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setMultipleTouchEnabled:YES];
    //self.imageView.twoFingerTapIsPossible = YES;
    //multipleTouches = NO;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidTopAndBottom:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    
    //[self.imageView addSubview:showOrigin];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.scrollView setContentSize:self.imageView.frame.size];
    
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setMinimumZoomScale:0.3];
    
    [self.scrollView setAutoresizesSubviews:YES];
    
    //self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    [self.scrollView setZoomScale:0.4 animated:NO];
    //[UIView animateWithDuration:0.25 animations:^{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    //}];
    //[self.scrollView scrollRectToVisible:CGRectMake(0, 0, 500, 0) animated:YES];
    self->barIsHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
    //[self.imageView setImage:nil];
    //self.imageView = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    //[self.imageView setImage:[UIImage imageNamed:@"map_colour300.png"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // return which subview want to zoom;
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [showOrigin setText:[NSString stringWithFormat:@"offset: (%.2f, %.2f)\nzoom: %.2f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.zoomScale]];
    //[showOrigin setText:[NSString stringWithFormat:@"offset: %@ \nzoom: %.2f", NSStringFromCGPoint(self.scrollView.contentOffset), self.scrollView.zoomScale]];
    [showOrigin setNumberOfLines:0];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.tabBarController setHidesBottomBarWhenPushed:YES];
    //[showOrigin sizeToFit];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollView Did End Scrolling Animation");
}

-(void) hidTopAndBottom:(UITapGestureRecognizer *)sender {
    //UINavigationControllerHideShowBarDuration = 0.5;
    //[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    
    
//    [UINavigationBar beginAnimations:@"NavBarFade" context:nil];
//    self.navigationController.navigationBar.alpha = 1;
//    [self.navigationController setNavigationBarHidden:YES animated:NO]; //Animated must be NO!
//    [UINavigationBar setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UINavigationBar setAnimationDuration:1.5];
//    self.navigationController.navigationBar.alpha = 0;
//    [UINavigationBar commitAnimations];
    
//    [self.tabBarController.tabBar setHidden:!self.tabBarController.tabBar.hidden];
    
    if (self->barIsHidden) {
        NSLog(@"hidden -> show");
        //[self showStatusBar:YES];
        self->barIsHidden = NO;
        [self showNavigationBar:self.navigationController];
        [self showTabBar:self.tabBarController];
        
    } else {
        NSLog(@"show -> hidden");
        //[self showStatusBar:NO];
        self->barIsHidden = YES;
        [self hideNavigationBar:self.navigationController];
        [self hideTabBar:self.tabBarController];
        
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//barIsHidden;
}

- (void)updateStatusBar{
    [UIView animateWithDuration:0.5 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}


// HideTabBar animated
- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in self.navigationController.view.subviews) {
        NSLog(@"%@", NSStringFromClass(view.class));
    }
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
    [UIView commitAnimations];
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        float fHeight = screenRect.size.height;
//        if( UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
//        {
//            fHeight = screenRect.size.width;
//        }
//        
//        for(UIView *view in tabbarcontroller.view.subviews)
//        {
//            //NSLog(@"%@", NSStringFromClass(view.class));
//            if([view isKindOfClass:[UITabBar class]])
//            {
//                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
//            }
//            else
//            {
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
//                view.backgroundColor = [UIColor yellowColor];
//            }
//        }
//    }completion:nil];
}

- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - tabbarcontroller.tabBar.frame.size.height;
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - tabbarcontroller.tabBar.frame.size.height;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    [UIView commitAnimations];

}

- (void) hideNavigationBar:(UINavigationController *) navigationController
{
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
////    float fHeight = screenRect.size.height;
////    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
////    {
////        fHeight = screenRect.size.width;
////    }
//    UINavigationBar *naviBar = navigationController.view.subviews[1];
//    
//    [naviBar setFrame:CGRectMake(naviBar.frame.origin.x, -naviBar.frame.size.height, naviBar.frame.size.width, naviBar.frame.size.height)];
//    
////    for(UIView *view in navigationController.view.subviews)
////    {
////        if([view isKindOfClass:[UINavigationBar class]])
////        {
////            [view setFrame:CGRectMake(view.frame.origin.x, -view.frame.size.height, view.frame.size.width, view.frame.size.height)];
////        }
//////        else
//////        {
//////            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
//////        }
////    }
//    [UIView commitAnimations];
    [self updateStatusBar];
    
    UINavigationBar *naviBar = navigationController.view.subviews[1];
    [UIView animateWithDuration:0.5 animations:^{
        [naviBar setFrame:CGRectMake(naviBar.frame.origin.x, -naviBar.frame.size.height, naviBar.frame.size.width, naviBar.frame.size.height)];
    }completion:^(BOOL finished){
        ;
    }];
}

- (void) showNavigationBar:(UINavigationController *) navigationController
{
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self updateStatusBar];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
//    float fHeight = screenRect.size.height;
//    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
//    {
//        fHeight = screenRect.size.width;
//    }
    UINavigationBar *naviBar = navigationController.view.subviews[1];
    
    [naviBar setFrame:CGRectMake(naviBar.frame.origin.x, 20.0f, naviBar.frame.size.width, naviBar.frame.size.height)];
    
//    for(UIView *view in navigationController.view.subviews)
//    {
//        if([view isKindOfClass:[UINavigationBar class]])
//        {
//            [view setFrame:CGRectMake(view.frame.origin.x, 20.0f, view.frame.size.width, view.frame.size.height)];
//        }
////        else
////        {
////            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
////        }
//    }
    [UIView commitAnimations];
}
@end
