//
//	PullHeaderViewController.h
//	PullCycle
//
//	Created by Zachary Witte on 12/10/13.
//	Copyright (c) 2013 Zachary Witte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	PullHeaderPulling = 0,
	PullHeaderNormal,
	PullHeaderLoading,
} PullHeaderState;

typedef enum{
	PullHeaderTop = 0,
	PullHeaderBottom
} PullHeaderPosition;

@protocol PullHeaderDelegate;
@interface PullHeaderView : UIView {
	UIScrollView *_scrollView;
	NSObject *delegate;
	PullHeaderState _state;
	PullHeaderPosition _position;
	CGSize _originalContentSize;
	
	UILabel *_subTextLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
	
}

@property(nonatomic,assign) NSObject <PullHeaderDelegate> *delegate;

- (id)initWithScrollView:(UIScrollView*)sv arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor subText:(NSString*)subText position:(PullHeaderPosition)position;
- (CGRect)makeFrameForScrollView:(UIScrollView*)scollView position:(PullHeaderPosition)position;

- (void)updateSubtext;
- (void)pullHeaderScrollViewDidScroll:(UIScrollView *)sv;
- (void)pullHeaderScrollViewDidEndDragging:(UIScrollView *)sv;
- (void)pullHeaderScrollViewDataSourceDidFinishedLoading:(UIScrollView *)sv;
- (void)pullHeaderScrollViewDidChangeSize:(UIScrollView*)sv;
@end

@protocol PullHeaderDelegate
- (void)pullHeaderDidTrigger:(PullHeaderView*)view;
- (BOOL)pullHeaderSourceIsLoading:(PullHeaderView*)view;
@optional
- (NSString*)pullHeaderSubtext:(PullHeaderView*)view;
@end
