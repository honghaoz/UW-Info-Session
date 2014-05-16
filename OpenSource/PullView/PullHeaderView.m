//
//	PullHeaderViewController.m
//	PullCycle
//
//	Created by Zachary Witte on 12/10/13.
//	Copyright (c) 2013 Zachary Witte. All rights reserved.
//

#import "PullHeaderView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f
#define HEIGHT 65.0f;

@interface PullHeaderView (Private)
- (void)setState:(PullHeaderState)aState;
@end

@implementation PullHeaderView

@synthesize delegate=_delegate;

static int kObservingContentSizeChangesContext;

- (id)initWithScrollView:(UIScrollView*)sv arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subText:(NSString *)subText position:(PullHeaderPosition)position  {
	
	CGRect frame = [self makeFrameForScrollView:sv position:position];
//	  CGRect frame = CGRectMake(0.0f, 0.0f - 65.0f, 320.0f, 65.0f);
//	  NSLog(@"initializing frame: x: %f y: %f w: %f h: %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	if((self = [super initWithFrame:frame])) {
		CALayer *layer;
		_originalContentSize = sv.contentSize;
		_scrollView = sv;
		[_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		self.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:31.0/255.0 blue:237.0/255.0 alpha:1.0];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 30.0f, self.frame.size.width-50.0f, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;
		label.text = subText;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_subTextLabel=label;
		
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
		
		layer = [CALayer layer];
		layer.frame = CGRectMake(15.0f, 0.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, 28.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		_position = position;
		
		[self setState:PullHeaderNormal];
		[self updateSubtext];
		
	}
	
	return self;
	
}

- (void)viewWillAppear:(BOOL)animated {
	[self pullHeaderScrollViewDidChangeSize:_scrollView];
	[_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:&kObservingContentSizeChangesContext];
}

- (void)viewDidDisappear:(BOOL)animated {
	[_scrollView removeObserver:self forKeyPath:@"contentSize" context:&kObservingContentSizeChangesContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kObservingContentSizeChangesContext) {
        UIScrollView *sv = object;
//        NSLog(@"%@ contentSize changed to %@", sv, NSStringFromCGSize(sv.contentSize));
		[self pullHeaderScrollViewDidChangeSize:sv];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (CGRect)makeFrameForScrollView:(UIScrollView*)scrollView position:(PullHeaderPosition)position {
	float y;
	if (position == PullHeaderTop) {
//		y = 0.0f - HEIGHT;
        y = scrollView.contentInset.top - HEIGHT;
	} else {
		y = scrollView.contentSize.height + scrollView.contentInset.bottom;
	}
	float h = HEIGHT;
	
	CGRect frame = CGRectMake(0.0f, y, scrollView.contentSize.width, h);
//	  CGRect frame = CGRectMake(0.0f, 0.0f - scrollView.frame.size.height, scrollView.frame.size.width, scrollView.frame.size.height);
	return frame;
}

//- (id)initWithScrollView:(UIScrollView*)sv {
//	  return [self initWithScrollView:sv arrowImageName:@"blueArrow.png" textColor:TEXT_COLOR subText:@"Pull to go next" position:PullHeaderTop];
//}

#pragma mark -
#pragma mark Setters

- (void)updateSubtext {
	if ([self.delegate respondsToSelector:@selector(pullHeaderSubtext:)]) {
		_subTextLabel.text = [self.delegate pullHeaderSubtext:self];
		[[NSUserDefaults standardUserDefaults] setObject:_subTextLabel.text forKey:@"PullHeaderView_subText"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		_subTextLabel.text = nil;
	}
//	  NSLog(@"update subtext: %@", _subTextLabel.text);
}

- (void)setState:(PullHeaderState)aState{
	
	switch (aState) {
		case PullHeaderPulling:
			if (_position == PullHeaderTop) {
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
		case PullHeaderNormal:
			
			if (_state == PullHeaderPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			if (_position == PullHeaderTop) {
				_statusLabel.text = NSLocalizedString(@"Pull down to go previous...", @"Pull down to go previous");
			} else {
				_statusLabel.text = NSLocalizedString(@"Pull up to go next...", @"Pull up to go next");
			}
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
//			NSLog(@"perform flip. text: %@", _statusLabel.text);
			
			break;
		case PullHeaderLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)pullHeaderScrollViewDidScroll:(UIScrollView *)sv {
	
	if (_state == PullHeaderLoading) {
		CGFloat offset = MAX(sv.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		if (_position == PullHeaderTop) {
			sv.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		} else {
			sv.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
		}
	} else if (sv.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(pullHeaderSourceIsLoading:)]) {
			_loading = [_delegate pullHeaderSourceIsLoading:self];
		}
		
		if (_position == PullHeaderTop) {
			if (_state == PullHeaderPulling && sv.contentOffset.y > -65.0f && sv.contentOffset.y < 0.0f && !_loading) {
				[self setState:PullHeaderNormal];
			} else if (_state == PullHeaderNormal && sv.contentOffset.y < -65.0f && !_loading) {
				[self setState:PullHeaderPulling];
			}
		} else {
//			  NSLog(@"offset+height: %f", sv.contentOffset.y+sv.frame.size.height);
			float pos = sv.contentOffset.y+sv.frame.size.height - sv.contentSize.height;
			if (_state == PullHeaderPulling && pos > 0.0f && pos < 65.0f && !_loading) {
				[self setState:PullHeaderNormal];
			} else if (_state == PullHeaderNormal && pos > 65.0f && !_loading) {
				[self setState:PullHeaderPulling];
			}
		}
		
		
		if (sv.contentInset.top != 0) {
			sv.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)pullHeaderScrollViewDidEndDragging:(UIScrollView *)sv {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(pullHeaderSourceIsLoading:)]) {
		_loading = [_delegate pullHeaderSourceIsLoading:self];
	}
	
	BOOL bounds = NO;
	if (_position == PullHeaderTop && sv.contentOffset.y <= - 65.0f) {
		bounds = YES;
	} else if (_position == PullHeaderBottom && sv.contentOffset.y+sv.frame.size.height - sv.contentSize.height >= 56.0f) {
		bounds = YES;
	}
	
	if (bounds && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(pullHeaderDidTrigger:)]) {
			[_delegate pullHeaderDidTrigger:self];
		}
//		NSLog(@"contentSize before: %f", sv.contentSize.height);
		[self setState:PullHeaderLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		UIEdgeInsets insets;
		if (_position == PullHeaderTop) {
			insets = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			sv.contentInset = insets;
		} else {
//			insets = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
//			sv.contentInset = insets;
			sv.contentSize = CGSizeMake(_originalContentSize.width, _originalContentSize.height+60.0f);
		}
		[UIView commitAnimations];
//		NSLog(@"contentSize after: %f", sv.contentSize.height);
	}
	
}

- (void)pullHeaderScrollViewDataSourceDidFinishedLoading:(UIScrollView *)sv {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[sv setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[sv setContentSize:_originalContentSize];
	[UIView commitAnimations];
	
	[self setState:PullHeaderNormal];
	
}

- (void)pullHeaderScrollViewDidChangeSize:(UIScrollView*)sv {
	self.frame = [self makeFrameForScrollView:sv position:_position];
}


@end