//
//  UWRSVPHelper.h
//  UW Info
//
//  Created by Zhang Honghao on 5/17/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWRSVPHelper : NSObject

//@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *rsvpURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (void)registerInfoSessionID:(NSString *)infoID status:(BOOL)on;

@end
