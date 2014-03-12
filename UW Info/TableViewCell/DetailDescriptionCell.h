//
//  DetailDescriptionCell.h
//  UW Info
//
//  Created by Zhang Honghao on 2/9/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PSPDFTextView;

@interface DetailDescriptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet PSPDFTextView *contentText;

@end
