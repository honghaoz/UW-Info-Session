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
    // set title
    self.title = @"Map of UWaterloo";
    
    // show origin label
    showOrigin =[[UILabel alloc] initWithFrame:(CGRectMake(10, 70, 190, 44))];
    [self.view addSubview:showOrigin];
    showOrigin.text = @"(%i, %i)";
    [showOrigin setBackgroundColor:[UIColor yellowColor]];
    
    
    // set imageView
    UIImage *map = [UIImage imageNamed:@"map_colour300.png"];
    [self.imageView setFrame:(CGRectMake(0, 0, map.size.width, map.size.height))];
    [self.imageView setImage:map];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView setMultipleTouchEnabled:YES];
    //self.imageView.twoFingerTapIsPossible = YES;
    //multipleTouches = NO;
    
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidTopAndBottom:)];
//    [self.scrollView addGestureRecognizer:tapGesture];
    
    //[self.imageView addSubview:showOrigin];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setFrame:[[UIScreen mainScreen] bounds]];
    [self.scrollView setContentSize:self.imageView.frame.size];

    
    
    
    
    UITapGestureRecognizer *doubleTap;
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [singleTap setNumberOfTapsRequired:1];
    //[singleTap setDelegate:self];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setMinimumZoomScale:0.3];
    // ??
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

#pragma mark - tap method

- (void)handleSingleTap
{
    NSLog(@"single tap");
    
    //    //Toggle visible/hidden status bar.
    //    //This will only work if the Info.plist file is updated with two additional entries
    //    //"View controller-based status bar appearance" set to NO and "Status bar is initially hidden" set to YES or NO
    //    //Hiding the status bar turns the gesture shortcuts for Notification Center and Control Center into 2 step gestures
    
    // hidden -> show
    if (self->barIsHidden) {
        //NSLog(@"hidden -> show");
        //[self showStatusBar:YES];
        self->barIsHidden = NO;
        
        //    [[UIApplication sharedApplication]setStatusBarHidden:![[UIApplication sharedApplication]isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.5 animations:^
         {
             [self.navigationController.navigationBar setAlpha:1.0];
             //[self.navigationController.toolbar setAlpha:alpha];
             [self showTabBar:self.tabBarController];

         } completion:^(BOOL finished)
         {
             
         }];
    }
    // show -> hidden
    else {
        //NSLog(@"show -> hidden");
        //[self showStatusBar:NO];
        self->barIsHidden = YES;
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.5 animations:^
         {
             [self.navigationController.navigationBar setAlpha:0.0];
             //[self.navigationController.toolbar setAlpha:alpha];
             [self hideTabBar:self.tabBarController];
         } completion:^(BOOL finished)
         {
             
         }];
    }
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

#pragma mark - Zoom methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [self.imageView frame].size.height / scale;
    zoomRect.size.width  = [self.imageView frame].size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self.scrollView];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"doubletaped");
    float newScale = [self.scrollView zoomScale] * 8.0;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
    
}

//- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
//{
//    float newScale = self.scrollView.zoomScale * 1.5;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
//    [self.scrollView zoomToRect:zoomRect animated:YES];
//}
//
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    CGRect zoomRect;
//    zoomRect.size.height = self.scrollView.frame.size.height / scale;
//    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
//    
//    center = [self.imageView convertPoint:center fromView:self.scrollView];
//    
//    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
//    return zoomRect;
//}
@end
