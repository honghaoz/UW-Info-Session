//
//  WeixinActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinActivityBase.h"

@implementation WeixinActivityBase

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        for (id activityItem in activityItems) {
            if ([activityItem isKindOfClass:[UIImage class]]) {
                return YES;
            }
            if ([activityItem isKindOfClass:[NSURL class]]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            text = activityItem;
        }
    }
}

- (void)setThumbImage:(SendMessageToWXReq *)req
{
//    
//    if (image) {
//        CGFloat width = 100.0f;
//        CGFloat height = image.size.height * 100.0f / image.size.width;
//        UIGraphicsBeginImageContext(CGSizeMake(width, height));
//        [image drawInRect:CGRectMake(0, 0, width, height)];
//        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        [req.message setThumbImage:scaledImage];
//    }
    image = [UIImage imageNamed:@"AppIcon-Rounded.png"];
    CGFloat width = 100.0f;
    CGFloat height = image.size.height * 100.0f / image.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [req.message setThumbImage:scaledImage];
}

- (void)performActivity
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
//    req.bText = NO;
    req.message = WXMediaMessage.message;
    //NSLog(@"%@", [text substringToIndex:9]);
    if ([[text substringToIndex:10] isEqualToString:@"UW Info is"]) {
        req.message.title = @"UW Info Session";
    } else {
        req.message.title = text;
    }
    req.message.description = text;
    
    [self setThumbImage:req];
    if (url) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = @"http://itunes.apple.com/app/uw-info-session/id837207884?mt=8";//[url absoluteString];
        NSLog(@"%@", webObject.webpageUrl);
        req.message.mediaObject = webObject;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        req.message.mediaObject = imageObject;
    }
    [WXApi sendReq:req];
    [self activityDidFinish:YES];
}

@end
