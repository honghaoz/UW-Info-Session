//
//  WeixinSessionActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinSessionActivity.h"

@implementation WeixinSessionActivity

- (UIImage *)_activityImage
{
    return [UIImage imageNamed:@"uiactivity_wechat"];
}

//- (UIImage *)activityImage
//{
//    return [UIImage imageNamed:@"icon_session"];
//}


- (NSString *)activityTitle
{
    return NSLocalizedString(@"WeChat Friends", nil);
}

@end
