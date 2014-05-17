//
//  ZHHPullView.h
//  UW Info
//
//  Created by Zhang Honghao on 5/16/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    PullPulling = 0, // pulling, but not release
    PullNormal, // normal state, not shown or shown a little
    PullLoading // loading state
} PullState;

typedef enum {
    PullTop = 0,
    PullBottom
} PullPosition;

@class ZHHPullView;

@protocol ZHHPullViewDelegate <NSObject>

- (void)pullViewDidTrigger:(ZHHPullView *)pullView;
- (BOOL)pullViewSourceIsLoading:(ZHHPullView*)pullView;

@optional

- (NSString*)pullViewSubtext:(ZHHPullView*)pullView;

@end

@interface ZHHPullView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) PullState state;
@property (nonatomic, assign) PullPosition position;
@property (nonatomic, assign) CGSize originalContentSize;
@property (nonatomic, assign) UIEdgeInsets originalContentInset;

@property (nonatomic, assign) CGFloat topOffset;
@property (nonatomic, assign) CGFloat bottomOffset;

@property (nonatomic, strong) UILabel *subtextLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CALayer *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak) id <ZHHPullViewDelegate> delegate;

//- (id)initWithScrollView:(UIScrollView *)scrollView arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subtext:(NSString*)subtext position:(PullPosition)position;

/**
 *  Initialize a new pull view
 *
 *  @param scrollView   the scroll view want to attach
 *  @param arrow        image name
 *  @param textColor    text color
 *  @param subtext      subtext title
 *  @param position     top or bottom
 *  @param topOffset    the offset of top scroll view
 *  @param bottomOffset the offset of bottom scroll view
 *
 *  @return a new pull view
 */
- (id)initWithScrollView:(UIScrollView *)scrollView arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subtext:(NSString*)subtext position:(PullPosition)position withTopOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;

/**
 *  Get the frame of pull view
 *
 *  @param scrollView   scroll to be attached
 *  @param position     top or bottom
 *  @param topOffset    the offset of top scroll view
 *  @param bottomOffset the offset of bottom scroll view
 *
 *  @return frame of pull view
 */
- (CGRect)getFrameForScrollView:(UIScrollView*)scrollView position:(PullPosition)position withTopOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset;

/**
 *  Update subtext
 */
- (void)updateSubtext;

/**
 *  Data scorce finish loading
 *
 *  @param scrollView scroll view attached
 */
- (void)pullViewScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

/**
 *  refresh the pull view's frame
 *
 *  @param scrollView scroll view attached
 */
- (void)pullViewScrollViewDidChange:(UIScrollView*)scrollView;


/**
 *  Delegate calls DidScroll
 *
 *  @param scrollView scroll view attached
 */
- (void)pullViewScrollViewDidScroll:(UIScrollView *)scrollView;

/**
 *  Delegate calls DidEndDragging
 *
 *  @param scrollView scroll view attached
 */
- (void)pullViewScrollViewDidEndDragging:(UIScrollView *)scrollView;

@end
