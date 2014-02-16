//
//  MapViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <UIScrollViewAccessibilityDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Map of UWaterloo";
    
    // show origin label
    showOrigin =[[UILabel alloc] initWithFrame:(CGRectMake(10, 70, 190, 44))];
    [self.view addSubview:showOrigin];
    showOrigin.text = @"(%i, %i)";
    [showOrigin setBackgroundColor:[UIColor yellowColor]];
    
    
    UIImage *map = [UIImage imageNamed:@"map_colour300.png"];
    [self.imageView setFrame:(CGRectMake(0, 0, map.size.width, map.size.height))];
    [self.imageView setImage:map];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setMultipleTouchEnabled:YES];
    //self.imageView.twoFingerTapIsPossible = YES;
    //multipleTouches = NO;
    
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidTopAndBottom:)];
//    [self.scrollView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *singleTap;
    singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(screenTapped)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setDelegate:self];
    [self.scrollView addGestureRecognizer:singleTap];
    
    //[self.imageView addSubview:showOrigin];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setFrame:[[UIScreen mainScreen] bounds]];
    [self.scrollView setContentSize:self.imageView.frame.size];
    
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setMinimumZoomScale:0.3];
    
    [self.scrollView setAutoresizesSubviews:YES];
    
    [self.scrollView setZoomScale:0.4 animated:NO];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];

    self->barIsHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [showOrigin setText:[NSString stringWithFormat:@"offset: (%.2f, %.2f)\nzoom: %.2f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.zoomScale]];
    //[showOrigin setText:[NSString stringWithFormat:@"offset: %@ \nzoom: %.2f", NSStringFromCGPoint(self.scrollView.contentOffset), self.scrollView.zoomScale]];
    [showOrigin setNumberOfLines:0];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollView Did End Scrolling Animation");
}

- (void)screenTapped
{
    CGFloat alpha = 0.0;
    
    if (self.navigationController.navigationBar.alpha < 1.0)
        alpha = 1.0;
    
    //Toggle visible/hidden status bar.
    //This will only work if the Info.plist file is updated with two additional entries
    //"View controller-based status bar appearance" set to NO and "Status bar is initially hidden" set to YES or NO
    //Hiding the status bar turns the gesture shortcuts for Notification Center and Control Center into 2 step gestures
    [[UIApplication sharedApplication]setStatusBarHidden:![[UIApplication sharedApplication]isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:0.5 animations:^
     {
         [self.navigationController.navigationBar setAlpha:alpha];
         //[self.navigationController.toolbar setAlpha:alpha];
         if (self->barIsHidden) {
             NSLog(@"hidden -> show");
             //[self showStatusBar:YES];
             self->barIsHidden = NO;
             [self showTabBar:self.tabBarController];
             
         } else {
             NSLog(@"show -> hidden");
             //[self showStatusBar:NO];
             self->barIsHidden = YES;
             [self hideTabBar:self.tabBarController];
         }

     } completion:^(BOOL finished)
     {
         
     }];
    
}
/**
 *  Hide tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
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
}

/**
 *  Show tabbarcontroller
 *
 *  @param tabbarcontroller
 */
- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - tabbarcontroller.tabBar.frame.size.height;
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - tabbarcontroller.tabBar.frame.size.height;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
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

//- (void) hideNavigationBar:(UINavigationController *) navigationController
//{
//    UINavigationBar *naviBar = navigationController.view.subviews[1];
//    [UIView animateWithDuration:0.5 animations:^{
//        [naviBar setFrame:CGRectMake(naviBar.frame.origin.x, -naviBar.frame.size.height, naviBar.frame.size.width, naviBar.frame.size.height)];
//    }completion:^(BOOL finished){
//        ;
//    }];
//}
//
//- (void) showNavigationBar:(UINavigationController *) navigationController
//{
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    UINavigationBar *naviBar = navigationController.view.subviews[1];
//    
//    [naviBar setFrame:CGRectMake(naviBar.frame.origin.x, 20.0f, naviBar.frame.size.width, naviBar.frame.size.height)];
//    
//    [UIView commitAnimations];
//}
@end
