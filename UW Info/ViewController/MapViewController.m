//
//  MapViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <UIScrollViewAccessibilityDelegate>

@end

@implementation MapViewController

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
	// Do any additional setup after loading the view.
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 20, 3300, 2550)];
//    self.scrollView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_colour300.png"]];
    
    //[self.imageView setFrame:CGRectMake(0, 0, 3300, 2550)];
    [self.imageView setImage:[UIImage imageNamed:@"map_colour300.png"]];
    
                         
    [self.scrollView setDelegate:self];
    [self.scrollView setFrame:[[UIScreen mainScreen] applicationFrame]];
    [self.scrollView setContentSize:self.imageView.frame.size];
    
                         
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    
    [self.scrollView setMaximumZoomScale:2];
    [self.scrollView setMinimumZoomScale:0.3];
                         
                         
    //self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    [self.scrollView setZoomScale:0.4 animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
    [self.imageView setImage:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
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

@end
