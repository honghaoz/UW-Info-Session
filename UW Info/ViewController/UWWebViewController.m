//
//  UWWebViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 5/27/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWWebViewController.h"

@implementation UWWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        _webView.scalesPageToFit = YES;
        self.view = _webView;
    }
    return self;
}

//- (void)loadView {
//    UIWebView *webView = [[UIWebView alloc] init];
//    webView.scalesPageToFit = YES;
//    self.view = webView;
//}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

@end
