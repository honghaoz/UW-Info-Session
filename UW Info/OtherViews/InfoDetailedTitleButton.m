//
//  GRTDetailedTitleButtonView.m
//  doGRT
//
//  Created by Greg Wang on 12-12-30.
//
//

#import "InfoDetailedTitleButton.h"

@interface InfoDetailedTitleButton ()

@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UILabel* detailTextLabel;

@end

@implementation InfoDetailedTitleButton

- (InfoDetailedTitleButton*)initWithText:(NSString*)text detailText:(NSString*)detailText
{
    CGFloat labelWidth = 180.0;
    self = [self initWithFrame:CGRectMake(0.0, 0.0, labelWidth, 32.0)];
    if (self) {
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 1.0, labelWidth, 17.0)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        textLabel.font = [UIFont boldSystemFontOfSize:17];

        UILabel* detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, labelWidth, 14.0)];
        detailTextLabel.textAlignment = NSTextAlignmentCenter;
        detailTextLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] - 2.0];

        [self addSubview:textLabel];
        [self addSubview:detailTextLabel];
        self.textLabel = textLabel;
        self.detailTextLabel = detailTextLabel;

        self.textLabel.text = text;
        self.detailTextLabel.text = detailText;
    }
    return self;
}

- (void)setText:(NSString*)text andDetailText:(NSString*)detailText
{
    self.textLabel.text = text;
    self.detailTextLabel.text = detailText;
}

- (void)setText:(NSMutableAttributedString*)attributedString
{
    [self.textLabel setAttributedText:attributedString];
}

- (void)setDetailTextWithAttributedString:(NSMutableAttributedString*)detailAttributedString
{
    [self.detailTextLabel setAttributedText:detailAttributedString];
}

- (void)setTitleColor:(UIColor *)titleColor detailTextColor:(UIColor *)detailColor {
    [self.textLabel setTextColor:titleColor];
    [self.detailTextLabel setTextColor:detailColor];
}

@end
