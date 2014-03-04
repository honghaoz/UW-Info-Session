//
//  InfoDetailedTitleButton
//  UW Info
//
//  Created by Zhang Honghao on 2/27/14.
//
//

@interface UWInfoDetailedTitleButton : UIButton

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;

- (UWInfoDetailedTitleButton *)initWithText:(NSString *)text detailText:(NSString *)detailText;
- (void)setText:(NSString *)text andDetailText:(NSString *)detailText;
- (void)setText:(NSMutableAttributedString *)attributedString;
- (void)setDetailTextWithAttributedString:(NSMutableAttributedString *)detailAttributedString;

@end
