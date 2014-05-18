//
//  UWRSVPHelper.m
//  UW Info
//
//  Created by Zhang Honghao on 5/17/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "UWRSVPHelper.h"

@implementation UWRSVPHelper

//- (id)init {
//    self = [super init];
//    if (self) {
//        _rsvpURL =
//    }
//}

//[NSURL URLWithString:@"https://h344zhan:Zhh358279765099@info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=2447&mode=off"]

- (void)registerInfoSessionID:(NSString *)infoID status:(BOOL)on {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *baseURL = @"info.uwaterloo.ca/infocecs/students/rsvp/index.php";
    NSString *onOff;
    if (on) {
        onOff = @"on";
    } else {
        onOff = @"off";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@%@id=%@&mode=%@", _username, _password, baseURL, infoID, onOff]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%@", response);
        //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [dataTask resume];
}



@end
