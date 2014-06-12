//
//  UWWebViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 5/27/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWWebViewController.h"

@interface UWWebViewController ()

@end

@implementation UWWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        _webView.scalesPageToFit = YES;
        self.view = _webView;
        _webProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _webProgress.progressTintColor = UWBlack;
        _webProgress.trackTintColor = [UIColor clearColor];
    }
    return self;
}

//- (void)viewDidLoad {
//    logSelector;
//}

- (void)viewWillAppear:(BOOL)animated {
    LogMethod;
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    CGRect newFrame = _webProgress.frame;
    newFrame.origin.y = height;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    _webProgress.frame = newFrame;

}

- (void)setProgressBar:(float)progress {
    if (self.navigationController) {
        if ([self.navigationController.navigationBar.subviews containsObject:_webProgress]) {
            [_webProgress setProgress:progress animated:YES];
        } else {
            [self.navigationController.navigationBar addSubview:_webProgress];
            [_webProgress setProgress:progress animated:YES];
        }
    }
}

- (void)loadView {
    LogMethod;
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

@end
