//
//  ZHHPullView.m
//  UW Info
//
//  Created by Zhang Honghao on 5/16/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "ZHHPullView.h"

#define TEXT_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define HEIGHT 65.0f;

@implementation ZHHPullView {
    BOOL shouldUpdateInset;
    CGFloat heightOfPullView;
}

static int kObservingContentSizeChangesContext = 0;
static int kObservingContentInsetChangesContext = 1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithScrollView:(UIScrollView *)scrollView arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subtext:(NSString*)subtext position:(PullPosition)position withTopOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset {
    // Get the frame of pull view for attached scrollView
    CGRect frame = [self getFrameForScrollView:scrollView position:position withTopOffset:topOffset andBottomOffset:bottomOffset];
    _topOffset = topOffset;
    _bottomOffset = bottomOffset;
    heightOfPullView = HEIGHT;
    if ((self = [super initWithFrame:frame])) {
        _originalContentSize = scrollView.contentSize;
        _originalContentInset = scrollView.contentInset;
        _scrollView = scrollView;
        
        // add observer, used for update pull view's frame when scroll view is updated
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:&kObservingContentSizeChangesContext];
        [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:&kObservingContentInsetChangesContext];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        shouldUpdateInset = YES;
        
        // initialize uiviews
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 30.0f, self.frame.size.width-50.0f, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;
		label.text = subtext;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_subtextLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(15.0f, 0.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
        [[self layer] addSublayer:layer];
        _arrowImage = layer;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, 28.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		_position = position;
		
		[self setState:PullNormal];
		[self updateSubtext];
    }
    return self;
}

/**
 *  Get Pull View's frame according target scroll view, position and either offset
 *
 *  @param scrollView   scrollView be attached
 *  @param position     pulltop or pullbottom
 *  @param topOffset    offset of top pull view, positive number means move down
 *  @param bottomOffset offset of bottom pull view, positive number means move up
 *
 *  @return the new frame for pull view
 */
- (CGRect)getFrameForScrollView:(UIScrollView*)scrollView position:(PullPosition)position withTopOffset:(CGFloat)topOffset andBottomOffset:(CGFloat)bottomOffset {
	CGFloat y;
	if (position == PullTop) {
        //        y = - scrollView.contentInset.top + topOffset - HEIGHT;
        y = -_originalContentInset.top + topOffset - heightOfPullView;
        //NSLog(@"return %f", y);
	} else {
        //		y = scrollView.contentSize.height + scrollView.contentInset.bottom - bottomOffset;
        y = _originalContentSize.height + _originalContentInset.bottom - bottomOffset;
	}
	CGRect frame = CGRectMake(0.0f, y, _originalContentSize.width/*scrollView.contentSize.width*/, heightOfPullView);
    //	  CGRect frame = CGRectMake(0.0f, 0.0f - scrollView.frame.size.height, scrollView.frame.size.width, scrollView.frame.size.height);
	return frame;
}

//- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"pull view will appear");
//	[self pullViewScrollViewDidChange:_scrollView];
//    //    [_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
//    //    [_scrollView addObserver:self forKeyPath:@"contentInset" options:0 context:&kObservingContentInsetChangesContext];
//    
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    NSLog(@"pull view did disappear");
//    //	[_scrollView removeObserver:self forKeyPath:@"contentSize" context:&kObservingContentSizeChangesContext];
//    //    [_scrollView removeObserver:self forKeyPath:@"contentInset" context:&kObservingContentInsetChangesContext];
//}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((context == &kObservingContentSizeChangesContext) || (context == &kObservingContentInsetChangesContext)) {
        UIScrollView *scrollView = object;
        //NSLog(@"scrollView contentSize changed to %@", NSStringFromCGSize(scrollView.contentSize));
        //NSLog(@"scrollView contentInset changed to %@", NSStringFromUIEdgeInsets(scrollView.contentInset));
		[self pullViewScrollViewDidChange:scrollView];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

/**
 *  Update pull view's frame when scrollView updates
 *
 *  @param scrollView <#scrollView description#>
 */
- (void)pullViewScrollViewDidChange:(UIScrollView*)scrollView {
    //NSLog(@"pull view scrollview did change...");
    _originalContentSize = scrollView.contentSize;
    if (shouldUpdateInset) {
        _originalContentInset = scrollView.contentInset;
    }
    if (_position == PullTop) {
        //NSLog(@"update top frame");
        self.frame = [self getFrameForScrollView:scrollView position:_position withTopOffset:_topOffset andBottomOffset:0];
    } else {
        //NSLog(@"update bottom frame");
        self.frame = [self getFrameForScrollView:scrollView position:_position withTopOffset:0 andBottomOffset:_bottomOffset];
    }
}

/**
 *  Update pull view's subtext
 */
- (void)updateSubtext {
	if ([self.delegate respondsToSelector:@selector(pullViewSubtext:)]) {
		_subtextLabel.text = [self.delegate pullViewSubtext:self];
//		[[NSUserDefaults standardUserDefaults] setObject:_subtextLabel.text forKey:@"PullView_subtext"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		_subtextLabel.text = nil;
	}
    //	  NSLog(@"update subtext: %@", _subTextLabel.text);
}

/**
 *  Set pull view's state, there are three states: normal, pulling and loading
 *
 *  @param aState state to be set
 */
- (void)setState:(PullState)aState{
    NSLog(@"set state...");
	switch (aState) {
		case PullPulling:
            // if change to pulling state, show hint text and rotate the arrow
			if (_position == PullTop) {
				_statusLabel.text = NSLocalizedString(@"Release to go previous...", @"Release to go previous");
			} else {
				_statusLabel.text = NSLocalizedString(@"Release to go next...", @"Release to go next");
			}
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
            //			NSLog(@"perform flip. text: %@", _statusLabel.text);
			break;
		case PullNormal:
            // if change to normal state, restore hint text
			if (_position == PullTop) {
				_statusLabel.text = NSLocalizedString(@"Pull down to go previous...", @"Pull down to go previous");
			} else {
				_statusLabel.text = NSLocalizedString(@"Pull up to go next...", @"Pull up to go next");
			}
            // from pulling to normal, restore the arrow
            if (_state == PullPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			break;
		case PullLoading: {
            CGFloat offset = MAX((_scrollView.contentOffset.y + _originalContentInset.top) * -1, 0);
            offset = MIN(offset, heightOfPullView);
            if (_position == PullTop) {
                shouldUpdateInset = NO;
//                NSLog(@"should no");
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                _scrollView.contentInset = UIEdgeInsetsMake(_originalContentInset.top + offset, _originalContentInset.left, _originalContentInset.bottom, _originalContentInset.right);
                [UIView commitAnimations];
//                NSLog(@"scrollView contentInset changed to %@", NSStringFromUIEdgeInsets(_scrollView.contentInset));
                shouldUpdateInset = YES;
//                NSLog(@"should yes");
            }
            else {
                shouldUpdateInset = NO;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                _scrollView.contentInset = UIEdgeInsetsMake(_originalContentInset.top, _originalContentInset.left, _originalContentInset.bottom + heightOfPullView, _originalContentInset.right);
                [UIView commitAnimations];
                shouldUpdateInset = YES;
            }
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			break;
        }
		default:
			break;
	}
	_state = aState;
}

- (void)pullViewScrollViewDataSourceDidFinishedLoading:(UIScrollView *)sv {
    NSLog(@"pull view did finish loading");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[sv setContentInset:_originalContentInset];
	[sv setContentSize:_originalContentSize];
	[UIView commitAnimations];
	[self setState:PullNormal];
}

#pragma mark ScrollView Methods

/**
 *  Called by delegate's ScrollViewDidScroll, update pull view's state
 *
 *  @param scrollView scrollView attached
 */
- (void)pullViewScrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.isDragging) {
        // get whether soure is loading
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(pullViewSourceIsLoading:)]) {
			_loading = [_delegate pullViewSourceIsLoading:self];
		}
        // for top pull view
		if (_position == PullTop) {
            // if state is pulling, offset.y is not reach to -65 but is pulling down, not loading
			if (_state == PullPulling && (scrollView.contentOffset.y + _originalContentInset.top) > -heightOfPullView && (scrollView.contentOffset.y + _originalContentInset.top) < 0.0f && !_loading) {
                // set state to normal
				[self setState:PullNormal];
			}
            // if state is normal, offset.y reached, not loading
            else if (_state == PullNormal && (scrollView.contentOffset.y + _originalContentInset.top) < -heightOfPullView && !_loading) {
                // set state to pulling
				[self setState:PullPulling];
			}
		}
        // for bottom pull view
        else {
			float pos = (scrollView.contentOffset.y - _originalContentInset.bottom) - scrollView.contentSize.height + scrollView.frame.size.height;
			if (_state == PullPulling && pos > 0.0f && pos < heightOfPullView && !_loading) {
				[self setState:PullNormal];
			} else if (_state == PullNormal && pos > heightOfPullView && !_loading) {
				[self setState:PullPulling];
			}
		}
//		if (sv.contentInset.top != 0) {
//			sv.contentInset = UIEdgeInsetsZero;
//		}
	}
}

- (void)pullViewScrollViewDidEndDragging:(UIScrollView *)scrollView {
    // get whether data source is loading
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(pullViewSourceIsLoading:)]) {
		_loading = [_delegate pullViewSourceIsLoading:self];
	}
    // bounds means reached
	BOOL bounds = NO;
	if (_position == PullTop && (scrollView.contentOffset.y + _originalContentInset.top) <= -heightOfPullView) {
		bounds = YES;
	} else if (_position == PullBottom && (((scrollView.contentOffset.y - _originalContentInset.bottom) + scrollView.frame.size.height - scrollView.contentSize.height) >= heightOfPullView)) {
		bounds = YES;
	}
    
	if (bounds && !_loading) {
        // if data source is loading and reached
		if ([_delegate respondsToSelector:@selector(pullViewDidTrigger:)]) {
			[_delegate pullViewDidTrigger:self];
		}
		[self setState:PullLoading];
	}
}

@end
